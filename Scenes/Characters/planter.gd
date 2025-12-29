extends Character

var inventory: Dictionary = {"Seeds": 0}
var closest

func _ready():
	pass
	
func _process(delta: float) -> void:
	navigation_agent.target_position = target
	
func _physics_process(delta: float) -> void:
	match character_state:
		CharacterState.IDLE:
			_move(target, 0)
		CharacterState.RUN:
			_move(target, 70)
		CharacterState.PLANT:
			_move(target, 0)
	
func _find_closest_chopped_tree():
	var current_distance = 999999
	for tree in Global.chopped_trees:
		if Global.chopped_trees.size() > 0:
			var tree_distance = self.global_position.distance_to(tree.global_position)
			if tree_distance < current_distance:
				current_distance = tree_distance
				closest_tree = tree
	return closest_tree
	
