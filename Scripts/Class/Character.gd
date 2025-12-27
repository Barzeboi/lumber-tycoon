extends CharacterBody2D
class_name Character

@export var speed: int
@export var acceleration: int = 220

enum CharacterState {
	IDLE,
	RUN,
	CHOP,
	CARRY,
	COLLECT,
	DROP,
	SUPPLY,
	PLANT
}

@export var character_state: CharacterState = CharacterState.IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
