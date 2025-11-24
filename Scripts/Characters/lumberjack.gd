extends CharacterBody2D

@export var target: Vector2
@export var target_position: Vector2
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var wait_spot: Marker2D = $"../wait_spot"
var is_moving: bool = false
var closest_tree = null
var higher: bool
var lower: bool
var action_performed: bool = false


enum CharacterState {
	IDLE,
	RUN,
	CHOP,
	CARRY
}

@export var character_state: CharacterState = CharacterState.IDLE

func _ready() -> void:
	pass
	
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	navigation_agent.target_position = target
	print()
	
	if closest_tree == null and not Global.trees.is_empty():
		_find_closest_tree()
	elif closest_tree != null:
		target = closest_tree.global_position
	elif closest_tree == null and Global.trees.is_empty():
		target = wait_spot.position 
		
	if is_moving == true:
		character_state = CharacterState.RUN
	elif is_moving == false and target == wait_spot.position:
		character_state = CharacterState.IDLE
	if closest_tree != null:
		if is_moving == false and target == closest_tree.global_position:
			character_state = CharacterState.CHOP
	
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
	if Global.trees.size() > 0:
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
	if self.position.distance_to(target) <= 1:
		_reached()
	else:
		is_moving = true

	move_and_slide()
	
@warning_ignore("shadowed_variable")
func _move(target, speed):
	self.position += self.position.direction_to(navigation_agent.get_next_path_position()) * get_physics_process_delta_time() * speed
	navigation_agent.target_position = target
	if speed > 0:
		is_moving = true
	else:
		is_moving = false
		
# (10/26/25) Idk why, but removing the "is_moving" line in the "_reached" function
# although outwardly redundant, causes the character to behave oddly while trying to stop
func _reached():
	is_moving = false

func _find_closest_tree():
	var current_distance = 999999
	closest_tree = null
	for tree in Global.trees:
		if Global.trees.size() > 0:
			if tree.state == tree.TreeState.CHOPPING:
				continue
			if tree.state == tree.TreeState.CHOPPED:
				continue
			var tree_distance = self.global_position.distance_to(tree.global_position)
			if tree_distance < current_distance:
				current_distance = tree_distance
				closest_tree = tree
	return closest_tree
	
func _chop():
	closest_tree._chop()
	action_performed = true
	$ChopTimer.start()
	if animation_player.animation_finished:
		animation_player.play("IDLE")

func _on_chop_timer_timeout() -> void:
	action_performed = false
	
func _character_state():
	match character_state:
		CharacterState.RUN:
			$run_animation.visible = true
			$idle_animation.visible = false
			$chop_animation.visible = false
			$axe_animation.visible = false
			animation_player.play("RUN")
		CharacterState.IDLE:
			$idle_animation.visible = true
			$run_animation.visible = false
			$chop_animation.visible = false
			$axe_animation.visible = false
			animation_player.play("IDLE")
		CharacterState.CHOP:
			$idle_animation.visible = false
			$run_animation.visible = false
			$chop_animation.visible = true
			$axe_animation.visible = true
			if action_performed == false:
				_chop()
			animation_player.play("CHOP")

func _tree_state():
	match closest_tree.state:
		closest_tree.TreeState.CHOPPED:
			closest_tree = null
