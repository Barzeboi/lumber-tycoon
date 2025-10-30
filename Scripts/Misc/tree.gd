extends StaticBody2D


enum TreeState {
	PLANTED,
	WATERED,
	GROWING,
	GROWN,
	CHOPPING,
	CHOPPED
}

@export var state: TreeState = TreeState.GROWN
@onready var chop_spot: Marker2D = $chop_spot
var health = 4


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if health == 0:
		remove_from_group("Trees")
		queue_free()
	
func _chop():
	health -= 1
