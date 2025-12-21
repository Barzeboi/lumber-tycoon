extends StaticBody2D


var chopper
signal statechanged
signal done_chopping
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
var chopped = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Grown_Trees")
	statechanged.connect(_tree_state)


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if health <= 0 and chopped != true:
		chopper.inventory["Lumber"] += randi_range(1,5)
		chopped = true
	
	if chopped == true:
		state = TreeState.CHOPPED
		statechanged.emit()
	
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
			done_chopping.emit()

func _on_tree_area_body_entered(body: Node2D) -> void:
	chopper = body


func _on_tree_area_body_exited(body: Node2D) -> void:
	chopper = null
