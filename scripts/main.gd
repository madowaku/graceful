extends Control

const StageData = preload("res://scripts/stage_data.gd")
const GracefulBoardScript = preload("res://scripts/graceful_board.gd")

const BG := Color("#06101D")
const PANEL := Color("#0C1827")
const PANEL_2 := Color("#101E30")
const GOLD := Color("#F4D58D")
const GOLD_DIM := Color("#7E6B48")
const BLUE := Color("#79C8FF")
const RED := Color("#FF7B86")
const TEXT := Color("#F3F0E8")
const MUTED := Color("#8B9AAF")

var stage_index := 0
var stage: Dictionary = {}
var assignments: Array = []
var history: Array = []
var selected_label := -1
var selected_swap_vertex := -1
var trace_enabled := false
var swap_spent := false
var completed: Array = []

var board: GracefulBoard
var title_label: Label
var stage_label: Label
var chapter_label: Label
var teaching_label: Label
var status_label: Label
var differences_row: HBoxContainer
var tray_row: HBoxContainer
var trace_button: Button
var next_button: Button
var prev_button: Button


func _ready() -> void:
	_load_progress()
	_build_ui()
	_load_stage(0)


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var glow_top := ColorRect.new()
	glow_top.color = Color("#0B2640", 0.28)
	glow_top.anchor_right = 1.0
	glow_top.offset_bottom = 230.0
	add_child(glow_top)

	var safe := MarginContainer.new()
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe.add_theme_constant_override("margin_left", 18)
	safe.add_theme_constant_override("margin_right", 18)
	safe.add_theme_constant_override("margin_top", 18)
	safe.add_theme_constant_override("margin_bottom", 18)
	add_child(safe)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	safe.add_child(column)

	var header := HBoxContainer.new()
	header.custom_minimum_size.y = 76
	header.add_theme_constant_override("separation", 10)
	column.add_child(header)

	prev_button = _button("‹", 28)
	prev_button.custom_minimum_size = Vector2(56, 56)
	prev_button.pressed.connect(_prev_stage)
	header.add_child(prev_button)

	var header_center := VBoxContainer.new()
	header_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_center.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_child(header_center)

	title_label = Label.new()
	title_label.text = "G R A C E F U L"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", TEXT)
	header_center.add_child(title_label)

	stage_label = Label.new()
	stage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stage_label.add_theme_font_size_override("font_size", 15)
	stage_label.add_theme_color_override("font_color", GOLD)
	header_center.add_child(stage_label)

	next_button = _button("›", 28)
	next_button.custom_minimum_size = Vector2(56, 56)
	next_button.pressed.connect(_next_stage)
	header.add_child(next_button)

	var differences_panel := PanelContainer.new()
	differences_panel.custom_minimum_size.y = 108
	differences_panel.add_theme_stylebox_override("panel", _panel_style(PANEL, 18, Color("#31465D")))
	column.add_child(differences_panel)

	var diff_column := VBoxContainer.new()
	diff_column.add_theme_constant_override("separation", 4)
	differences_panel.add_child(diff_column)

	var diff_title := Label.new()
	diff_title.text = "D I F F E R E N C E S"
	diff_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	diff_title.add_theme_font_size_override("font_size", 14)
	diff_title.add_theme_color_override("font_color", MUTED)
	diff_column.add_child(diff_title)

	differences_row = HBoxContainer.new()
	differences_row.alignment = BoxContainer.ALIGNMENT_CENTER
	differences_row.add_theme_constant_override("separation", 5)
	diff_column.add_child(differences_row)

	var board_panel := PanelContainer.new()
	board_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board_panel.add_theme_stylebox_override("panel", _panel_style(Color("#071321", 0.72), 24, Color("#1B334B")))
	column.add_child(board_panel)

	board = GracefulBoardScript.new()
	board.custom_minimum_size = Vector2(0, 320)
	board.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board.vertex_pressed.connect(_on_vertex_pressed)
	board_panel.add_child(board)

	var controls_panel := PanelContainer.new()
	controls_panel.custom_minimum_size.y = 176
	controls_panel.add_theme_stylebox_override("panel", _panel_style(PANEL, 22, Color("#2B4057")))
	column.add_child(controls_panel)

	var controls := VBoxContainer.new()
	controls.add_theme_constant_override("separation", 10)
	controls_panel.add_child(controls)

	tray_row = HBoxContainer.new()
	tray_row.alignment = BoxContainer.ALIGNMENT_CENTER
	tray_row.add_theme_constant_override("separation", 4)
	controls.add_child(tray_row)

	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 8)
	controls.add_child(action_row)

	var undo_button := _button("↶  UNDO", 16)
	undo_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	undo_button.pressed.connect(_undo)
	action_row.add_child(undo_button)

	var reset_button := _button("⟳  RESET", 16)
	reset_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reset_button.pressed.connect(_reset_stage)
	action_row.add_child(reset_button)

	trace_button = _button("TRACE", 16)
	trace_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	trace_button.pressed.connect(_toggle_trace)
	action_row.add_child(trace_button)

	chapter_label = Label.new()
	chapter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chapter_label.add_theme_font_size_override("font_size", 13)
	chapter_label.add_theme_color_override("font_color", BLUE)
	controls.add_child(chapter_label)

	teaching_label = Label.new()
	teaching_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	teaching_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	teaching_label.add_theme_font_size_override("font_size", 14)
	teaching_label.add_theme_color_override("font_color", MUTED)
	controls.add_child(teaching_label)

	status_label = Label.new()
	status_label.text = "すべての差を1回ずつ作ろう"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.custom_minimum_size.y = 28
	status_label.add_theme_font_size_override("font_size", 15)
	status_label.add_theme_color_override("font_color", TEXT)
	column.add_child(status_label)


func _load_stage(index: int) -> void:
	stage_index = clampi(index, 0, StageData.count() - 1)
	stage = StageData.get_stage(stage_index)
	history.clear()
	selected_label = -1
	selected_swap_vertex = -1
	trace_enabled = false
	swap_spent = false

	var n: int = (stage["positions"] as Array).size()
	if stage["mode"] == "swap":
		assignments = stage["initial"].duplicate()
	else:
		assignments.resize(n)
		assignments.fill(-1)
		for vertex in stage["vertex_clues"].keys():
			assignments[int(vertex)] = int(stage["vertex_clues"][vertex])

	stage_label.text = "STAGE %s" % stage["id"]
	chapter_label.text = stage["chapter"]
	teaching_label.text = stage["teaching"]
	status_label.text = "すべての差を1回ずつ作ろう" if stage["mode"] == "place" else "1組だけ入れ替えて、GRACEFULに戻そう"
	trace_button.text = "TRACE"
	board.configure(stage, assignments)
	_refresh_ui()


func _refresh_ui() -> void:
	board.set_assignments(assignments)
	board.set_selected_vertex(selected_swap_vertex)
	_rebuild_differences()
	_rebuild_tray()

	prev_button.disabled = stage_index <= 0
	var unlocked := _highest_unlocked()
	next_button.disabled = stage_index >= StageData.count() - 1 or (stage_index + 1 > unlocked and not _is_solved())


func _rebuild_differences() -> void:
	for child in differences_row.get_children():
		child.queue_free()

	var counts := _difference_counts()
	var max_difference: int = (stage["edges"] as Array).size()
	for d in range(1, max_difference + 1):
		var cell := VBoxContainer.new()
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.alignment = BoxContainer.ALIGNMENT_CENTER

		var number := Label.new()
		number.text = str(d)
		number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		number.add_theme_font_size_override("font_size", 16)
		number.add_theme_color_override("font_color", TEXT)
		cell.add_child(number)

		var indicator := Label.new()
		indicator.text = "●"
		indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		indicator.add_theme_font_size_override("font_size", 24)
		var count := int(counts.get(d, 0))
		var color := Color("#344253")
		if count == 1:
			color = GOLD
		elif count > 1:
			color = RED
		indicator.add_theme_color_override("font_color", color)
		cell.add_child(indicator)
		differences_row.add_child(cell)


func _rebuild_tray() -> void:
	for child in tray_row.get_children():
		child.queue_free()

	var n := assignments.size()
	if stage["mode"] == "swap":
		var hint := Label.new()
		hint.text = "UNDO OR RESET" if swap_spent and not _is_solved() else "TAP TWO NODES TO SWAP"
		hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hint.add_theme_font_size_override("font_size", 16)
		hint.add_theme_color_override("font_color", GOLD)
		tray_row.add_child(hint)
		return

	for label_value in range(n):
		var button := _button(str(label_value), 20)
		button.custom_minimum_size = Vector2(34, 42)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.disabled = assignments.has(label_value)
		if selected_label == label_value:
			button.add_theme_stylebox_override("normal", _panel_style(Color("#173552"), 18, BLUE, 2))
		button.pressed.connect(_select_label.bind(label_value))
		tray_row.add_child(button)


func _select_label(value: int) -> void:
	if assignments.has(value):
		return
	selected_label = -1 if selected_label == value else value
	_rebuild_tray()


func _on_vertex_pressed(index: int) -> void:
	if trace_enabled:
		return

	if stage["mode"] == "swap":
		_handle_swap_vertex(index)
		return

	if stage["vertex_clues"].has(index):
		return

	if selected_label >= 0:
		_push_history()
		assignments[index] = selected_label
		selected_label = -1
	elif assignments[index] >= 0:
		_push_history()
		assignments[index] = -1
	else:
		return

	_after_move()


func _handle_swap_vertex(index: int) -> void:
	if swap_spent:
		return

	if selected_swap_vertex < 0:
		selected_swap_vertex = index
		board.set_selected_vertex(index)
		return

	if selected_swap_vertex == index:
		selected_swap_vertex = -1
		board.set_selected_vertex(-1)
		return

	_push_history()
	var tmp: Variant = assignments[selected_swap_vertex]
	assignments[selected_swap_vertex] = assignments[index]
	assignments[index] = tmp
	selected_swap_vertex = -1
	swap_spent = true
	_after_move()


func _after_move() -> void:
	board.set_selected_vertex(-1)
	_refresh_ui()

	if _is_solved():
		_mark_completed(stage_index)
		status_label.text = "✦  G R A C E F U L  ✦"
		status_label.add_theme_color_override("font_color", GOLD)
		next_button.disabled = stage_index >= StageData.count() - 1
		_play_clear_pulse()
	else:
		status_label.add_theme_color_override("font_color", TEXT)
		if stage["mode"] == "swap" and swap_spent:
			status_label.text = "まだGRACEFULじゃない。UNDOかRESETでもう一度。"


func _is_solved() -> bool:
	if assignments.has(-1):
		return false

	var counts := _difference_counts()
	var m: int = (stage["edges"] as Array).size()
	for d in range(1, m + 1):
		if int(counts.get(d, 0)) != 1:
			return false

	for edge_index in stage["edge_clues"].keys():
		var edge: Array = stage["edges"][int(edge_index)]
		if abs(int(assignments[edge[0]]) - int(assignments[edge[1]])) != int(stage["edge_clues"][edge_index]):
			return false

	return true


func _difference_counts() -> Dictionary:
	var counts := {}
	for edge in stage["edges"]:
		var a := int(assignments[edge[0]])
		var b := int(assignments[edge[1]])
		if a < 0 or b < 0:
			continue
		var d: int = abs(int(a - b))
		counts[d] = counts.get(d, 0) + 1
	return counts


func _push_history() -> void:
	history.append(assignments.duplicate())
	if history.size() > 64:
		history.pop_front()


func _undo() -> void:
	if history.is_empty():
		return
	assignments = history.pop_back()
	selected_label = -1
	selected_swap_vertex = -1
	if stage["mode"] == "swap":
		swap_spent = false
		status_label.text = "1組だけ入れ替えて、GRACEFULに戻そう"
	else:
		status_label.text = "すべての差を1回ずつ作ろう"
	status_label.add_theme_color_override("font_color", TEXT)
	_refresh_ui()


func _reset_stage() -> void:
	_load_stage(stage_index)


func _toggle_trace() -> void:
	trace_enabled = not trace_enabled
	trace_button.text = "TRACE ON" if trace_enabled else "TRACE"
	trace_button.add_theme_color_override("font_color", BLUE if trace_enabled else TEXT)
	board.set_trace(trace_enabled)


func _prev_stage() -> void:
	if stage_index > 0:
		_load_stage(stage_index - 1)


func _next_stage() -> void:
	if stage_index < StageData.count() - 1 and (stage_index + 1 <= _highest_unlocked() or _is_solved()):
		_load_stage(stage_index + 1)


func _play_clear_pulse() -> void:
	var tween := create_tween()
	tween.tween_property(board, "modulate", Color(1.15, 1.08, 0.86, 1.0), 0.16)
	tween.tween_property(board, "modulate", Color.WHITE, 0.42)


func _button(text_value: String, font_size: int) -> Button:
	var b := Button.new()
	b.text = text_value
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", font_size)
	b.add_theme_color_override("font_color", TEXT)
	b.add_theme_color_override("font_disabled_color", Color(MUTED, 0.45))
	b.add_theme_stylebox_override("normal", _panel_style(PANEL_2, 16, Color("#344B63")))
	b.add_theme_stylebox_override("hover", _panel_style(Color("#142A42"), 16, BLUE))
	b.add_theme_stylebox_override("pressed", _panel_style(Color("#173552"), 16, BLUE, 2))
	b.add_theme_stylebox_override("disabled", _panel_style(Color("#0A1320"), 16, Color("#1B2939")))
	return b


func _panel_style(color: Color, radius: int, border_color: Color, border_width: int = 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.border_color = border_color
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 9
	style.content_margin_bottom = 9
	return style


func _load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://progress.cfg") == OK:
		completed = cfg.get_value("progress", "completed", [])
	else:
		completed = []


func _mark_completed(index: int) -> void:
	if not completed.has(index):
		completed.append(index)
		completed.sort()
		var cfg := ConfigFile.new()
		cfg.set_value("progress", "completed", completed)
		cfg.save("user://progress.cfg")


func _highest_unlocked() -> int:
	var highest := 0
	for i in completed:
		highest = maxi(highest, int(i) + 1)
	return mini(highest, StageData.count() - 1)
