class_name GracefulBoard
extends Control

signal vertex_pressed(index: int)

const GOLD := Color("#F4D58D")
const GOLD_SOFT := Color("#9F8652")
const BLUE := Color("#79C8FF")
const BLUE_SOFT := Color("#315A78")
const RED := Color("#FF7B86")
const INK := Color("#08111E")
const PAPER := Color("#F4F0E8")
const DIM := Color("#344253")

var stage: Dictionary = {}
var assignments: Array = []
var trace_enabled := false
var trace_vertex := -1
var selected_vertex := -1


func configure(new_stage: Dictionary, new_assignments: Array) -> void:
	stage = new_stage
	assignments = new_assignments
	trace_vertex = -1
	selected_vertex = -1
	queue_redraw()


func set_assignments(new_assignments: Array) -> void:
	assignments = new_assignments
	queue_redraw()


func set_trace(enabled: bool, vertex: int = -1) -> void:
	trace_enabled = enabled
	if vertex >= 0:
		trace_vertex = vertex
	elif not enabled:
		trace_vertex = -1
	queue_redraw()


func set_selected_vertex(vertex: int) -> void:
	selected_vertex = vertex
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _gui_input(event: InputEvent) -> void:
	var point := Vector2.ZERO
	var trigger := false
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		point = event.position
		trigger = true
	elif event is InputEventScreenTouch and event.pressed:
		point = event.position
		trigger = true

	if not trigger or stage.is_empty():
		return

	var radius := _node_radius()
	var positions: Array = stage["positions"]
	var best := -1
	var best_distance := INF
	for i in range(positions.size()):
		var d := point.distance_to(_to_canvas(positions[i]))
		if d <= radius * 1.25 and d < best_distance:
			best = i
			best_distance = d

	if best >= 0:
		if trace_enabled:
			trace_vertex = best
			queue_redraw()
		else:
			vertex_pressed.emit(best)
		accept_event()


func _draw() -> void:
	if stage.is_empty():
		return

	var font := get_theme_default_font()
	var edges: Array = stage["edges"]
	var positions: Array = stage["positions"]
	var counts := _difference_counts()
	var edge_clues: Dictionary = stage.get("edge_clues", {})

	for edge_index in range(edges.size()):
		var edge: Array = edges[edge_index]
		var a: int = edge[0]
		var b: int = edge[1]
		var p1 := _to_canvas(positions[a])
		var p2 := _to_canvas(positions[b])
		var current_diff := _edge_difference(a, b)
		var is_duplicate := current_diff > 0 and counts.get(current_diff, 0) > 1
		var is_traced := trace_enabled and trace_vertex >= 0 and (a == trace_vertex or b == trace_vertex)
		var has_fixed_clue := edge_clues.has(edge_index)

		var line_color := Color("#718092")
		var line_width := 4.0
		if current_diff > 0:
			line_color = GOLD_SOFT
		if is_duplicate:
			line_color = RED
			line_width = 6.0
		if is_traced:
			line_color = BLUE
			line_width = 7.0

		draw_line(p1, p2, line_color, line_width, true)

		var badge_text := ""
		var badge_color := line_color
		if has_fixed_clue:
			badge_text = str(edge_clues[edge_index])
			badge_color = BLUE
		elif current_diff > 0:
			badge_text = str(current_diff)

		if not badge_text.is_empty():
			var mid := p1.lerp(p2, 0.5)
			_draw_badge(font, mid, badge_text, badge_color, has_fixed_clue)

	var vertex_clues: Dictionary = stage.get("vertex_clues", {})
	var radius := _node_radius()
	for i in range(positions.size()):
		var center := _to_canvas(positions[i])
		var fixed := vertex_clues.has(i)
		var traced := trace_enabled and i == trace_vertex
		var selected := selected_vertex == i

		var rim := GOLD_SOFT
		if fixed:
			rim = GOLD
		if traced:
			rim = BLUE
		if selected:
			rim = BLUE

		if traced or selected:
			draw_circle(center, radius + 10.0, Color(rim, 0.14))
			draw_arc(center, radius + 7.0, 0.0, TAU, 48, Color(rim, 0.72), 3.0, true)

		draw_circle(center, radius, Color("#0B1625"))
		draw_arc(center, radius, 0.0, TAU, 48, rim, 3.0 if fixed else 2.0, true)

		var value := -1
		if i < assignments.size():
			value = int(assignments[i])

		if value >= 0:
			var text := str(value)
			var font_size := int(radius * 1.05)
			var text_width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
			draw_string(font, center + Vector2(-text_width * 0.5, font_size * 0.34), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, PAPER)
		else:
			draw_circle(center, radius * 0.18, Color("#25364A"))
			draw_arc(center, radius * 0.45, 0.0, TAU, 32, Color("#42566E"), 1.5, true)


func _draw_badge(font: Font, center: Vector2, text: String, color: Color, fixed: bool) -> void:
	var rect := Rect2(center - Vector2(19, 16), Vector2(38, 32))
	draw_rect(rect, Color(INK, 0.96), true)
	draw_rect(rect, color, false, 2.2 if fixed else 1.4)
	var font_size := 18
	var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	draw_string(font, center + Vector2(-w * 0.5, 6.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, PAPER)


func _difference_counts() -> Dictionary:
	var counts := {}
	if stage.is_empty():
		return counts
	for edge in stage["edges"]:
		var d := _edge_difference(edge[0], edge[1])
		if d > 0:
			counts[d] = counts.get(d, 0) + 1
	return counts


func _edge_difference(a: int, b: int) -> int:
	if a >= assignments.size() or b >= assignments.size():
		return -1
	var va := int(assignments[a])
	var vb := int(assignments[b])
	if va < 0 or vb < 0:
		return -1
	return abs(va - vb)


func _to_canvas(normalized: Vector2) -> Vector2:
	var pad_x := max(34.0, size.x * 0.08)
	var pad_y := max(30.0, size.y * 0.07)
	return Vector2(
		lerp(pad_x, size.x - pad_x, normalized.x),
		lerp(pad_y, size.y - pad_y, normalized.y)
	)


func _node_radius() -> float:
	return clamp(min(size.x, size.y) * 0.062, 25.0, 43.0)
