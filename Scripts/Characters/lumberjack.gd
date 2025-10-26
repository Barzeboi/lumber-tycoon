extends CharacterBody2D

@export var target: Variant
@export var target_position: Vector2
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var wait_spot: Marker2D = $"../wait_spot"
var is_moving: bool = false


enum CharacterState {
	IDLE,
	RUN,
	CHOP,
	CARRY
}

@export var character_state: CharacterState = CharacterState.IDLE

func _ready() -> void:
	target = wait_spot.position
	target_position = navigation_agent.target_position
	
func _process(delta: float) -> void:
	print(is_moving)
	navigation_agent.target_position = target
	var closest_tree = null
	var current_distance = 99999
	
	if is_moving == true:
		character_state = CharacterState.RUN
	else:
		character_state = CharacterState.IDLE
	match  character_state:
		CharacterState.RUN:
			$AnimatedSprite2D.play("walk")
		CharacterState.IDLE:
			$AnimatedSprite2D.play("idle")
			
	if character_state == CharacterState.IDLE:
		for tree in get_tree().get_nodes_in_group("Trees"):
			var tree_distance = global_position.distance_to(tree.chop_spot.position)
			if tree_distance > current_distance:
				current_distance = tree_distance
				closest_tree = tree
				target = closest_tree
	
func _physics_process(delta: float) -> void:
	
	match character_state:
		CharacterState.RUN:
			_move(target,70)
		CharacterState.IDLE:
			_move(position, 0)

	
	move_and_slide()
	
func _move(target, speed):
	self.position += self.position.direction_to(navigation_agent.get_next_path_position()) * get_physics_process_delta_time() * speed
	navigation_agent.target_position = target
	if speed > 0:
		is_moving = true
	else:
		is_moving = false
	
func _on_navigation_agent_2d_target_reached() -> void:
		character_state = CharacterState.IDLE
		is_moving = false
		target = position
		print("reached")
