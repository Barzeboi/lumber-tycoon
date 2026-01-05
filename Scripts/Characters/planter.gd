extends Character

var inventory: Dictionary = {"Seeds": 0}
var take_amount: int
var inventory_full = 10

func _ready():
	pass
	
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	navigation_agent.target_position = target
	#print($planting_timer.time_left)
	
	if is_moving == true:
		character_state = CharacterState.RUN
	elif is_moving == false and target == wait_spot.global_position:
		await get_tree().process_frame
		character_state = CharacterState.IDLE
	elif target == closest_crate.global_position and self.position.distance_to(target) < 1:
		character_state = CharacterState.TAKE
	if closest_tree != null:
		if inventory["Seeds"] > 0:
			if target == closest_tree.global_position and self.position.distance_to(target) < 1 and is_moving == false:
				character_state = CharacterState.PLANT
	
	if closest_tree != null:
		if inventory["Seeds"] < 1:
			target = closest_crate.global_position
		if inventory["Seeds"] >= 1:
			target = closest_tree.global_position
	if closest_tree == null:
		if Global.chopped_trees.size() >= 1:
			_find_closest_chopped_tree()
		elif Global.chopped_trees.size() < 1 and Global.planted_trees.size() < 1:
			target = wait_spot.global_position
			
	if closest_crate == null:
		_find_closest_crate()
	
	if closest_crate != null:
		if closest_crate.store["Seeds"] < 1:
				target = wait_spot.global_position
	
	_character_state()
	if closest_tree != null:
		_tree_state()
		
	
@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	match character_state:
		CharacterState.IDLE:
			_move(target, 0)
		CharacterState.RUN:
			_move(target, 70)
		CharacterState.PLANT:
			_move(target, 0)
			
	if self.position.distance_to(target) <= 1:
		_reached()
	else:
		is_moving = true
		
func _reached():
	is_moving = false
	
func _take():
	take_amount = randi() % inventory_full + 1
	inventory["Seeds"] += take_amount
	closest_crate.store["Seeds"] -= take_amount
	
func _plant():
	if closest_tree != null:
		print("plant")
		inventory["Seeds"] -= 1
		action_performed = true
		$Timer.start()
		$planting_timer.start()
	
	
func _find_closest_chopped_tree():
	var current_distance = 999999
	if Global.chopped_trees.size() > 0:
		for tree in Global.chopped_trees:
			if tree.state == tree.TreeState.PLANTED:
				continue
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
			$idle_sprites.show()
			$run_sprites.hide()
			$doing_sprites.hide()
			$watering_sprites.hide()
			animation_player.play("IDLE")
		CharacterState.RUN:
			$run_sprites.show()
			$idle_sprites.hide()
			$doing_sprites.hide()
			$watering_sprites.hide()
			animation_player.play("RUN")
		CharacterState.PLANT:
			$doing_sprites.show()
			$run_sprites.hide()
			$idle_sprites.hide()
			$watering_sprites.hide()
			animation_player.play("DOING")
			if closest_tree != null:
				if closest_tree.state == closest_tree.TreeState.CHOPPED:
					if action_performed == false:
						if animation_player.animation_finished:
							_plant()
			
		CharacterState.WATER:
			$watering_sprites.show()
			$run_sprites.hide()
			$idle_sprites.hide()
			$doing_sprites.hide()
			animation_player.play("WATERING")
		CharacterState.TAKE:
			_take()

func _on_timer_timeout() -> void:
	action_performed = false
	
func _tree_state():
	match closest_tree.state:
		closest_tree.TreeState.PLANTED:
			closest_tree = null


func _on_planting_timer_timeout() -> void:
	if closest_tree != null:
		closest_tree._planted()
