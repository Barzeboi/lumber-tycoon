extends CanvasLayer

var Tab_min: float = 565.0
var Tab_max: float = 365.0
var placer
var item_selected: bool = false
var mouse_pos: Vector2
var placer_texture: CompressedTexture2D = preload("res://Assets/Characters/base_idle_strip9.png")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	mouse_pos = get_viewport().get_mouse_position()
	
func _physics_process(delta: float) -> void:
		pass

func _on_button_pressed() -> void:
	$Control/TabContainer.position.y = Tab_min
	$Control/TabContainer.current_tab = -1
	_create_placement_visualizer(placer_texture)

func _on_tab_container_tab_clicked(tab: int) -> void:
	$Control/TabContainer.position.y = Tab_max

func _create_placement_visualizer(visual: Sprite2D):
	placer = Sprite2D.new()
	add_child(placer)
	placer.position = mouse_pos
	visual.hframes = 9
	visual.vframes = 1
	visual.frame = 0
	visual.self_modulate = Color(255.014, 255.014, 255.014, 0.482)
