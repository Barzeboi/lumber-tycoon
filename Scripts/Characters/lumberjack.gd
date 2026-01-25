extends Character

var inventory_full: int = 10
@export var inventory: Dictionary = {"Lumber": 0}
var currentspeed
var id

var level: int = 1
var base_cost: float = 900
@export var cost: float = 900
@export var damage: float = 1.0

var collectable_lumber: Array = []

var closest_log: Object

func _init() -> void:
	Events.emit_signal("purchase", cost)
	Events.connect("collect", _collect)

func _ready() -> void:
	pass
	
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	navigation_agent.target_position = target
	#print(name)
	
	$Label.text = str(inventory["Lumber"])
	#print(str(inventory["Lumber"]))

	
	match character_state:
		CharacterState.IDLE:
			_check_for_logs()
			if inventory["Lumber"] >= inventory_full:
				if closest_crate == null:
					_find_closest_crate()
				if closest_crate:
					_change_state(CharacterState.MOVE_TO_CRATE)
					
			elif collectable_lumber.size() > 0:
				if closest_log == null:
					_find_closest_log()
				else:
					_change_state(CharacterState.MOVE_TO_COLLECT)
			
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
				closest_tree = null
				_change_state(CharacterState.IDLE)
		CharacterState.MOVE_TO_CRATE:
			if _reached():
				_change_state(CharacterState.DROP)
		CharacterState.MOVE_TO_COLLECT:
			if _reached():
				_change_state(CharacterState.IDLE)
			
	for index in collectable_lumber:
		if index == null:
			collectable_lumber.erase(index)
	
	if target.x < global_position.x:
		$Idle_Sprites.scale.x = -1.0
		$Run_sprites.scale.x = -1.0
		$Chop_Sprites.scale.x = -1.0
		$Carry_Sprites.scale.x = -1.0
	elif target.x > global_position.x:
		$Idle_Sprites.scale.x = 1.0
		$Run_sprites.scale.x = 1.0
		$Chop_Sprites.scale.x = 1.0
		$Carry_Sprites.scale.x = 1.0
	
@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	var direction = position.direction_to(Vector2(0,0))
	velocity = speed * direction
	match character_state:
		CharacterState.MOVE_TO_TREE, CharacterState.MOVE_TO_SPOT:
			_move(target, 70)
		CharacterState.MOVE_TO_CRATE, CharacterState.MOVE_TO_COLLECT:
			_move(target, 50)
		_:
			_move(global_position, 0)

func _change_state(new_state: CharacterState):
	if character_state == new_state: return
	$CollisionShape2D.disabled = false
	_exit_state(character_state)
	character_state = new_state
	_enter_state(character_state)
	
func _exit_state(state:CharacterState):
	match state:
		CharacterState.CHOP:
			$ChopTimer.stop()

func _enter_state(state: CharacterState):
	match state:
		CharacterState.IDLE:
			target = wait_spot.global_position
			_animation_state(character_state)
		CharacterState.MOVE_TO_TREE:
			target = closest_tree.global_position
			_animation_state(character_state)
			$CollisionShape2D.disabled = true
		CharacterState.MOVE_TO_CRATE:
			target = closest_crate.global_position
			_animation_state(character_state)
			$CollisionShape2D.disabled = true
		CharacterState.MOVE_TO_SPOT:
			target = wait_spot.global_position
			_animation_state(character_state)
		CharacterState.MOVE_TO_COLLECT:
			target = closest_log.global_position
			_animation_state(character_state)
		CharacterState.CHOP:
			_chop()
			_animation_state(character_state)
			$ChopTimer.start()
		CharacterState.COLLECT:
			pass
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
		CharacterState.MOVE_TO_TREE, CharacterState.MOVE_TO_SPOT, CharacterState.MOVE_TO_COLLECT:
			$Run_sprites.show()
			$Idle_Sprites.hide()
			$Carry_Sprites.hide()
			$Chop_Sprites.hide()
			animation_player.play("RUN")
		CharacterState.MOVE_TO_CRATE:
			$Run_sprites.hide()
			$Idle_Sprites.hide()
			$Carry_Sprites.show()
			$Chop_Sprites.hide()
			animation_player.play("CARRY")
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
	
func _find_closest_log():
	var current_distance: float = 60
	for logs in collectable_lumber:
		if collectable_lumber.size() > 0:
			if logs != null:
				var log_distance = global_position.distance_to(logs.global_position)
				if log_distance < current_distance:
					current_distance = log_distance
					closest_log = logs
	return closest_log
			
func _chop():
	if closest_tree != null:
		id = closest_tree.get_instance_id()
		action_performed = true
		$ChopTimer.start()
		
func _carry():
	pass

func _check_for_logs():
	$Collect_Area/CollisionShape2D.disabled = false
	await get_tree().create_timer(0.06).timeout
	$Collect_Area/CollisionShape2D.disabled = true

func _collect(lumb_id, area: Node2D):
	var instanceid = get_instance_id()
	print("collect")
	if is_same(lumb_id, instanceid):
		inventory["Lumber"] += 1
	collectable_lumber.erase(area)
		
func _drop():
	closest_crate.store["Lumber"] += inventory["Lumber"]
	inventory["Lumber"] -= inventory["Lumber"]
	
func _on_chop_timer_timeout() -> void:
	if character_state != CharacterState.CHOP:
		return
	if closest_tree:
		Events.emit_signal("chop", id, damage)
	_change_state(CharacterState.IDLE)
	
func _tree_state():
		match closest_tree.state:
			closest_tree.TreeState.CHOPPING:
				if closest_tree.chopper != null and closest_tree.chopper != self:
					_find_closest_tree()
			closest_tree.TreeState.CHOPPED:
				closest_tree = null

func _on_collect_area_area_entered(area: Area2D) -> void:
	collectable_lumber.append(area)
