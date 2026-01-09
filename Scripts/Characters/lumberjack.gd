extends Character

var inventory_full = 10
var inventory: Dictionary = {"Lumber": 0}
var currentspeed

func _ready() -> void:
	pass
	
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	navigation_agent.target_position = target
	#print(name)

	$Label.text = str(inventory["Lumber"])
	
	match character_state:
		CharacterState.IDLE:
			if inventory["Lumber"] >= inventory_full:
				if closest_crate == null:
					_find_closest_crate()
				if closest_crate:
					_change_state(CharacterState.MOVE_TO_CRATE)
			
			elif closest_tree == null:
				_find_closest_tree()
			elif closest_tree:
				_change_state(CharacterState.MOVE_TO_TREE)
			
			else:
				_change_state(CharacterState.MOVE_TO_SPOT)
		CharacterState.MOVE_TO_TREE:
			if _reached():
				_change_state(CharacterState.CHOP)
		CharacterState.CHOP:
			if closest_tree.health <= 0:
				closest_tree._planted()
				_change_state(CharacterState.IDLE)
		CharacterState.MOVE_TO_CRATE:
			if _reached():
				_change_state(CharacterState.DROP)
				
	_animation_state(character_state)
	
	if target.x < global_position.x:
		$Idle_Sprites.flip_h = true
		$Run_sprites.flip_h = true
		$Chop_Sprites.flip_h = true
		$Carry_Sprites.flip_h = true
	elif target.x > global_position.x:
		$Idle_Sprites.flip_h = false
		$Run_sprites.flip_h = false
		$Chop_Sprites.flip_h = false
		$Carry_Sprites.flip_h = false
		
	#_character_state()
	#if closest_tree != null:
		#_tree_state()
	
@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	match character_state:
		CharacterState.MOVE_TO_TREE:
			_move(target, 70)
		CharacterState.MOVE_TO_CRATE:
			_move(target, 50)
		CharacterState.MOVE_TO_SPOT:
			_move(target, 70)
		_:
			_move(global_position, 0)
	if self.position.distance_to(target) <= 1:
		_reached()


	
# (10/26/25) Idk why, but removing the "is_moving" line in the "_reached" function
# although outwardly redundant, causes the character to behave oddly while trying to stop
func _reached():
	return position.distance_to(target) < 1

func _change_state(new_state: CharacterState):
	if character_state == new_state: return
	_exit_state(character_state)
	character_state = new_state
	_enter_state(character_state)
	print(character_state)
	
func _exit_state(state:CharacterState):
	match state:
		CharacterState.CHOP:
			$ChopTimer.stop()

func _enter_state(state: CharacterState):
	match state:
		CharacterState.IDLE:
			target = wait_spot.global_position
			animation_player.play("IDLE")
		CharacterState.MOVE_TO_TREE:
			target = closest_tree.global_position
			animation_player.play("RUN")
		CharacterState.MOVE_TO_CRATE:
			target = closest_crate.global_position
			animation_player.play("CARRY")
		CharacterState.CHOP:
			_chop()
			animation_player.play("CHOP")
			$ChopTimer.start()
		CharacterState.DROP:
			_drop()
			_change_state(CharacterState.IDLE)
			

func _animation_state(state:CharacterState):
	match state:
		CharacterState.IDLE:
			$Idle_Sprites.show()
			$Run_sprites.hide()
			$Carry_Sprites.hide()
			$Chop_Sprites.hide()
			animation_player.play("IDLE")
		CharacterState.MOVE_TO_TREE:
			$Run_sprites.show()
			$Idle_Sprites.hide()
			$Carry_Sprites.hide()
			$Chop_Sprites.hide()
			animation_player.play("RUN")
		CharacterState.MOVE_TO_CRATE:
			$Run_sprites.show()
			$Idle_Sprites.hide()
			$Carry_Sprites.hide()
			$Chop_Sprites.hide()
			animation_player.play("CARRY")
		CharacterState.MOVE_TO_SPOT:
			$Run_sprites.show()
			$Idle_Sprites.hide()
			$Carry_Sprites.hide()
			$Chop_Sprites.hide()
			animation_player.play("RUN")
		CharacterState.CHOP:
			$Run_sprites.hide()
			$Idle_Sprites.hide()
			$Carry_Sprites.hide()
			$Chop_Sprites.show()
			animation_player.play("CHOP")
	

func _find_closest_tree():
	var current_distance = 999999
	closest_tree = null
	for tree in Global.grown_trees:
		if Global.grown_trees.size() > 0:
			if tree.state == tree.TreeState.CHOPPING:
				continue
			if tree.state == tree.TreeState.CHOPPED:
				continue
			if tree.chopper:
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
			var crate_distance = self.global_position.distance_to(crate.global_position)
			if crate_distance < current_distance:
				current_distance = crate_distance
				closest_crate = crate
	return closest_crate
	

	
func _chop():
	if closest_tree != null:
		action_performed = true
		$ChopTimer.start()
		closest_tree._chop()
		print("Le Chop")
		

func _carry():
	pass
		
func _drop():
	closest_crate.store["Lumber"] += inventory["Lumber"]
	inventory["Lumber"] -= inventory["Lumber"]
	
func _on_chop_timer_timeout() -> void:
	if character_state != CharacterState.CHOP:
		return
	if closest_tree:
		closest_tree._chop()
	_change_state(CharacterState.IDLE)
	
func _tree_state():
		match closest_tree.state:
			closest_tree.TreeState.CHOPPING:
				if closest_tree.chopper != null and closest_tree.chopper != self:
					_find_closest_tree()
			closest_tree.TreeState.CHOPPED:
				closest_tree = null
