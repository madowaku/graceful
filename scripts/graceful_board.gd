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
	var point: Vector2 = Vector2.ZERO
	var trigger: bool = false
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		point = event.position
		trigger = true
	elif event is InputEventScreenTouch and event.pressed:
		point = event.position
		trigger = true

	if not trigger or stage.is_empty():
		return

	var radius: float = _node_radius()
	var positions: Array = stage["positions"]
	var best: int = -1
	var best_distance: float = INF
	for i in range(positions.size()):
		var d: float = point.distance_to(_to_canvas(positions[i] as Vector2))
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

	var font: Font = get_theme_default_font()
	var edges: Array = stage["edges"]
	var positions: Array = stage["positions"]
	var counts: Dictionary = _difference_counts()
	var edge_clues: Dictionary = stage.get("edge_clues", {})

	for edge_index in range(edges.size()):
		var edge: Array = edges[edge_index]
		var a: int = edge[0]
		var b: int = edge[1]
		var p1: Vector2 = _to_canvas(positions[a] as Vector2)
		var p2: Vector2 = _to_canvas(positions[b] as Vector2)
		var current_diff: int = _edge_difference(a, b)
		var is_duplicate: bool = current_diff > 0 and int(counts.get(current_diff, 0)) > 1
		var is_traced: bool = trace_enabled and trace_vertex >= 0 and (a == trace_vertex or b == trace_vertex)
		var has_fixed_clue: bool = edge_clues.has(edge_index)

		var line_color: Color = Color("#718092")
		var line_width: float = 4.0
		if current_diff > 0:
			line_color = GOLD_SOFT
		if is_duplicate:
			line_color = RED
			line_width = 6.0
		if is_traced:
			line_color = BLUE
			line_width = 7.0

		draw_line(p1, p2, line_color, line_width, true)

		var badge_text: String = ""
		var badge_color: Color = line_color
		if has_fixed_clue:
			badge_text = str(edge_clues[edge_index])
			badge_color = BLUE
		elif current_diff > 0:
			badge_text = str(current_diff)

		if not badge_text.is_empty():
			var mid: Vector2 = p1.lerp(p2, 0.5)
			_draw_badge(font, mid, badge_text, badge_color, has_fixed_clue)

	var vertex_clues: Dictionary = stage.get("vertex_clues", {})
	var radius := _node_radius()
	for i in range(positions.size()):
		var center: Vector2 = _to_canvas(positions[i] as Vector2)
		var fixed: bool = vertex_clues.has(i)
		var traced: bool = trace_enabled and i == trace_vertex
		var selected: bool = selected_vertex == i

		var rim: Color = GOLD_SOFT
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

		var value: int = -1
		if i < assignments.size():
			value = int(assignments[i])

		if value >= 0:
			var text: String = str(value)
			var font_size: int = int(radius * 1.05)
			var text_width: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
			draw_string(font, center + Vector2(-text_width * 0.5, font_size * 0.34), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, PAPER)
		else:
			draw_circle(center, radius * 0.18, Color("#25364A"))
			draw_arc(center, radius * 0.45, 0.0, TAU, 32, Color("#42566E"), 1.5, true)


func _draw_badge(font: Font, center: Vector2, text: String, color: Color, fixed: bool) -> void:
	var rect: Rect2 = Rect2(center - Vector2(19, 16), Vector2(38, 32))
	draw_rect(rect, Color(INK, 0.96), true)
	draw_rect(rect, color, false, 2.2 if fixed else 1.4)
	var font_size: int = 18
	var w: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	draw_string(font, center + Vector2(-w * 0.5, 6.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, PAPER)


func _difference_counts() -> Dictionary:
	var counts: Dictionary = {}
	if stage.is_empty():
		return counts
	var edges: Array = stage["edges"] as Array
	for edge_variant in edges:
		var edge: Array = edge_variant as Array
		var d: int = _edge_difference(int(edge[0]), int(edge[1]))
		if d > 0:
			counts[d] = counts.get(d, 0) + 1
	return counts


func _edge_difference(a: int, b: int) -> int:
	if a >= assignments.size() or b >= assignments.size():
		return -1
	var va: int = int(assignments[a])
	var vb: int = int(assignments[b])
	if va < 0 or vb < 0:
		return -1
	return absi(va - vb)


func _to_canvas(normalized: Vector2) -> Vector2:
	var pad_x: float = maxf(34.0, size.x * 0.08)
	var pad_y: float = maxf(30.0, size.y * 0.07)
	return Vector2(
		lerp(pad_x, size.x - pad_x, normalized.x),
		lerp(pad_y, size.y - pad_y, normalized.y)
	)


func _node_radius() -> float:
	return clampf(minf(size.x, size.y) * 0.062, 25.0, 43.0)
