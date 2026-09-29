extends Node2D
## Native, self-contained turn-based roguelike. No addons or external assets.

const WIDTH: int = 19
const HEIGHT: int = 13
const CELL: float = 40.0
const BOARD_ORIGIN: Vector2 = Vector2(34, 146)
const DIRECTIONS: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
const FLOOR_NAMES: Array[String] = ["잿빛 입구", "침묵의 병영", "마왕의 왕좌"]
const FOE_STATS: Dictionary = {
	"slime": {"name": "슬라임", "hp": 7, "attack": 2, "xp": 3},
	"skeleton": {"name": "해골", "hp": 11, "attack": 3, "xp": 5},
	"boss": {"name": "마왕", "hp": 36, "attack": 5, "xp": 20},
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
var hp: int = 24
var max_hp: int = 24
var attack: int = 5
var level: int = 1
var xp: int = 0
var potions: int = 2
var turns: int = 0
var kills: int = 0
var messages: Array[String] = []
var damage_flash: float = 0.0
var font: SystemFont
var hud: Label
var log_label: Label
var floor_label: Label
var hint_label: Label
var overlay: Control
var overlay_title: Label
var overlay_body: Label
var start_button: Button
var restart_dialog: ConfirmationDialog


func _ready() -> void:
	font = SystemFont.new()
	font.font_names = PackedStringArray(["Malgun Gothic", "Noto Sans CJK KR", "Noto Sans KR", "Apple SD Gothic Neo", "sans-serif"])
	_build_ui()
	_show_title()
	queue_redraw()


func _build_ui() -> void:
	var ui: Control = Control.new()
	ui.name = "Interface"
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ui)
	_label(ui, "마지막 등불", Vector2(34, 22), Vector2(760, 58), 38, GOLD)
	_label(ui, "세 층 아래의 마왕을 쓰러뜨리고, 마을의 새벽을 되찾으세요.", Vector2(36, 85), Vector2(760, 36), 19, MUTED)
	floor_label = _label(ui, "", Vector2(850, 40), Vector2(382, 46), 26, TEAL)
	hud = _label(ui, "", Vector2(850, 108), Vector2(382, 225), 22)
	_label(ui, "여정의 기록", Vector2(850, 350), Vector2(380, 38), 21, GOLD)
	log_label = _label(ui, "", Vector2(850, 399), Vector2(370, 259), 17, MUTED)
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label = _label(ui, "", Vector2(36, 676), Vector2(756, 34), 18, TEAL)
	_label(ui, "방향키 / WASD  이동·공격     SPACE  대기     H  물약     R  새 게임", Vector2(36, 724), Vector2(1170, 33), 19)
	_label(ui, "● 슬라임  HP 7 / 공격 2     ◆ 해골  HP 11 / 공격 3     ▼ 마왕  HP 36 / 공격 5", Vector2(36, 770), Vector2(1170, 30), 17, MUTED)

	overlay = Control.new()
	overlay.name = "RunOverlay"
	ui.add_child(overlay)
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.01, 0.02, 0.035, 0.86)
	shade.size = Vector2(1280, 820)
	overlay.add_child(shade)
	var panel: Panel = Panel.new()
	panel.position = Vector2(310, 175)
	panel.size = Vector2(660, 470)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = INK
	style.border_color = GOLD
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	panel.add_theme_stylebox_override("panel", style)
	overlay.add_child(panel)
	overlay_title = _label(panel, "", Vector2(35, 32), Vector2(590, 60), 34, GOLD)
	overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_body = _label(panel, "", Vector2(50, 118), Vector2(560, 228), 21)
	overlay_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	start_button = Button.new()
	start_button.position = Vector2(145, 365)
	start_button.size = Vector2(370, 64)
	start_button.add_theme_font_override("font", font)
	start_button.add_theme_font_size_override("font_size", 24)
	start_button.pressed.connect(func() -> void: start_run())
	panel.add_child(start_button)

	restart_dialog = ConfirmationDialog.new()
	restart_dialog.title = "새 여정 시작"
	restart_dialog.dialog_text = "진행 중인 여정을 끝내고 새 던전을 만들까요?"
	restart_dialog.ok_button_text = "새 게임"
	restart_dialog.cancel_button_text = "계속 플레이"
	restart_dialog.add_theme_font_override("font", font)
	restart_dialog.add_theme_font_size_override("font_size", 20)
	restart_dialog.confirmed.connect(func() -> void: start_run())
	ui.add_child(restart_dialog)


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
	overlay_title.text = "마지막 등불"
	overlay_body.text = "마을의 마지막 빛을 든 용사여,\n지하 요새의 세 층을 내려가 마왕을 쓰러뜨리세요.\n\n적과 부딪히면 공격합니다.\n적을 모두 처치하면 다음 층의 계단이 열립니다.\n죽으면 모든 성장은 사라집니다."
	start_button.text = "여정 시작  ·  ENTER"
	overlay.show()
	start_button.grab_focus()


func start_run(seed_override: int = -1) -> void:
	# Explicit seeds also support reproducible native engine verification.
	if seed_override >= 0:
		run_seed = seed_override
	elif state == "title" and _command_line_seed() >= 0:
		run_seed = _command_line_seed()
	else:
		rng.randomize()
		run_seed = int(rng.randi() % 2147483647)
	rng.seed = run_seed
	state = "playing"
	floor_number = 1
	hp = 24
	max_hp = 24
	attack = 5
	level = 1
	xp = 0
	potions = 2
	turns = 0
	kills = 0
	damage_flash = 0.0
	messages.clear()
	restart_dialog.hide()
	overlay.hide()
	start_button.release_focus()
	_generate_floor()
	_log("등불을 들었다. 마왕은 지하 3층에 있다.")
	_refresh()


func _command_line_seed() -> int:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--seed="):
			var value: String = argument.trim_prefix("--seed=")
			if value.is_valid_int() and int(value) >= 0:
				return int(value)
	return -1


func _generate_floor() -> void:
	cells.resize(WIDTH * HEIGHT)
	cells.fill(0)
	enemies.clear()
	items.clear()
	var rooms: Array[Rect2i] = []
	var anchors: Array[Vector2i] = [Vector2i(1, 1), Vector2i(11, 1), Vector2i(11, 8), Vector2i(1, 8)]
	for anchor: Vector2i in anchors:
		var room: Rect2i = Rect2i(anchor, Vector2i(rng.randi_range(4, 6), rng.randi_range(3, 4)))
		rooms.append(room)
		for y: int in range(room.position.y, room.end.y):
			for x: int in range(room.position.x, room.end.x):
				cells[y * WIDTH + x] = 1
	for index: int in range(rooms.size()):
		_carve_corridor(rooms[index].get_center(), rooms[(index + 1) % rooms.size()].get_center())
	player = rooms[0].get_center()
	stairs = rooms[2].get_center()
	var species: Array[String] = []
	match floor_number:
		1: species = ["slime", "slime", "slime", "slime"]
		2: species = ["slime", "slime", "skeleton", "skeleton", "skeleton"]
		3: species = ["skeleton", "skeleton", "skeleton"]
	for kind: String in species:
		_spawn_enemy(kind, _empty_cell(5))
	if floor_number == 3:
		_spawn_enemy("boss", stairs)
	for item_kind: String in ["potion", "potion", "heart", "heart"]:
		items[_empty_cell(1)] = item_kind
	_log("%d층 · %s에 도착했다." % [floor_number, FLOOR_NAMES[floor_number - 1]])


func _carve_corridor(first: Vector2i, last: Vector2i) -> void:
	var cursor: Vector2i = first
	var horizontal_first: bool = rng.randf() < 0.5
	while cursor != last:
		cells[cursor.y * WIDTH + cursor.x] = 1
		if (horizontal_first and cursor.x != last.x) or cursor.y == last.y:
			cursor.x += int(sign(last.x - cursor.x))
		else:
			cursor.y += int(sign(last.y - cursor.y))
	cells[last.y * WIDTH + last.x] = 1


func _empty_cell(min_distance: int) -> Vector2i:
	var choices: Array[Vector2i] = []
	for y: int in range(1, HEIGHT - 1):
		for x: int in range(1, WIDTH - 1):
			var tile: Vector2i = Vector2i(x, y)
			if _walkable(tile) and tile != player and tile != stairs and _distance(tile, player) >= min_distance and _enemy_at(tile) < 0 and not items.has(tile):
				choices.append(tile)
	assert(not choices.is_empty(), "Dungeon has no free spawn cell")
	return choices[rng.randi_range(0, choices.size() - 1)]


func _spawn_enemy(kind: String, tile: Vector2i) -> void:
	var stats: Dictionary = FOE_STATS[kind]
	enemies.append({"kind": kind, "pos": tile, "hp": stats["hp"], "awake": false})


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
		_: return
	get_viewport().set_input_as_handled()


func act(direction: Vector2i) -> void:
	if state != "playing" or not (direction == Vector2i.ZERO or direction in DIRECTIONS):
		return
	var destination: Vector2i = player + direction
	if direction != Vector2i.ZERO and not _walkable(destination):
		return
	turns += 1
	var enemy_index: int = _enemy_at(destination)
	if direction != Vector2i.ZERO and enemy_index >= 0:
		_attack_enemy(enemy_index)
	elif direction != Vector2i.ZERO:
		player = destination
		_collect_item()
		if player == stairs and enemies.is_empty() and floor_number < 3:
			floor_number += 1
			hp = mini(max_hp, hp + 4)
			_generate_floor()
			_log("다음 층으로 내려가 HP 4를 회복했다.")
			_refresh()
			return
	if state == "playing":
		_enemy_turn()
	_refresh()


func drink_potion() -> void:
	if state != "playing":
		return
	if potions == 0 or hp == max_hp:
		_log("물약이 없다." if potions == 0 else "HP가 가득 차 있다.")
		_refresh()
		return
	potions -= 1
	turns += 1
	var restored: int = mini(12, max_hp - hp)
	hp += restored
	_log("물약을 마셔 HP %d를 회복했다." % restored)
	_enemy_turn()
	_refresh()


func _attack_enemy(index: int) -> void:
	var foe: Dictionary = enemies[index]
	var stats: Dictionary = FOE_STATS[foe["kind"]]
	var damage: int = attack + rng.randi_range(0, 1)
	foe["hp"] -= damage
	_log("%s에게 %d 피해." % [stats["name"], damage])
	if int(foe["hp"]) <= 0:
		enemies.remove_at(index)
		kills += 1
		xp += int(stats["xp"])
		_log("%s 처치! 경험치 +%d." % [stats["name"], stats["xp"]])
		while xp >= _xp_needed():
			xp -= _xp_needed()
			level += 1
			max_hp += 4
			attack += 2
			hp = mini(max_hp, hp + 6)
			_log("레벨 %d! 최대 HP +4, 공격 +2, HP +6." % level)
		if enemies.is_empty():
			if floor_number == 3:
				_finish_run(true)
			else:
				_log("모든 적을 처치했다. 청록색 계단이 열렸다!")


func _collect_item() -> void:
	if not items.has(player):
		return
	var kind: String = items[player]
	if kind == "potion" and potions < 5:
		potions += 1
		items.erase(player)
		_log("물약을 주웠다. 현재 %d개." % potions)
	elif kind == "heart" and hp < max_hp:
		var restored: int = mini(5, max_hp - hp)
		hp += restored
		items.erase(player)
		_log("회복 구슬로 HP %d 회복." % restored)


func _enemy_turn() -> void:
	for foe: Dictionary in enemies:
		var tile: Vector2i = foe["pos"]
		if _distance(tile, player) <= 6:
			foe["awake"] = true
		if not bool(foe["awake"]):
			continue
		if _distance(tile, player) == 1:
			var stats: Dictionary = FOE_STATS[foe["kind"]]
			hp = maxi(0, hp - int(stats["attack"]))
			damage_flash = 0.18
			_log("%s의 공격! HP -%d." % [stats["name"], stats["attack"]])
			if hp == 0:
				_finish_run(false)
				return
		else:
			foe["pos"] = _step_towards(tile, player)


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
	return 8 + (level - 1) * 4


func _log(message: String) -> void:
	messages.append(message)
	while messages.size() > 7:
		messages.pop_front()


func _finish_run(victory: bool) -> void:
	state = "won" if victory else "lost"
	overlay_title.text = "새벽이 돌아왔다" if victory else "등불이 꺼졌다"
	var ending: String = "마왕이 쓰러지고 마을에 새벽이 돌아왔습니다." if victory else "쓰러진 용사의 등불이 다음 용사를 기다립니다."
	overlay_body.text = "%s\n\n도달 층  %d / 3     레벨  %d\n행동  %d턴     처치  %d마리\n\n새 여정은 새 던전과 레벨 1에서 시작합니다." % [ending, floor_number, level, turns, kills]
	start_button.text = "새 여정  ·  R"
	overlay.show()
	start_button.grab_focus()


func _refresh() -> void:
	floor_label.text = "%d층  ·  %s" % [floor_number, FLOOR_NAMES[floor_number - 1]]
	hud.text = "HP    %d / %d\n레벨  %d    공격  %d\n경험치  %d / %d\n물약  %d / 5    남은 적  %d\n행동  %d턴\nSEED  %d" % [hp, max_hp, level, attack, xp, _xp_needed(), potions, enemies.size(), turns, run_seed]
	log_label.text = "\n".join(messages)
	if floor_number == 3:
		hint_label.text = "마왕과 남은 적을 모두 쓰러뜨리세요."
	elif enemies.is_empty():
		hint_label.text = "계단이 열렸습니다. 청록색 계단으로 이동하세요."
	else:
		hint_label.text = "적을 모두 쓰러뜨리면 계단이 열립니다."
	queue_redraw()


func _process(delta: float) -> void:
	if damage_flash > 0.0:
		damage_flash = maxf(0.0, damage_flash - delta)
		queue_redraw()


func _draw() -> void:
	draw_style_box(_card_style(), Rect2(826, 24, 424, 658))
	draw_line(Vector2(850, 335), Vector2(1225, 335), Color("2c3c51"), 1.0)
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
			if not walkable:
				draw_line(rect.position + Vector2(4, 7), rect.position + Vector2(32, 7), Color("223047"), 2)
	if floor_number < 3:
		_draw_stairs(stairs, enemies.is_empty())
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
	elif kind == "skeleton":
		draw_circle(center + Vector2(0, -3), 11, Color("e1ddcd"))
		draw_rect(Rect2(center + Vector2(-6, 6), Vector2(12, 9)), Color("c2bfaf"))
	else:
		draw_colored_polygon(PackedVector2Array([center + Vector2(-15, -12), center + Vector2(15, -12), center + Vector2(0, 16)]), Color("ed7182"))
		draw_line(center + Vector2(-11, -5), center + Vector2(-16, -18), GOLD, 4)
		draw_line(center + Vector2(11, -5), center + Vector2(16, -18), GOLD, 4)
	draw_circle(center + Vector2(-4, -2), 2.5, INK)
	draw_circle(center + Vector2(4, -2), 2.5, INK)
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
