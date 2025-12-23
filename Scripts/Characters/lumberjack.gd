extends CharacterBody2D

@export var target: Vector2
@export var target_position: Vector2
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var wait_spot: Marker2D = $"../wait_spot"
var is_moving: bool = false
var closest_tree = null
var closest_crate = null
var dibs = false
var higher: bool
var lower: bool
var inventory_full
var action_performed: bool = false
var inventory: Dictionary = {"Lumber": 0}
var currentspeed



enum CharacterState {
	IDLE,
	RUN,
	CHOP,
	CARRY,
	COLLECT,
	DROP
}

@export var character_state: CharacterState = CharacterState.IDLE

func _ready() -> void:
	pass
	
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	navigation_agent.target_position = target
	#print(name)

	$Label.text = str(inventory["Lumber"])
	
	if closest_tree == null and not Global.grown_trees.is_empty():
		_find_closest_tree()
	elif closest_crate != null and inventory["Lumber"] >= 10:
		target = closest_crate.global_position
	elif closest_tree != null:
		target = closest_tree.global_position
	elif closest_tree == null and inventory["Lumber"] > 0:
		target = closest_crate.global_position
	else:
		target = wait_spot.global_position
	
	if closest_crate == null and not Global.crates.is_empty():
		_find_closest_crate()
		
	if closest_tree:
		dibs = true
		
	if is_moving == true and target != closest_crate.global_position:
		character_state = CharacterState.RUN
	elif is_moving == false and target == wait_spot.position:
		character_state = CharacterState.IDLE
	if closest_tree != null:
		if is_moving == false and target == closest_tree.global_position:
			character_state = CharacterState.CHOP
	if closest_crate != null:
		if is_moving == true and target == closest_crate.global_position:
			character_state = CharacterState.CARRY
		if target == closest_crate.global_position and self.position.distance_to(target) < 5:
			character_state = CharacterState.DROP
	
	if target.x < self.global_position.x:
		$idle_animation.flip_h = true
		$run_animation.flip_h = true
		$chop_animation.flip_h = true
		$axe_animation.flip_h = true
	elif target.x > self.global_position.x:
		$idle_animation.flip_h = false
		$run_animation.flip_h = false
		$chop_animation.flip_h = false
		$axe_animation.flip_h = false
		
	_character_state()
	if closest_tree != null:
		_tree_state()
	
@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	match character_state:
		CharacterState.RUN:
			_move(target,70)
		CharacterState.IDLE:
			_move(target, 0)
		CharacterState.CHOP:
			_move(target, 0)
		CharacterState.CARRY:
			_move(target, 50)
	if self.position.distance_to(target) <= 1:
		_reached()
	else:
		is_moving = true

	move_and_slide()
	
@warning_ignore("shadowed_variable")
func _move(target, speed):
	#print(speed)
	self.position += self.position.direction_to(navigation_agent.get_next_path_position()) * get_physics_process_delta_time() * speed
	navigation_agent.target_position = target
	if speed > 0:
		is_moving = true
	else:
		is_moving = false
	currentspeed = speed
	
	if (speed != currentspeed):
		print(name + ":" + " Speed Changed")
# (10/26/25) Idk why, but removing the "is_moving" line in the "_reached" function
# although outwardly redundant, causes the character to behave oddly while trying to stop
func _reached():
	is_moving = false
	

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
	closest_tree._chop()
	action_performed = true
	$ChopTimer.start()
	if animation_player.animation_finished:
		animation_player.play("IDLE")

func _carry():
	pass
		
func _drop():
	closest_crate.store["Lumber"] += inventory["Lumber"]
	inventory["Lumber"] -= inventory["Lumber"]
	
func _on_chop_timer_timeout() -> void:
	action_performed = false
	
func _character_state():
	match character_state:
		CharacterState.RUN:
			$run_animation.visible = true
			$idle_animation.visible = false
			$chop_animation.visible = false
			$axe_animation.visible = false
			$carry_animation.visible = false
			$box_animation.visible = false
			animation_player.play("RUN")
		CharacterState.IDLE:
			$idle_animation.visible = true
			$run_animation.visible = false
			$chop_animation.visible = false
			$axe_animation.visible = false
			$carry_animation.visible = false
			$box_animation.visible = false
			animation_player.play("IDLE")
		CharacterState.CHOP:
			$idle_animation.visible = false
			$run_animation.visible = false
			$chop_animation.visible = true
			$axe_animation.visible = true
			$carry_animation.visible = false
			$box_animation.visible = false
			if action_performed == false:
				_chop()
			animation_player.play("CHOP")
		CharacterState.CARRY:
			$idle_animation.visible = false
			$run_animation.visible = false
			$chop_animation.visible = false
			$axe_animation.visible = false
			$carry_animation.visible = true
			$box_animation.visible = true
			animation_player.play("CARRY")
		CharacterState.DROP:
			_drop()

func _tree_state():
	if dibs == true:
		match closest_tree.state:
			closest_tree.TreeState.CHOPPING:
				if closest_tree.chopper != null and closest_tree.chopper != self:
					_find_closest_tree()
			closest_tree.TreeState.CHOPPED:
				closest_tree = null
