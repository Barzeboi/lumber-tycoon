extends Character

var inventory: Dictionary = {"Seeds": 0}
var take_amount: int

func _ready():
	pass
	
func _process(delta: float) -> void:
	navigation_agent.target_position = target
	
	if is_moving == true:
		character_state = CharacterState.RUN
	if is_moving == false and target == closest_crate.global_position:
		await get_tree().process_frame
		_take()
	
	if closest_tree != null:
		if inventory["Seeds"] < 1:
			target = closest_crate.global_position
		if inventory["Seeds"] >= 1:
			target = closest_tree.global_position
	if closest_tree == null:
		if Global.chopped_trees.size() > 1:
			_find_closest_chopped_tree()
		if Global.chopped_trees.size() < 1:
			target = wait_spot.global_position
			
	if closest_crate == null:
		_find_closest_crate()
			
	
func _physics_process(delta: float) -> void:
	match character_state:
		CharacterState.IDLE:
			_move(target, 0)
		CharacterState.RUN:
			_move(target, 70)
		CharacterState.PLANT:
			_move(target, 0)
			
	if self.position.distance_to(target) < 1:
		_reached()
	else:
		is_moving = true
		
func _reached():
	is_moving = false
	
func _take():
	take_amount = randi() % closest_crate.store["Seeds"] + 1
	inventory["Seeds"] += take_amount
	closest_crate.store["Seeds"] -= take_amount
	
	
func _find_closest_chopped_tree():
	var current_distance = 999999
	if Global.chopped_trees.size() > 0:
		for tree in Global.chopped_trees:
				var tree_distance = self.global_position.distance_to(tree.global_position)
				if tree_distance < current_distance:
					current_distance = tree_distance
					closest_tree = tree
	return closest_tree
	
func _find_closest_crate():
	var current_distance = 999999
	closest_crate = null
	for crate in Global.crates:
		if Global.crates.size() > 0:
			if crate.state == crate.CrateState.FULL:
				continue
			if crate.store["Seeds"] < 0:
				continue
			var crate_distance = self.global_position.distance_to(crate.global_position)
			if crate_distance < current_distance:
				current_distance = crate_distance
				closest_crate = crate
	return closest_crate
	
func _character_state():
	match character_state:
		CharacterState.IDLE:
			$idle_animation.visible = true
			$hair_idle.visible = true
			$arm_animation.visible = true
		CharacterState.RUN:
			$run_animation.visible = true
			$hair_run.visible = true
			$run_arm_animation.visible = true
		CharacterState.PLANT:
			pass
		CharacterState.WATER:
			pass
