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
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if health <= 0:
		state = TreeState.CHOPPED
	
	_tree_state()
	
func _chop():
	health -= 1


func _tree_state():
	match state:
		TreeState.GROWN:
			add_to_group("Grown_Trees")
			$GrownSprite.visible = true
			$ChoppedSprite.visible = false
		TreeState.CHOPPING:
			pass
		TreeState.CHOPPED:
			remove_from_group("Grown_Trees")
			add_to_group("Chopped_Trees")
			$GrownSprite.visible = false
			$ChoppedSprite.visible = true
