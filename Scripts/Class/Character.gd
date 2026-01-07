extends CharacterBody2D
class_name Character

@export var speed: int
@export var acceleration: int = 220
@export var target: Vector2
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var wait_spot: Marker2D = $"../wait_spot"
var closest_tree = null
var closest_crate = null
var is_moving: bool = false
var action_performed: bool = false
var reached: bool = false

enum CharacterState {
	IDLE,
	RUN,
	CHOP,
	CARRY,
	COLLECT,
	DROP,
	SUPPLY,
	PLANT,
	WATER,
	TAKE
}

@export var character_state: CharacterState = CharacterState.IDLE
@export var previous_state: CharacterState

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
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
