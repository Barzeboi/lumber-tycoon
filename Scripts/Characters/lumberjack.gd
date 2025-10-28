extends CharacterBody2D

@export var target: Vector2
@export var target_position: Vector2
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var wait_spot: Marker2D = $"../wait_spot"
var is_moving: bool = false
var closest_tree = null


enum CharacterState {
	IDLE,
	RUN,
	CHOP,
	CARRY
}

@export var character_state: CharacterState = CharacterState.RUN

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	print(character_state)
	navigation_agent.target_position = target
	
	if is_moving == true:
		character_state = CharacterState.RUN
	else:
		character_state = CharacterState.IDLE
	match  character_state:
		CharacterState.RUN:
			$AnimatedSprite2D.play("walk")
		CharacterState.IDLE:
			$AnimatedSprite2D.play("idle")
			
	if closest_tree == null:
		_find_closest_tree()
	else:
		target = closest_tree.chop_spot.global_position
	
func _physics_process(delta: float) -> void:
	match character_state:
		CharacterState.RUN:
			_move(target,70)
		CharacterState.IDLE:
			_move(position, 0)
	if self.position.distance_to(target) <= 5:
		_reached()

	move_and_slide()
	
func _move(target, speed):
	self.position += self.position.direction_to(navigation_agent.get_next_path_position()) * get_physics_process_delta_time() * speed
	navigation_agent.target_position = target
	if speed > 0:
		is_moving = true
	else:
		is_moving = false
		
# (10/26/25) Idk why, but removing the "is_moving" line in the "_reached function
# although outwardly redundant, causes the character to behave oddly while trying to stop
func _reached():
	is_moving = false
	target = position
	print("reached")

func _find_closest_tree():
	var current_distance = 999999
	closest_tree = null
	for tree in get_tree().get_nodes_in_group("Trees"):
		if tree.state != tree.TreeState.CHOPPING or tree.state != tree.TreeState.CHOPPED:
			var tree_distance = self.global_position.distance_to(tree.global_position)
			if tree_distance < current_distance:
				current_distance = tree_distance
				closest_tree = tree
	return closest_tree
