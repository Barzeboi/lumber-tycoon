extends CanvasLayer

var min: float = 565.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_tab_container_tab_button_pressed(tab: int) -> void:
	pass # Replace with function body.


func _on_button_pressed() -> void:
	$Control/TabContainer.position.y = min
