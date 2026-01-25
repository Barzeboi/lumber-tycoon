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
	
	match character_state:
		CharacterState.IDLE:
			if inventory["Seeds"] <= 0:
				if !closest_crate:
					_find_closest_crate()
				else:
					_change_state(CharacterState.MOVE_TO_CRATE)
					
			elif Global.chopped_trees.size() <= 0:
				_change_state(CharacterState.MOVE_TO_SPOT)
				
			elif !closest_tree:
				_find_closest_chopped_tree()
			elif closest_tree:
				_change_state(CharacterState.MOVE_TO_TREE)
		CharacterState.MOVE_TO_TREE:
			if _reached():
				_change_state(CharacterState.PLANT)
		CharacterState.MOVE_TO_CRATE:
			if _reached():
				_change_state(CharacterState.TAKE)
		CharacterState.MOVE_TO_SPOT:
			if _reached():
				_change_state(CharacterState.IDLE)
	
	_reached()
@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	match character_state:
		CharacterState.MOVE_TO_TREE, CharacterState.MOVE_TO_CRATE, CharacterState.MOVE_TO_SPOT:
			_move(target, 70)
		_:
			_move(global_position, 0)
			
func _change_state(new_state:CharacterState):
	if character_state == new_state: return
	previous_state = character_state
	_exit_state(character_state)
	character_state = new_state
	_enter_state(character_state)
	
func _exit_state(state: CharacterState):
	match state:
		CharacterState.PLANT:
			$planting_timer.stop()
		CharacterState.WATER:
			$watering_timer.stop()

func _enter_state(state: CharacterState):
	match state:
		CharacterState.IDLE:
			target = global_position
			_animation_state(character_state)
		CharacterState.MOVE_TO_TREE:
			target = closest_tree.global_position
			_animation_state(character_state)
		CharacterState.MOVE_TO_CRATE:
			target = closest_crate.global_position
			_animation_state(character_state)
		CharacterState.MOVE_TO_SPOT:
			target = wait_spot.global_position
			_animation_state(character_state)
		CharacterState.PLANT:
			_plant()
			$planting_timer.start()
			_animation_state(character_state)
		CharacterState.WATER:
			_water()
			_animation_state(character_state)
			_change_state(CharacterState.IDLE)
		CharacterState.TAKE:
			_take()
			_change_state(CharacterState.IDLE)
		
func _reached() -> bool:
	return position.distance_to(target) < 5
	
	
func _take() -> void:
	take_amount = randi() % inventory_full + 1
	inventory["Seeds"] += take_amount
	closest_crate.store["Seeds"] -= take_amount
	
func _plant() -> void:
	if closest_tree != null:
		print("plant")
		inventory["Seeds"] -= 1
		$planting_timer.start()
		
func _water():
	pass
	
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
	
func _animation_state(state: CharacterState):
	match state:
		CharacterState.IDLE:
			$idle_sprites.show()
			$run_sprites.hide()
			$doing_sprites.hide()
			$watering_sprites.hide()
			animation_player.play("IDLE")
		CharacterState.MOVE_TO_TREE,CharacterState.MOVE_TO_CRATE, CharacterState.MOVE_TO_SPOT:
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
		CharacterState.WATER:
			$watering_sprites.show()
			$run_sprites.hide()
			$idle_sprites.hide()
			$doing_sprites.hide()
			animation_player.play("WATERING")

func _on_timer_timeout() -> void:
	action_performed = false

func _on_planting_timer_timeout() -> void:
	if closest_tree != null:
		closest_tree._planted()
		
		_change_state(CharacterState.WATER)
