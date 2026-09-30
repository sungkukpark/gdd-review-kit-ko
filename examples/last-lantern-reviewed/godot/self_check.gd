extends RefCounted
## Built-in native validation, invoked only by --check-seeds=N. No test plugin.

var errors: Array[String] = []
var checks: int = 0


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		errors.append(message)


func run(game: Node2D, count: int) -> Dictionary:
	var layouts: int = 0
	var fallback_layouts: int = 0
	for seed_value: int in range(count):
		game.start_run(seed_value)
		for floor_value: int in range(1, 4):
			game.floor_number = floor_value
			game._generate_floor()
			check(game.floor_errors().is_empty(), "layout %d/%d" % [seed_value, floor_value])
			check(game.enemies.size() == [3, 4, 3][floor_value - 1], "enemy count")
			for foe: Dictionary in game.enemies:
				check(not foe.awake and game._path_distance(game.player, foe.pos) >= 8, "safe sleeping spawn")
			layouts += 1
			if game.fallback_used:
				fallback_layouts += 1
	game.force_fallback = true
	for floor_value: int in range(1, 4):
		game.start_run(42)
		game.floor_number = floor_value
		game._generate_floor()
		check(game.floor_errors().is_empty() and game.fallback_used, "forced fallback floor %d" % floor_value)
	game.force_fallback = false
	var trace: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.UP, Vector2i.ZERO, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.ZERO]
	game.start_run(42)
	for move: Vector2i in trace:
		game.act(move)
	var first: String = JSON.stringify(snapshot(game))
	game.start_run(42)
	for move: Vector2i in trace:
		game.act(move)
	check(JSON.stringify(snapshot(game)) == first, "same seed and input replay")
	game.floor_number = 2
	game._generate_floor()
	var next_floor: String = JSON.stringify({"cells": game.cells, "items": game.items, "enemies": game.enemies})
	game.start_run(42)
	game.rng.randi()
	game.rng.randi()
	game.floor_number = 2
	game._generate_floor()
	check(JSON.stringify({"cells": game.cells, "items": game.items, "enemies": game.enemies}) == next_floor, "generation independent of prior RNG use")
	game.start_run(42)
	game.player = Vector2i(1, 1)
	game.act(Vector2i.UP)
	var invalid_messages: int = game.messages.size()
	game.act(Vector2i.UP)
	check(game.turns == 0 and game.fuel == 90 and game.messages.size() == invalid_messages, "wall no turn and duplicate feedback")
	game.drink_potion()
	check(game.turns == 0 and game.potions == 1, "full HP no turn")
	game.restart_dialog.popup_centered(Vector2i(540, 180))
	var paused: String = JSON.stringify(snapshot(game))
	game.act(Vector2i.ZERO)
	game.drink_potion()
	game.burn_potion()
	game.descend()
	check(JSON.stringify(snapshot(game)) == paused, "restart dialog blocks gameplay")
	game.restart_dialog.hide()
	game.enemies.clear()
	game.hp = 10
	game.drink_potion()
	check(game.hp == 20 and game.fuel == 89 and game.potions == 0 and game.turns == 1, "H allocates potion to HP")
	game.start_run(42)
	game.enemies.clear()
	game.burn_potion()
	check(game.hp == 28 and game.fuel == 109 and game.potions == 0 and game.turns == 1, "O allocates same potion to fuel")
	game.potions = 3
	game.items[game.player] = "potion"
	game._collect_item()
	check(game.potions == 3 and not game.items.has(game.player), "full potion removes ground stock")
	game.hp = game.max_hp
	game.items[game.player] = "heart"
	game._collect_item()
	check(not game.items.has(game.player), "full HP consumes ground heart")
	game.start_run(42)
	game.player = game.stairs
	game.descend()
	check(game.floor_number == 1 and game.turns == 0, "locked stair Enter feedback")
	# Controlled fixtures check turn ordering; they are not natural playthroughs.
	game.enemies.assign([
		{"id": 0, "kind": "gate", "pos": game.player + Vector2i.LEFT, "hp": 1, "awake": true},
		{"id": 1, "kind": "slime", "pos": game.player + Vector2i.UP, "hp": 8, "awake": true}
	])
	game.act(Vector2i.LEFT)
	check(not game._gate_alive() and game.hp == 25 and game.floor_number == 1, "gate opens while remaining enemy acts")
	game.descend()
	check(game.floor_number == 2 and game.hp == 25 and game.turns == 2, "Enter on unlocked stair transitions without free heal")
	check(game.enemies.all(func(e: Dictionary) -> bool: return not e.awake), "new floor does not act on transition")
	game.start_run(42)
	game.floor_number = 3
	game._generate_floor()
	game.enemies.assign([
		{"id": 0, "kind": "boss", "pos": game.rooms[2].get_center(), "hp": 1, "awake": true},
		{"id": 1, "kind": "skeleton", "pos": game.rooms[2].get_center() + Vector2i.LEFT * 2, "hp": 13, "awake": true}
	])
	game.player = game.enemies[0].pos + Vector2i.LEFT
	game.fuel = 1
	game.act(Vector2i.RIGHT)
	check(game.state == "won" and game.enemies.size() == 1 and game.hp == 28 and game.level == 1 and game.fuel == 0, "boss win beats final fuel and remaining enemy")
	game.start_run(42)
	game.enemies.clear()
	game.fuel = 1
	game.act(Vector2i.ZERO)
	check(game.state == "lost" and game.fuel == 0, "fuel defeat")
	game.start_run(42)
	game.floor_number = 3
	game._generate_floor()
	game.enemies.resize(1)
	game.player = game.enemies[0].pos + Vector2i.LEFT
	var boss_pos: Vector2i = game.enemies[0].pos
	game.act(Vector2i.ZERO)
	check(game.boss_phase == "windup" and game.hp == 28 and game.boss_marks.size() == 1, "boss telegraph before damage")
	game.act(Vector2i.UP)
	check(game.hp == 28 and game.boss_phase == "recover" and game.enemies[0].pos == boss_pos, "one-step dodge and tethered boss")
	game.act(Vector2i.ZERO)
	game.act(Vector2i.ZERO)
	game.act(Vector2i.ZERO)
	check(game.hp == 20, "ignoring next telegraph deals exact 8 damage")
	game.hp = 1
	game._hurt(4, "fixture")
	check(game.state == "lost", "HP defeat")
	game.start_run(42)
	check(game.run_seed == 42 and game.turns == 0 and game.hp == 28 and game.fuel == 90 and game.potions == 1, "same seed retry resets progress")
	game.state = "lost"
	game.start_run()
	check(game.run_seed != 42 and game.turns == 0, "new seed retry resets progress")
	var playthroughs: Array[Dictionary] = []
	for policy: String in ["gate-first", "supplies-and-combat"]:
		for seed_value: int in range(20):
			game.start_run(seed_value)
			while game.state == "playing" and game.turns < 240:
				policy_action(game, policy)
			playthroughs.append({"policy": policy, "seed": seed_value, "result": game.state, "turns": game.turns, "hp": game.hp, "fuel": game.fuel, "healing": game.healing_used, "potionsBurned": game.potions_burned, "kills": game.kills, "floor": game.floor_number})
	for policy: String in ["gate-first", "supplies-and-combat"]:
		var wins: Array[Dictionary] = playthroughs.filter(func(p: Dictionary) -> bool: return p.policy == policy and p.result == "won")
		check(not wins.is_empty(), "natural victory for " + policy)
		for win: Dictionary in wins:
			check(win.turns >= 60 and win.turns <= 160 and win.hp > 0, "winning proxy acceptance " + policy)
	return {"engine": Engine.get_version_info().string, "checks": checks, "layouts": layouts, "randomFallbackLayouts": fallback_layouts, "forcedFallbackFloors": 3, "errors": errors, "playthroughs": playthroughs, "humanPlaytest": "not performed; policies are not beginner win rates"}


func snapshot(game: Node2D) -> Dictionary:
	return {"seed": game.run_seed, "state": game.state, "floor": game.floor_number, "player": game.player, "hp": game.hp, "fuel": game.fuel, "potions": game.potions, "turns": game.turns, "level": game.level, "xp": game.xp, "cells": game.cells, "enemies": game.enemies, "items": game.items}


func policy_action(game: Node2D, policy: String) -> void:
	if game.boss_phase == "windup" and game.player in game.boss_marks:
		for direction: Vector2i in game.DIRECTIONS:
			if game._walkable(game.player + direction) and game._enemy_at(game.player + direction) < 0:
				game.act(direction)
				return
	if game.fuel < 25 and game.hp >= 14 and game.potions > 0:
		game.burn_potion()
		return
	if game.hp <= game.max_hp - 10 and game.potions > 0:
		game.drink_potion()
		return
	if game.fuel < 10 and game.potions > 0:
		game.burn_potion()
		return
	for direction: Vector2i in game.DIRECTIONS:
		if game._enemy_at(game.player + direction) >= 0:
			game.act(direction)
			return
	var targets: Array[Vector2i] = []
	if policy == "supplies-and-combat":
		for tile: Vector2i in game.items:
			targets.append(tile)
		if targets.is_empty():
			for foe: Dictionary in game.enemies:
				if foe.kind != "boss":
					targets.append(foe.pos)
	elif game.fuel < 40:
		for tile: Vector2i in game.items:
			if game.items[tile] == "oil":
				targets.append(tile)
	if targets.is_empty():
		for foe: Dictionary in game.enemies:
			if foe.kind in ["gate", "boss"]:
				targets.append(foe.pos)
	if targets.is_empty() and game.floor_number < 3:
		targets.append(game.stairs)
	if targets.is_empty():
		game.act(Vector2i.ZERO)
		return
	var distances: Dictionary = game._paths_from(game.player)
	targets.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return int(distances.get(a, 9999)) < int(distances.get(b, 9999)))
	var next: Vector2i = game._step_towards(game.player, targets[0])
	# Enemy target is normally an obstacle; use a geometric first step to its tile.
	if next == game.player:
		var best: int = 9999
		for direction: Vector2i in game.DIRECTIONS:
			var tile: Vector2i = game.player + direction
			if game._walkable(tile) and game._enemy_at(tile) < 0:
				var distance: int = game._path_distance(tile, targets[0])
				if distance < best:
					best = distance
					next = tile
	game.act(next - game.player)
