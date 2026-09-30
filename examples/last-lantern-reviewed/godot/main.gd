extends Node2D
## Review-informed rules. Standalone game with an optional built-in diagnostic mode.

const WIDTH: int = 19
const HEIGHT: int = 13
const CELL: float = 40.0
const BOARD_ORIGIN: Vector2 = Vector2(34, 146)
const DIRECTIONS: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
const FLOOR_NAMES: Array[String] = ["잿빛 입구", "침묵의 병영", "마왕의 왕좌"]
const FOE_STATS: Dictionary = {
	"slime": {"name": "슬라임", "hp": 8, "attack": 3, "xp": 3},
	"skeleton": {"name": "해골", "hp": 13, "attack": 4, "xp": 4},
	"boss": {"name": "마왕", "hp": 32, "attack": 8, "xp": 0},
	"gate": {"name": "수문장", "hp": 15, "attack": 4, "xp": 6},
}
const GOLD: Color = Color("e8c47d")
const TEAL: Color = Color("79ddc8")
const INK: Color = Color("101a29")
const MUTED: Color = Color("9dacc3")

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var state: String = "title"
var run_seed: int = 0
var floor_number: int = 1
var cells: PackedInt32Array = PackedInt32Array()
var player: Vector2i = Vector2i.ZERO
var stairs: Vector2i = Vector2i.ZERO
var enemies: Array[Dictionary] = []
var items: Dictionary = {}
var hp: int = 28
var max_hp: int = 28
var attack: int = 5
var level: int = 1
var xp: int = 0
var potions: int = 1
var turns: int = 0
var kills: int = 0
var messages: Array[String] = []
var damage_flash: float = 0.0
var font: Font
var hud: Label
var log_label: Label
var floor_label: Label
var hint_label: Label
var overlay: Control
var overlay_title: Label
var overlay_body: Label
var start_button: Button
var restart_dialog: ConfirmationDialog
var fuel: int = 90
var fuel_spent: int = 0
var healing_used: int = 0
var oil_used: int = 0
var potions_burned: int = 0
var started_ms: int = 0
var rooms: Array[Rect2i] = []
var boss_marks: Array[Vector2i] = []
var boss_phase: String = "idle"
var fallback_used: bool = false
var force_fallback: bool = false
var story_label: Label
var seed_input: SpinBox
var retry_button: Button
var best_seed_turns: Dictionary = {}
var persistent_hint: String = ""
var wake_tiles: Dictionary = {}
var placing_fixed: bool = false
const STORIES: Array[String] = [
	"재가 쌓인 입구. 수문장의 봉인을 풀면 병영으로 내려갈 수 있다.",
	"침묵한 병영. 더 싸워 강해질지, 연료를 아껴 왕좌로 갈지 선택하자.",
	"마왕의 왕좌. 예고된 불길을 피해 마지막 일격을 준비하자."
]



func _ready() -> void:
	var bundled_font: FontVariation = FontVariation.new()
	bundled_font.base_font = preload("res://assets/NotoSansKR.ttf")
	bundled_font.variation_opentype = {"wght": 500.0}
	font = bundled_font
	force_fallback = "--force-fallback" in OS.get_cmdline_user_args()
	_build_ui()
	_show_title()
	_publish_snapshot()
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--check-seeds="):
			call_deferred("_run_self_checks", maxi(1, int(argument.trim_prefix("--check-seeds="))))
		elif argument.begins_with("--capture="):
			call_deferred("_capture_preview", argument.trim_prefix("--capture="))
	queue_redraw()


func _build_ui() -> void:
	var ui: Control = Control.new()
	ui.name = "Interface"
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ui)
	_label(ui, "마지막 등불 · 리뷰 반영판", Vector2(34, 22), Vector2(760, 58), 38, GOLD)
	story_label = _label(ui, "연료를 아껴 수문장과 마왕에게 도전하세요.", Vector2(36, 85), Vector2(760, 36), 19, MUTED)
	floor_label = _label(ui, "", Vector2(850, 40), Vector2(382, 46), 26, TEAL)
	hud = _label(ui, "", Vector2(850, 108), Vector2(382, 300), 19)
	_label(ui, "여정의 기록", Vector2(850, 425), Vector2(380, 38), 21, GOLD)
	log_label = _label(ui, "", Vector2(850, 469), Vector2(370, 180), 16, MUTED)
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label = _label(ui, "", Vector2(36, 676), Vector2(756, 34), 18, TEAL)
	_label(ui, "방향키 / WASD  이동·공격   SPACE 대기   H 회복   O 연료   ENTER 계단   R 새 여정", Vector2(36, 724), Vector2(1170, 33), 19)
	_label(ui, "● 슬라임 8/3   ◆ 해골 13/4   K 수문장 15/4   ▼ 마왕 32/8   Z 잠듦 / ! 각성", Vector2(36, 770), Vector2(1170, 30), 17, MUTED)

	overlay = Control.new()
	overlay.name = "RunOverlay"
	ui.add_child(overlay)
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.01, 0.02, 0.035, 0.86)
	shade.size = Vector2(1280, 820)
	overlay.add_child(shade)
	var panel: Panel = Panel.new()
	panel.position = Vector2(310, 120)
	panel.size = Vector2(660, 570)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = INK
	style.border_color = GOLD
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	panel.add_theme_stylebox_override("panel", style)
	overlay.add_child(panel)
	overlay_title = _label(panel, "", Vector2(35, 32), Vector2(590, 60), 34, GOLD)
	overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_body = _label(panel, "", Vector2(50, 104), Vector2(560, 250), 19)
	overlay_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	start_button = Button.new()
	start_button.position = Vector2(145, 475)
	start_button.size = Vector2(370, 64)
	start_button.add_theme_font_override("font", font)
	start_button.add_theme_font_size_override("font_size", 24)
	start_button.pressed.connect(func() -> void: start_run())
	panel.add_child(start_button)
	_label(panel, "도전 seed (같은 값으로 재현)", Vector2(90, 358), Vector2(450, 30), 17, MUTED)
	seed_input = SpinBox.new()
	seed_input.position = Vector2(90, 394)
	seed_input.size = Vector2(210, 52)
	seed_input.max_value = 2147483646
	seed_input.value = 42
	seed_input.add_theme_font_override("font", font)
	seed_input.add_theme_font_size_override("font_size", 20)
	panel.add_child(seed_input)
	retry_button = Button.new()
	retry_button.text = "이 seed로 시작 / 재도전"
	retry_button.position = Vector2(320, 394)
	retry_button.size = Vector2(250, 52)
	retry_button.add_theme_font_override("font", font)
	retry_button.add_theme_font_size_override("font_size", 18)
	retry_button.pressed.connect(func() -> void: start_run(int(seed_input.value)))
	panel.add_child(retry_button)

	restart_dialog = ConfirmationDialog.new()
	restart_dialog.title = "새 여정 시작"
	restart_dialog.dialog_text = "진행 중인 여정을 끝내고 새 던전을 만들까요?"
	restart_dialog.ok_button_text = "새 게임"
	restart_dialog.cancel_button_text = "계속 플레이"
	restart_dialog.add_theme_font_override("font", font)
	restart_dialog.add_theme_font_size_override("font_size", 20)
	restart_dialog.confirmed.connect(func() -> void: start_run())
	ui.add_child(restart_dialog)
	restart_dialog.visibility_changed.connect(_publish_snapshot)


func _label(parent: Node, text_value: String, pos: Vector2, dimensions: Vector2, size_value: int, color: Color = Color("e4ebf5")) -> Label:
	var label: Label = Label.new()
	label.text = text_value
	label.position = pos
	label.size = dimensions
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", size_value)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label


func _show_title() -> void:
	overlay_title.text = "마지막 등불 · 리뷰 반영판"
	overlay_body.text = "이번 여정의 마지막 등불을 들고 새벽을 되찾으세요.\n\n1·2층: K 수문장을 쓰러뜨리면 계단이 열립니다.\n일반 적은 더 싸우거나 남겨 두고 내려갈 수 있습니다.\n매 행동에 연료 1. 연료가 0이면 패배합니다.\n물약 하나를 H(HP +10) 또는 O(연료 +20)에 씁니다.\n3층: X 불길 예고를 피하고 마왕을 처치하면 승리!\nZ는 잠든 적, !는 깨어난 적입니다."
	start_button.text = "여정 시작 · ENTER"
	overlay.show()
	start_button.grab_focus()


func start_run(seed_override: int = -1) -> void:
	if seed_override >= 0:
		run_seed = seed_override % 2147483647
	elif state == "title":
		run_seed = _command_line_seed() if _command_line_seed() >= 0 else int(seed_input.value)
	else:
		rng.randomize()
		run_seed = int(rng.randi() % 2147483647)
	seed_input.value = run_seed
	state = "playing"
	floor_number = 1
	hp = 28
	max_hp = 28
	attack = 5
	level = 1
	xp = 0
	potions = 1
	fuel = 90
	fuel_spent = 0
	healing_used = 0
	oil_used = 0
	potions_burned = 0
	turns = 0
	kills = 0
	damage_flash = 0.0
	persistent_hint = ""
	started_ms = Time.get_ticks_msec()
	messages.clear()
	restart_dialog.hide()
	overlay.hide()
	start_button.release_focus()
	_generate_floor()
	_log("등불 연료 90. 수문장을 처치하고 계단으로 가자.")
	_refresh()


func _command_line_seed() -> int:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--seed="):
			var value: String = argument.trim_prefix("--seed=")
			if value.is_valid_int() and int(value) >= 0:
				return int(value)
	return -1


func _generate_floor() -> void:
	var accepted: bool = false
	if not force_fallback:
		for attempt: int in range(12):
			rng.seed = (run_seed * 31 + floor_number * 1009 + attempt * 7919) % 2147483647
			_make_floor(false)
			if floor_errors().is_empty():
				accepted = true
				break
	fallback_used = not accepted
	if not accepted:
		rng.seed = (run_seed * 31 + floor_number * 1009) % 2147483647
		_make_floor(true)
		if not floor_errors().is_empty():
			state = "error"
			overlay_title.text = "안전한 던전을 만들 수 없습니다"
			overlay_body.text = ", ".join(floor_errors())
			overlay.show()
			return
	boss_marks.clear()
	boss_phase = "idle"
	persistent_hint = ""
	story_label.text = STORIES[floor_number - 1]
	_log("%d층 · %s" % [floor_number, FLOOR_NAMES[floor_number - 1]])


func _carve_corridor(first: Vector2i, last: Vector2i) -> void:
	var cursor: Vector2i = first
	var horizontal_first: bool = true if placing_fixed else rng.randf() < 0.5
	while cursor != last:
		_carve_tile(cursor)
		if (horizontal_first and cursor.x != last.x) or cursor.y == last.y:
			cursor.x += int(sign(last.x - cursor.x))
		else:
			cursor.y += int(sign(last.y - cursor.y))
	_carve_tile(last)


func _empty_cell(min_distance: int) -> Vector2i:
	var choices: Array[Vector2i] = []
	var distances: Dictionary = _paths_from(player)
	for y: int in range(1, HEIGHT - 1):
		for x: int in range(1, WIDTH - 1):
			var tile: Vector2i = Vector2i(x, y)
			if _walkable(tile) and tile != player and tile != stairs and tile != rooms[2].get_center() and int(distances.get(tile, 0)) >= min_distance and _enemy_at(tile) < 0 and not items.has(tile):
				var spaced: bool = true
				for foe: Dictionary in enemies:
					if _distance(foe.pos, tile) < 3:
						spaced = false
				if min_distance < 8 or spaced:
					choices.append(tile)
	if choices.is_empty():
		return Vector2i(-1, -1)
	return choices[0] if placing_fixed else choices[rng.randi_range(0, choices.size() - 1)]


func _spawn_enemy(kind: String, tile: Vector2i) -> void:
	enemies.append({"id": enemies.size(), "kind": kind, "pos": tile, "hp": FOE_STATS[kind]["hp"], "awake": false})


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key: InputEventKey = event as InputEventKey
	if not key.pressed or key.echo or restart_dialog.visible:
		return
	if key.physical_keycode == KEY_R:
		if state == "playing":
			restart_dialog.popup_centered(Vector2i(540, 180))
		else:
			start_run()
		get_viewport().set_input_as_handled()
		return
	if state != "playing":
		if key.physical_keycode == KEY_ENTER:
			start_run()
		return
	match key.physical_keycode:
		KEY_UP, KEY_W: act(Vector2i.UP)
		KEY_RIGHT, KEY_D: act(Vector2i.RIGHT)
		KEY_DOWN, KEY_S: act(Vector2i.DOWN)
		KEY_LEFT, KEY_A: act(Vector2i.LEFT)
		KEY_SPACE: act(Vector2i.ZERO)
		KEY_H: drink_potion()
		KEY_O: burn_potion()
		KEY_ENTER: descend()
		_: return
	get_viewport().set_input_as_handled()


func act(direction: Vector2i) -> void:
	if state != "playing" or restart_dialog.visible or not (direction == Vector2i.ZERO or direction in DIRECTIONS):
		return
	var destination: Vector2i = player + direction
	if direction != Vector2i.ZERO and not _walkable(destination):
		_notice("벽입니다. 턴과 연료를 쓰지 않았습니다.")
		return
	persistent_hint = ""
	var enemy_index: int = _enemy_at(destination)
	if direction != Vector2i.ZERO and enemy_index >= 0:
		_attack_enemy(enemy_index)
	elif direction != Vector2i.ZERO:
		player = destination
		_collect_item()
		if player == stairs and floor_number < 3 and not _gate_alive():
			_finish_action(true)
			return
		if player == stairs and floor_number < 3:
			persistent_hint = "잠긴 계단: K 수문장을 처치하세요. 열린 뒤 여기서 ENTER."
	_finish_action()


func drink_potion() -> void:
	if state != "playing" or restart_dialog.visible:
		return
	if potions == 0 or hp == max_hp:
		_notice("물약이 없습니다. 턴을 쓰지 않았습니다." if potions == 0 else "HP가 가득 차 있습니다. O로 연료에 쓸 수 있습니다.")
		return
	potions -= 1
	var restored: int = mini(10, max_hp - hp)
	hp += restored
	healing_used += restored
	_log("물약으로 HP +%d. 적도 행동합니다." % restored)
	_finish_action()


func _attack_enemy(index: int) -> void:
	var foe: Dictionary = enemies[index]
	foe.hp -= attack
	_log("%s에게 %d 피해." % [FOE_STATS[foe.kind]["name"], attack])
	if int(foe.hp) > 0:
		return
	enemies.remove_at(index)
	kills += 1
	if foe.kind == "boss":
		boss_marks.clear()
		state = "victory_pending"
		return
	if level < 4:
		xp += int(FOE_STATS[foe.kind]["xp"])
		while level < 4 and xp >= _xp_needed():
			xp -= _xp_needed()
			level += 1
			max_hp += 2
			attack += 1
			_log("레벨 %d! 최대 HP +2, 공격 +1 (자동 회복 없음)." % level)
		if level == 4:
			xp = 0
	_log("%s 처치!" % FOE_STATS[foe.kind]["name"])
	if foe.kind == "gate":
		_log("수문장의 봉인이 풀렸다. 남은 적을 건너뛰고 내려갈 수 있다.")


func _collect_item() -> void:
	if not items.has(player):
		return
	var kind: String = items[player]
	items.erase(player)
	if kind == "potion":
		if potions < 3:
			potions += 1
			_log("물약 획득. H 회복 / O 연료 중 선택.")
		else:
			_log("물약 3개로 가득 참. 넘치는 물약은 사라졌다.")
	elif kind == "heart":
		var restored: int = mini(6, max_hp - hp)
		hp += restored
		healing_used += restored
		_log("구슬 HP +%d. 넘치는 회복은 사라졌다." % restored)
	else:
		var restored: int = mini(15 if floor_number == 3 else 25, 140 - fuel)
		fuel += restored
		oil_used += restored
		_log("기름 연료 +%d. 넘치는 연료는 사라졌다." % restored)


func _enemy_turn() -> void:
	for foe: Dictionary in enemies:
		if foe.kind == "boss":
			_boss_turn(foe)
			if state != "playing":
				return
			continue
		var tile: Vector2i = foe.pos
		if _path_distance(tile, player) <= 4:
			foe.awake = true
		if not bool(foe.awake):
			continue
		if _distance(tile, player) == 1:
			_hurt(int(FOE_STATS[foe.kind]["attack"]), FOE_STATS[foe.kind]["name"])
			if state != "playing":
				return
		else:
			foe.pos = _step_towards(tile, player)


func _step_towards(first: Vector2i, target: Vector2i) -> Vector2i:
	# BFS includes occupied cells as obstacles, except the target (the hero).
	var frontier: Array[Vector2i] = [first]
	var previous: Dictionary = {first: first}
	var cursor: int = 0
	while cursor < frontier.size():
		var tile: Vector2i = frontier[cursor]
		cursor += 1
		if tile == target:
			var step: Vector2i = target
			while previous[step] != first:
				step = previous[step]
			return step
		for direction: Vector2i in DIRECTIONS:
			var neighbor: Vector2i = tile + direction
			if not _walkable(neighbor) or previous.has(neighbor):
				continue
			if neighbor != target and _enemy_at(neighbor) >= 0:
				continue
			previous[neighbor] = tile
			frontier.append(neighbor)
	return first


func _walkable(tile: Vector2i) -> bool:
	return tile.x >= 0 and tile.x < WIDTH and tile.y >= 0 and tile.y < HEIGHT and cells[tile.y * WIDTH + tile.x] == 1


func _enemy_at(tile: Vector2i) -> int:
	for index: int in range(enemies.size()):
		if enemies[index]["pos"] == tile:
			return index
	return -1


func _distance(first: Vector2i, last: Vector2i) -> int:
	return absi(first.x - last.x) + absi(first.y - last.y)


func _xp_needed() -> int:
	return 6 + (level - 1) * 4


func _log(message: String) -> void:
	if not messages.is_empty() and messages[-1] == message:
		return
	messages.append(message)
	while messages.size() > 7:
		messages.pop_front()


func _finish_run(victory: bool) -> void:
	state = "won" if victory else "lost"
	if victory:
		var final_turns: int = turns
		if not best_seed_turns.has(run_seed) or final_turns < int(best_seed_turns[run_seed]):
			best_seed_turns[run_seed] = final_turns
	overlay_title.text = "새벽이 돌아왔다" if victory else "등불이 꺼졌다"
	var ending: String = "마왕이 쓰러졌다. 등불의 빛이 새벽으로 번지고,\n마을의 창문이 다시 밝아졌다." if victory else ("등불이 꺼졌다. 새벽을 되찾기 전에\n어둠이 길을 삼켰다." if fuel <= 0 else "용사가 쓰러졌다. 이번 여정의 마지막 불꽃은 꺼졌다.")
	overlay_body.text = "%s\n\n층 %d / 3 · 레벨 %d · 처치 %d\nHP %d / %d · 연료 %d · 행동 %d턴\n세션 내 이 seed 최소 승리 턴: %s\n\n재도전은 다른 가능성의 여정입니다. 성장 초기화." % [ending, floor_number, level, kills, hp, max_hp, fuel, turns, str(best_seed_turns.get(run_seed, "아직 없음"))]
	start_button.text = "새 seed로 새 여정 · R"
	overlay.show()
	start_button.grab_focus()


func _refresh() -> void:
	wake_tiles.clear()
	for foe: Dictionary in enemies:
		if not foe.awake:
			var distances: Dictionary = _paths_from(foe.pos)
			for tile: Vector2i in distances:
				if int(distances[tile]) <= (5 if foe.kind == "boss" else 4):
					wake_tiles[tile] = true
	floor_label.text = "%d층 · %s" % [floor_number, FLOOR_NAMES[floor_number - 1]]
	hud.text = "HP	 %d / %d	 공격 %d\n등불   %d / 140  (매 행동 -1)\n물약   %d / 3  · H:HP / O:연료\n레벨 %d  · 경험치 %s\n남은 적 %d  · 수문장 %s\n행동 %d턴  · SEED %d\n\n%s" % [hp, max_hp, attack, fuel, potions, level, "최대" if level == 4 else "%d / %d" % [xp, _xp_needed()], enemies.size(), "생존" if _gate_alive() else "없음", turns, run_seed, "X: 다음 행동에 불길! 옆 칸으로 피하세요." if boss_phase == "windup" else ("마왕: 회복 중. 공격할 기회!" if boss_phase == "recover" else "Z 잠든 적 / ! 추격 · 점: 각성 범위")]
	log_label.text = "\n".join(messages)
	hint_label.text = persistent_hint if not persistent_hint.is_empty() else ("연료 부족! O는 물약을 연료로 바꿉니다. 0이면 패배." if fuel <= 20 else ("마왕 처치 = 즉시 승리. X 불길 예고를 피하세요." if floor_number == 3 else ("K 수문장 처치가 목표. 일반 적은 선택 전투입니다." if _gate_alive() else "계단이 열렸습니다. 계단으로 이동 / 위에서 ENTER.")))
	if state in ["won", "lost"]:
		var elapsed: int = int((Time.get_ticks_msec() - started_ms) / 1000.0)
		overlay_body.text = overlay_body.text.split("\n행동 기록:")[0] + "\n행동 기록: %d턴 · %d초 · 연료 %d" % [turns, elapsed, fuel]
	_publish_snapshot()
	queue_redraw()


func _process(delta: float) -> void:
	if damage_flash > 0.0:
		damage_flash = maxf(0.0, damage_flash - delta)
		queue_redraw()


func _draw() -> void:
	draw_style_box(_card_style(), Rect2(826, 24, 424, 658))
	draw_line(Vector2(850, 407), Vector2(1225, 407), Color("2c3c51"), 1.0)
	if cells.is_empty():
		return
	for y: int in range(HEIGHT):
		for x: int in range(WIDTH):
			var tile: Vector2i = Vector2i(x, y)
			var rect: Rect2 = Rect2(BOARD_ORIGIN + Vector2(tile) * CELL, Vector2.ONE * (CELL - 2))
			var walkable: bool = _walkable(tile)
			var tint: Color = Color("1c2b3b") if walkable else Color("0e1724")
			if walkable and (x + y) % 2 == 0:
				tint = Color("203041")
			draw_rect(rect, tint)
			if wake_tiles.has(tile):
				draw_circle(rect.position + Vector2(5, 5), 2, TEAL)
			if not walkable:
				draw_line(rect.position + Vector2(4, 7), rect.position + Vector2(32, 7), Color("223047"), 2)
	if floor_number < 3:
		_draw_stairs(stairs, not _gate_alive())
	for tile: Vector2i in boss_marks:
		var mark: Rect2 = Rect2(BOARD_ORIGIN + Vector2(tile) * CELL, Vector2.ONE * (CELL - 2))
		draw_rect(mark, Color("ef7182"), false, 3)
		draw_string(font, _center(tile) + Vector2(-7, 7), "X", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("ffb9b4"))
	for tile: Vector2i in items:
		_draw_item(tile, items[tile])
	for foe: Dictionary in enemies:
		_draw_enemy(foe)
	_draw_hero()


func _card_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = INK
	style.set_corner_radius_all(12)
	return style


func _center(tile: Vector2i) -> Vector2:
	return BOARD_ORIGIN + Vector2(tile) * CELL + Vector2.ONE * (CELL / 2 - 1)


func _draw_stairs(tile: Vector2i, unlocked: bool) -> void:
	var center: Vector2 = _center(tile)
	var color: Color = TEAL if unlocked else Color("6b7589")
	for step: int in range(4):
		draw_line(center + Vector2(-12 + step * 4, -10 + step * 6), center + Vector2(12, -10 + step * 6), color, 3)
	if not unlocked:
		draw_rect(Rect2(center + Vector2(-5, -7), Vector2(10, 10)), Color("a5aec0"))


func _draw_item(tile: Vector2i, kind: String) -> void:
	var center: Vector2 = _center(tile)
	if kind == "potion":
		draw_rect(Rect2(center + Vector2(-5, -12), Vector2(10, 6)), Color("dce7f3"))
		draw_circle(center + Vector2(0, 3), 10, Color("ac86e8"))
		draw_circle(center + Vector2(-3, 0), 3, Color("dfcbff"))
	elif kind == "oil":
		draw_rect(Rect2(center + Vector2(-8, -8), Vector2(16, 18)), GOLD)
		draw_string(font, center + Vector2(-5, 6), "O", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, INK)
	else:
		draw_circle(center, 9, Color("fa929b"))
		draw_line(center + Vector2(-5, 0), center + Vector2(5, 0), Color.WHITE, 3)
		draw_line(center + Vector2(0, -5), center + Vector2(0, 5), Color.WHITE, 3)


func _draw_enemy(foe: Dictionary) -> void:
	var center: Vector2 = _center(foe["pos"])
	var kind: String = foe["kind"]
	if kind == "slime":
		draw_circle(center + Vector2(0, 4), 13, Color("78ce93"))
		draw_rect(Rect2(center + Vector2(-13, 5), Vector2(26, 8)), Color("78ce93"))
	elif kind == "skeleton" or kind == "gate":
		draw_circle(center + Vector2(0, -3), 11, Color("e1ddcd"))
		draw_rect(Rect2(center + Vector2(-6, 6), Vector2(12, 9)), Color("c2bfaf"))
	else:
		draw_colored_polygon(PackedVector2Array([center + Vector2(-15, -12), center + Vector2(15, -12), center + Vector2(0, 16)]), Color("ed7182"))
		draw_line(center + Vector2(-11, -5), center + Vector2(-16, -18), GOLD, 4)
		draw_line(center + Vector2(11, -5), center + Vector2(16, -18), GOLD, 4)
	draw_circle(center + Vector2(-4, -2), 2.5, INK)
	draw_circle(center + Vector2(4, -2), 2.5, INK)
	draw_string(font, center + Vector2(-5, -24), "K" if kind == "gate" else ("!" if foe.awake else "Z"), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, GOLD)
	if not foe.awake and _path_distance(foe.pos, player) <= (5 if kind == "boss" else 4):
		draw_circle(center + Vector2(15, 13), 3, TEAL)
	var full_hp: float = float(FOE_STATS[kind]["hp"])
	draw_rect(Rect2(center + Vector2(-14, -19), Vector2(28, 3)), Color("422737"))
	draw_rect(Rect2(center + Vector2(-14, -19), Vector2(28 * maxf(0, float(foe["hp"]) / full_hp), 3)), Color("ef929b"))


func _draw_hero() -> void:
	var center: Vector2 = _center(player)
	if damage_flash > 0:
		draw_rect(Rect2(center - Vector2.ONE * 19, Vector2.ONE * 38), Color(0.9, 0.2, 0.3, 0.45))
	draw_circle(center, 18, Color(0.91, 0.77, 0.49, 0.12))
	draw_colored_polygon(PackedVector2Array([center + Vector2(-11, -5), center + Vector2(11, -5), center + Vector2(0, 15)]), GOLD)
	draw_circle(center + Vector2(0, -6), 8, Color("f4dea7"))
	draw_line(center + Vector2(-5, -5), center + Vector2(5, -5), INK, 3)
	draw_line(center + Vector2(12, -12), center + Vector2(12, 8), Color("e3eef9"), 3)
	draw_circle(center + Vector2(-13, 4), 5, Color("fff1b4"))


func _carve_tile(tile: Vector2i) -> void:
	if tile.x > 0 and tile.x < WIDTH - 1 and tile.y > 0 and tile.y < HEIGHT - 1:
		cells[tile.y * WIDTH + tile.x] = 1
		if floor_number == 1 and tile.x + 1 < WIDTH - 1:
			cells[tile.y * WIDTH + tile.x + 1] = 1


func _make_floor(fixed: bool) -> void:
	placing_fixed = fixed
	cells.resize(WIDTH * HEIGHT)
	cells.fill(0)
	enemies.clear()
	items.clear()
	rooms.clear()
	var anchors: Array[Vector2i] = [Vector2i(1, 1), Vector2i(11, 1), Vector2i(11, 8), Vector2i(1, 8)]
	for i: int in range(4):
		var dimensions: Vector2i = Vector2i(5, 3) if fixed else Vector2i(rng.randi_range(4, 6), rng.randi_range(3, 4))
		if i == 2 and floor_number == 3:
			dimensions = Vector2i(6, 4)
		var room: Rect2i = Rect2i(anchors[i], dimensions)
		rooms.append(room)
		for y: int in range(room.position.y, room.end.y):
			for x: int in range(room.position.x, room.end.x):
				cells[y * WIDTH + x] = 1
	for i: int in range(4):
		_carve_corridor(rooms[i].get_center(), rooms[(i + 1) % 4].get_center())
	player = rooms[0].get_center()
	stairs = rooms[2].get_center() if floor_number < 3 else Vector2i(-1, -1)
	_spawn_enemy("gate" if floor_number < 3 else "boss", rooms[2].get_center())
	var species: Array[String] = []
	species.assign(["slime", "slime"] if floor_number == 1 else (["skeleton", "skeleton", "skeleton"] if floor_number == 2 else ["skeleton", "skeleton"]))
	for kind: String in species:
		_spawn_enemy(kind, _empty_cell(8))
	var loot: Array[String] = []
	loot.assign(["potion", "oil"] if floor_number == 1 else (["potion", "heart", "oil"] if floor_number == 2 else ["oil"]))
	for kind: String in loot:
		var tile: Vector2i = _empty_cell(1)
		if tile.x < 0:
			return
		items[tile] = kind


func _paths_from(first: Vector2i) -> Dictionary:
	var distance: Dictionary = {first: 0}
	var frontier: Array[Vector2i] = [first]
	var cursor: int = 0
	while cursor < frontier.size():
		var tile: Vector2i = frontier[cursor]
		cursor += 1
		for direction: Vector2i in DIRECTIONS:
			var next: Vector2i = tile + direction
			if _walkable(next) and not distance.has(next):
				distance[next] = int(distance[tile]) + 1
				frontier.append(next)
	return distance


func _path_distance(first: Vector2i, last: Vector2i) -> int:
	return int(_paths_from(first).get(last, 9999))


func floor_errors() -> Array[String]:
	var errors: Array[String] = []
	var reachable: Dictionary = _paths_from(player)
	var total: int = 0
	for value: int in cells:
		total += value
	if reachable.size() != total:
		errors.append("분리된 바닥")
	var occupied: Dictionary = {player: true}
	for foe: Dictionary in enemies:
		if not reachable.has(foe.pos) or occupied.has(foe.pos) or int(reachable.get(foe.pos, 0)) < 8:
			errors.append("적 배치 실패")
		occupied[foe.pos] = true
	for tile: Vector2i in items:
		if not reachable.has(tile) or occupied.has(tile) or tile == stairs:
			errors.append("아이템 배치 실패")
		occupied[tile] = true
	if items.size() != ([2, 3, 1][floor_number - 1]):
		errors.append("아이템 수 부족")
	if floor_number == 3:
		if stairs != Vector2i(-1, -1) or enemies[0].kind != "boss" or enemies[0].pos != rooms[2].get_center():
			errors.append("왕좌 정의 위반")
	elif not reachable.has(stairs) or enemies[0].kind != "gate":
		errors.append("출구 정의 위반")
	return errors


func _gate_alive() -> bool:
	for foe: Dictionary in enemies:
		if foe.kind == "gate":
			return true
	return false


func descend() -> void:
	if state != "playing" or restart_dialog.visible:
		return
	if floor_number == 3 or player != stairs:
		_notice("열린 계단 위에서 ENTER로 내려갑니다.")
	elif _gate_alive():
		_notice("잠긴 계단: K 수문장을 처치해야 합니다.")
	else:
		_finish_action(true)


func burn_potion() -> void:
	if state != "playing" or restart_dialog.visible:
		return
	if potions == 0 or fuel == 140:
		_notice("물약이 없습니다. 연료를 보충하지 못했습니다." if potions == 0 else "연료가 가득 차 있습니다.")
		return
	potions -= 1
	var restored: int = mini(20, 140 - fuel)
	fuel += restored
	potions_burned += 1
	_log("물약을 연료 +%d로 바꿨다. HP 회복과는 양립하지 않는다." % restored)
	_finish_action()


func _finish_action(descending: bool = false) -> void:
	turns += 1
	fuel = maxi(0, fuel - 1)
	fuel_spent += 1
	if state == "victory_pending":
		_finish_run(true)
		_refresh()
		return
	if fuel <= 0:
		_finish_run(false)
		_refresh()
		return
	if fuel in [20, 10]:
		_log("등불 연료 %d! 0이면 패배. 기름이나 O로 보충하세요." % fuel)
	if descending:
		floor_number += 1
		_generate_floor()
	else:
		_enemy_turn()
	_refresh()


func _hurt(damage: int, source: String) -> void:
	hp = maxi(0, hp - damage)
	damage_flash = 0.18
	_log("%s의 공격! HP -%d." % [source, damage])
	if hp == 0:
		_finish_run(false)


func _boss_turn(foe: Dictionary) -> void:
	if not foe.awake and _path_distance(foe.pos, player) <= 5:
		foe.awake = true
		_log("마왕: 이 등불마저 꺼뜨리겠다!")
	if not foe.awake:
		return
	if boss_phase == "windup":
		if player in boss_marks:
			_hurt(8, "예고된 마왕의 불길")
		else:
			_log("마왕의 불길을 피했다!")
		boss_marks.clear()
		boss_phase = "recover"
	elif boss_phase == "recover":
		boss_phase = "idle"
	else:
		boss_marks.assign([player])
		boss_phase = "windup"
		_log("X 불길 예고! 다음 행동에 공격. 옆 칸으로 피하세요.")


func _notice(message: String) -> void:
	persistent_hint = message
	_log(message)
	_refresh()


func _run_self_checks(count: int) -> void:
	var verifier: RefCounted = load("res://self_check.gd").new()
	var result: Dictionary = verifier.run(self, count)
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--report="):
			var file: FileAccess = FileAccess.open(argument.trim_prefix("--report="), FileAccess.WRITE)
			if file != null:
				file.store_string(JSON.stringify(result, "  "))
	print(JSON.stringify(result))
	get_tree().quit(0 if result.errors.is_empty() else 1)


func _capture_preview(file_name: String) -> void:
	start_run(_command_line_seed() if _command_line_seed() >= 0 else 42)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(file_name)
	get_tree().quit()


func _publish_snapshot() -> void:
	if not OS.has_feature("web"):
		return
	var foes: Array[Dictionary] = []
	for foe: Dictionary in enemies:
		foes.append({"kind": foe.kind, "x": foe.pos.x, "y": foe.pos.y, "hp": foe.hp, "awake": foe.awake})
	var loot: Array[Dictionary] = []
	for tile: Vector2i in items:
		loot.append({"kind": items[tile], "x": tile.x, "y": tile.y})
	var marks: Array[Dictionary] = []
	for tile: Vector2i in boss_marks:
		marks.append({"x": tile.x, "y": tile.y})
	var value: Dictionary = {"version": "reviewed", "state": state, "paused": restart_dialog.visible, "seed": run_seed, "floor": floor_number, "hp": hp, "maxHp": max_hp, "fuel": fuel, "potions": potions, "turns": turns, "kills": kills, "level": level, "attack": attack, "x": player.x, "y": player.y, "stairs": {"x": stairs.x, "y": stairs.y}, "cells": Array(cells), "enemies": foes, "items": loot, "marks": marks, "bossPhase": boss_phase}
	JavaScriptBridge.eval("window.gameSnapshot=" + JSON.stringify(value) + ";window.parent.postMessage({type:'lantern-state',data:window.gameSnapshot},window.location.origin);", true)
