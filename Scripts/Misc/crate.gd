extends StaticBody2D

var store: Dictionary = {"Lumber": 0, "Planks": 0, "Furniture": 0}

enum CrateState {
	NOT_FULL,
	FULL
}

@onready var state = CrateState.NOT_FULL

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Crates")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
