extends CharacterBody2D
class_name Character

@export var speed: int
@export var acceleration: int = 220
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
var closest_crate = null
var is_moving: bool = false

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


@warning_ignore("shadowed_variable")
func _move(target, speed):
	#print(speed)
	self.position += self.position.direction_to(navigation_agent.get_next_path_position()) * get_physics_process_delta_time() * speed
	navigation_agent.target_position = target
	if speed > 0:
		is_moving = true
	else:
		is_moving = false
		
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
