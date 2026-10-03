extends SceneTree

const StageData = preload("res://scripts/stage_data.gd")

var failures: Array[String] = []


func _init() -> void:
	print("GRACEFUL stage verification")
	print("===========================")

	for index in range(StageData.count()):
		var stage: Dictionary = StageData.get_stage(index)
		if stage["mode"] == "place":
			_verify_place(stage)
		else:
			_verify_swap(stage)

	if failures.is_empty():
		print("")
		print("PASS: all %d stages verified." % StageData.count())
		quit(0)
	else:
		print("")
		for failure in failures:
			push_error(failure)
		print("FAIL: %d validation errors." % failures.size())
		quit(1)


func _verify_place(stage: Dictionary) -> void:
	var n: int = stage["positions"].size()
	var current: Array = []
	current.resize(n)
	current.fill(-1)
	var used: Array[bool] = []
	used.resize(n)
	used.fill(false)
	var found: Array = []

	_search_permutations(stage, current, used, 0, found)

	var expected: Array = stage["solution"]
	var ok := found.size() == 1 and found[0] == expected
	print("Stage %s PLACE solutions=%d %s" % [stage["id"], found.size(), "PASS" if ok else "FAIL"])
	if not ok:
		failures.append("Stage %s expected one solution %s, got %s" % [stage["id"], str(expected), str(found)])


func _search_permutations(stage: Dictionary, current: Array, used: Array[bool], vertex: int, found: Array) -> void:
	var n := current.size()
	if vertex == n:
		if _matches_clues(stage, current) and _is_graceful(stage, current):
			found.append(current.duplicate())
		return

	var clues: Dictionary = stage["vertex_clues"]
	if clues.has(vertex):
		var forced := int(clues[vertex])
		if not used[forced]:
			current[vertex] = forced
			used[forced] = true
			_search_permutations(stage, current, used, vertex + 1, found)
			used[forced] = false
			current[vertex] = -1
		return

	for value in range(n):
		if used[value]:
			continue
		current[vertex] = value
		used[value] = true
		_search_permutations(stage, current, used, vertex + 1, found)
		used[value] = false
		current[vertex] = -1


func _matches_clues(stage: Dictionary, values: Array) -> bool:
	for vertex in stage["vertex_clues"].keys():
		if int(values[int(vertex)]) != int(stage["vertex_clues"][vertex]):
			return false

	for edge_index in stage["edge_clues"].keys():
		var edge: Array = stage["edges"][int(edge_index)]
		var actual := abs(int(values[edge[0]]) - int(values[edge[1]]))
		if actual != int(stage["edge_clues"][edge_index]):
			return false

	return true


func _is_graceful(stage: Dictionary, values: Array) -> bool:
	var m: int = stage["edges"].size()
	var seen: Array[bool] = []
	seen.resize(m + 1)
	seen.fill(false)

	for edge in stage["edges"]:
		var d := abs(int(values[edge[0]]) - int(values[edge[1]]))
		if d <= 0 or d > m or seen[d]:
			return false
		seen[d] = true

	for d in range(1, m + 1):
		if not seen[d]:
			return false
	return true


func _verify_swap(stage: Dictionary) -> void:
	var initial: Array = stage["initial"]
	var repairs: Array = []

	for a in range(initial.size()):
		for b in range(a + 1, initial.size()):
			var candidate := initial.duplicate()
			var tmp = candidate[a]
			candidate[a] = candidate[b]
			candidate[b] = tmp
			if _is_graceful(stage, candidate):
				repairs.append([a, b, candidate])

	var expected_pair: Array = stage["repair_pair"]
	var ok := repairs.size() == 1 and repairs[0][0] == expected_pair[0] and repairs[0][1] == expected_pair[1]
	print("Stage %s SWAP repairs=%d %s" % [stage["id"], repairs.size(), "PASS" if ok else "FAIL"])
	if not ok:
		failures.append("Stage %s expected repair %s, got %s" % [stage["id"], str(expected_pair), str(repairs)])
