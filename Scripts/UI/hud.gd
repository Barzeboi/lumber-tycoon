extends CanvasLayer

var Tab_min: float = 565.0
var Tab_max: float = 365.0
var tab
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	$Control/TabContainer.position.y = Tab_min
	$Control/TabContainer.current_tab = -1

func _on_tab_container_tab_clicked(tab: int) -> void:
	$Control/TabContainer.position.y = Tab_max
