extends Character

var inventory: Dictionary = {"Seeds": 0}
var take_amount: int
var inventory_full = 10

func _ready():
	pass
	
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	navigation_agent.target_position = target
	#print()
	
	if is_moving == false and target == wait_spot.global_position:
		await get_tree().process_frame
		character_state = CharacterState.IDLE
	if is_moving == true:
		character_state = CharacterState.RUN
	if is_moving == false and self.position.distance_to(closest_crate.global_position) < 1:
		character_state = CharacterState.TAKE
	if closest_tree != null:
		if inventory["Seeds"] > 0:
			if is_moving == false and self.position.distance_to(closest_tree.global_position) < 1:
				character_state = CharacterState.PLANT
	
	if closest_tree != null:
		if inventory["Seeds"] < 1:
			target = closest_crate.global_position
		if inventory["Seeds"] >= 1:
			target = closest_tree.global_position
	if closest_tree == null:
		if Global.chopped_trees.size() > 1:
			_find_closest_chopped_tree()
		if Global.chopped_trees < 1 and Global.planted_trees > 0:
			_find_closest_planted_tree()
		if Global.chopped_trees.size() < 1:
			target = wait_spot.global_position
			
	if closest_crate == null:
		_find_closest_crate()
	
	
		
	_character_state()
	if closest_tree != null:
		_tree_state()
		if closest_tree.watered == true:
			closest_tree = null
	
@warning_ignore("unused_parameter")
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
	take_amount = randi() % inventory_full + 1
	inventory["Seeds"] += take_amount
	closest_crate.store["Seeds"] -= take_amount
	
func _plant():
	print("plant")
	inventory["Seeds"] -= 1
	closest_tree._planted()
	action_performed = true
	$Timer.start()
	
	
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
	
func _find_closest_planted_tree():
	var current_distance = 999999
	if Global.chopped_trees.size() > 0:
		for tree in Global.growing_trees:
			if tree.watered == true:
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
			if action_performed == false:
				_plant()
			animation_player.play("DOING")
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
			character_state = CharacterState.WATER
