extends CharacterBody2D
class_name Character

@export var speed: int
@export var acceleration: int = 220
@export var target: Vector2
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var wait_spot: Marker2D = $"../wait_spot"
var closest_tree: Object
var closest_crate: Object
var chop_score: float
var collect_score: float
@onready var materials = Materials.new()
var is_moving: bool = false
var action_performed: bool = false
var reached: bool = false
signal newly_purchased

var Lumber: Object

enum CharacterState{
	IDLE,
	MOVE_TO_TREE,
	MOVE_TO_CRATE,
	MOVE_TO_SPOT,
	MOVE_TO_COLLECT,
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

func _init() -> void:
	newly_purchased.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	print(reached)
	_reached()


func _physics_process(_delta: float) -> void:
	move_and_slide()

@warning_ignore("shadowed_variable")
func _move(target, speed: int):
	#print(speed)
	self.position += self.position.direction_to(navigation_agent.get_next_path_position()) * get_physics_process_delta_time() * speed
	navigation_agent.target_position = target
	if speed > 0:
		is_moving = true
	else:
		is_moving = false
		
func _reached() -> bool:
	return position.distance_to(target) <= 5
