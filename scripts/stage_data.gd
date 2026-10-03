class_name GracefulStageData
extends RefCounted

# Normalized graph layouts. Logic uses only edges; positions are presentation data.
const TEMPLATES := {
	"P2": {
		"positions": [Vector2(0.32, 0.50), Vector2(0.68, 0.50)],
		"edges": [[0, 1]],
	},
	"P3": {
		"positions": [Vector2(0.16, 0.50), Vector2(0.50, 0.50), Vector2(0.84, 0.50)],
		"edges": [[0, 1], [1, 2]],
	},
	"P4": {
		"positions": [Vector2(0.10, 0.50), Vector2(0.37, 0.50), Vector2(0.63, 0.50), Vector2(0.90, 0.50)],
		"edges": [[0, 1], [1, 2], [2, 3]],
	},
	"P5": {
		"positions": [Vector2(0.07, 0.50), Vector2(0.285, 0.50), Vector2(0.50, 0.50), Vector2(0.715, 0.50), Vector2(0.93, 0.50)],
		"edges": [[0, 1], [1, 2], [2, 3], [3, 4]],
	},
	"T5": {
		"positions": [Vector2(0.20, 0.20), Vector2(0.45, 0.38), Vector2(0.78, 0.38), Vector2(0.45, 0.63), Vector2(0.45, 0.87)],
		"edges": [[0, 1], [1, 2], [1, 3], [3, 4]],
	},
	"STAR4": {
		"positions": [Vector2(0.50, 0.48), Vector2(0.50, 0.13), Vector2(0.18, 0.78), Vector2(0.82, 0.78)],
		"edges": [[0, 1], [0, 2], [0, 3]],
	},
	"FORK6": {
		"positions": [Vector2(0.10, 0.25), Vector2(0.35, 0.25), Vector2(0.62, 0.12), Vector2(0.55, 0.46), Vector2(0.78, 0.70), Vector2(0.32, 0.80)],
		"edges": [[0, 1], [1, 2], [1, 3], [3, 4], [3, 5]],
	},
	"Y6": {
		"positions": [Vector2(0.10, 0.30), Vector2(0.38, 0.35), Vector2(0.68, 0.15), Vector2(0.72, 0.43), Vector2(0.45, 0.62), Vector2(0.70, 0.84)],
		"edges": [[0, 1], [1, 2], [1, 3], [1, 4], [4, 5]],
	},
	"BROOM6": {
		"positions": [Vector2(0.08, 0.26), Vector2(0.32, 0.26), Vector2(0.55, 0.42), Vector2(0.84, 0.16), Vector2(0.86, 0.48), Vector2(0.70, 0.78)],
		"edges": [[0, 1], [1, 2], [2, 3], [2, 4], [2, 5]],
	},
	"BROOM7": {
		"positions": [Vector2(0.08, 0.24), Vector2(0.30, 0.24), Vector2(0.52, 0.40), Vector2(0.82, 0.14), Vector2(0.84, 0.43), Vector2(0.62, 0.66), Vector2(0.82, 0.86)],
		"edges": [[0, 1], [1, 2], [2, 3], [2, 4], [2, 5], [5, 6]],
	},
	"BRANCH7": {
		"positions": [Vector2(0.08, 0.20), Vector2(0.33, 0.27), Vector2(0.62, 0.10), Vector2(0.48, 0.49), Vector2(0.77, 0.42), Vector2(0.50, 0.72), Vector2(0.76, 0.86)],
		"edges": [[0, 1], [1, 2], [1, 3], [3, 4], [3, 5], [5, 6]],
	},
	"BRANCH8": {
		"positions": [Vector2(0.08, 0.18), Vector2(0.32, 0.26), Vector2(0.61, 0.10), Vector2(0.47, 0.48), Vector2(0.77, 0.42), Vector2(0.49, 0.69), Vector2(0.28, 0.88), Vector2(0.73, 0.88)],
		"edges": [[0, 1], [1, 2], [1, 3], [3, 4], [3, 5], [5, 6], [5, 7]],
	},
}

# Every PLACE stage was selected to have exactly one graceful labeling under its clues.
# Every SWAP stage has exactly one pair whose swap produces a graceful labeling.
const STAGES := [
	{
		"id": "001", "chapter": "DIFFERENCE", "mode": "place", "template": "P2",
		"vertex_clues": {0: 0}, "edge_clues": {}, "solution": [0, 1],
		"teaching": "Place labels. Each edge creates an absolute difference.",
	},
	{
		"id": "002", "chapter": "DIFFERENCE", "mode": "place", "template": "P3",
		"vertex_clues": {0: 0}, "edge_clues": {}, "solution": [0, 2, 1],
		"teaching": "The largest difference can only come from the two extremes.",
	},
	{
		"id": "003", "chapter": "DIFFERENCE", "mode": "place", "template": "P4",
		"vertex_clues": {0: 0}, "edge_clues": {}, "solution": [0, 3, 1, 2],
		"teaching": "Use the missing differences to continue the chain.",
	},
	{
		"id": "004", "chapter": "DIFFERENCE", "mode": "place", "template": "T5",
		"vertex_clues": {0: 0}, "edge_clues": {}, "solution": [0, 4, 1, 2, 3],
		"teaching": "A branch must create different differences on every incident edge.",
	},
	{
		"id": "005", "chapter": "DIFFERENCE", "mode": "place", "template": "P5",
		"vertex_clues": {0: 0}, "edge_clues": {}, "solution": [0, 4, 1, 3, 2],
		"teaching": "Read the whole set of remaining differences.",
	},
	{
		"id": "006", "chapter": "BRANCH", "mode": "place", "template": "STAR4",
		"vertex_clues": {1: 1, 3: 3}, "edge_clues": {}, "solution": [0, 1, 2, 3],
		"teaching": "Hub pressure: repeated differences around one center are impossible.",
	},
	{
		"id": "007", "chapter": "BRANCH", "mode": "place", "template": "FORK6",
		"vertex_clues": {0: 0, 4: 3}, "edge_clues": {}, "solution": [0, 5, 1, 2, 3, 4],
		"teaching": "Solve one branch, then let its consequences travel into the next.",
	},
	{
		"id": "008", "chapter": "BRANCH", "mode": "place", "template": "Y6",
		"vertex_clues": {0: 0, 2: 1}, "edge_clues": {}, "solution": [0, 5, 1, 2, 3, 4],
		"teaching": "The same labels feel different when the tree changes shape.",
	},
	{
		"id": "009", "chapter": "BRANCH", "mode": "place", "template": "BROOM7",
		"vertex_clues": {0: 0, 3: 2}, "edge_clues": {}, "solution": [0, 6, 1, 2, 4, 5, 3],
		"teaching": "Large differences constrain the trunk while small ones settle the twigs.",
	},
	{
		"id": "010", "chapter": "BRANCH", "mode": "place", "template": "BRANCH8",
		"vertex_clues": {0: 0, 2: 1, 7: 5}, "edge_clues": {}, "solution": [0, 7, 1, 2, 4, 6, 3, 5],
		"teaching": "PLACE fundamentals, combined.",
	},
	{
		"id": "011", "chapter": "GAPS", "mode": "place", "template": "P5",
		"vertex_clues": {0: 0}, "edge_clues": {0: 4}, "solution": [0, 4, 1, 3, 2],
		"teaching": "Blue edge badges are fixed difference clues. Now reason difference to vertex.",
	},
	{
		"id": "012", "chapter": "GAPS", "mode": "place", "template": "BROOM6",
		"vertex_clues": {3: 2}, "edge_clues": {3: 2}, "solution": [0, 5, 1, 2, 3, 4],
		"teaching": "A fixed difference has several possible label pairs. The tree removes them.",
	},
	{
		"id": "013", "chapter": "GAPS", "mode": "place", "template": "Y6",
		"vertex_clues": {0: 0}, "edge_clues": {1: 4}, "solution": [0, 5, 1, 2, 3, 4],
		"teaching": "Combine the forced maximum difference with an edge clue.",
	},
	{
		"id": "014", "chapter": "GAPS", "mode": "place", "template": "BRANCH7",
		"vertex_clues": {0: 0}, "edge_clues": {1: 5}, "solution": [0, 6, 1, 2, 5, 4, 3],
		"teaching": "Large differences can lock into a chain.",
	},
	{
		"id": "015", "chapter": "GAPS", "mode": "place", "template": "BRANCH8",
		"vertex_clues": {2: 1}, "edge_clues": {0: 7, 5: 3}, "solution": [0, 7, 1, 2, 4, 6, 3, 5],
		"teaching": "PLACE finale: vertex clues and multiple edge clues together.",
	},
	{
		"id": "016", "chapter": "BROKEN GRACE", "mode": "swap", "template": "P5",
		"vertex_clues": {}, "edge_clues": {}, "initial": [3, 4, 1, 0, 2],
		"solution": [0, 4, 1, 3, 2], "repair_pair": [0, 3],
		"teaching": "All labels are present. Swap one pair to repair the missing difference.",
	},
	{
		"id": "017", "chapter": "BROKEN GRACE", "mode": "swap", "template": "T5",
		"vertex_clues": {}, "edge_clues": {}, "initial": [0, 4, 2, 1, 3],
		"solution": [0, 4, 1, 2, 3], "repair_pair": [2, 3],
		"teaching": "Repeated differences point toward the damaged region.",
	},
	{
		"id": "018", "chapter": "BROKEN GRACE", "mode": "swap", "template": "FORK6",
		"vertex_clues": {}, "edge_clues": {}, "initial": [0, 4, 1, 2, 3, 5],
		"solution": [0, 5, 1, 2, 3, 4], "repair_pair": [1, 5],
		"teaching": "Find the missing maximum difference.",
	},
	{
		"id": "019", "chapter": "BROKEN GRACE", "mode": "swap", "template": "BRANCH7",
		"vertex_clues": {}, "edge_clues": {}, "initial": [0, 6, 1, 2, 4, 5, 3],
		"solution": [0, 6, 1, 2, 5, 4, 3], "repair_pair": [4, 5],
		"teaching": "Diagnose a seven-vertex branch from its difference signature.",
	},
	{
		"id": "020", "chapter": "BROKEN GRACE", "mode": "swap", "template": "BRANCH8",
		"vertex_clues": {}, "edge_clues": {}, "initial": [0, 7, 1, 6, 4, 2, 3, 5],
		"solution": [0, 7, 1, 2, 4, 6, 3, 5], "repair_pair": [3, 5],
		"teaching": "Final diagnosis: one swap restores all seven differences.",
	},
]

static func get_stage(index: int) -> Dictionary:
	var stage: Dictionary = STAGES[index].duplicate(true)
	var template: Dictionary = TEMPLATES[String(stage["template"])]
	stage["positions"] = template["positions"]
	stage["edges"] = template["edges"]
	return stage

static func count() -> int:
	return STAGES.size()
