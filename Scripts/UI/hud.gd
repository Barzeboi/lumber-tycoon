extends CanvasLayer

var Tab_min: float = 565.0
var Tab_max: float = 365.0
var placer
var item_selected: bool = false
var mouse_pos: Vector2
var placer_texture: CompressedTexture2D = preload("res://Assets/Characters/base_idle_strip9.png")
var lumberjack: PackedScene = preload("res://Scenes/Characters/lumberjack.tscn")
@onready var wait_spot: Marker2D = $"../wait_spot"

enum Selected_Purchaseable {
	LUMBERJACK,
	PLANTER,
	COURIER,
	LUMBERMILL
}

var currently_seletected: Selected_Purchaseable = Selected_Purchaseable.LUMBERJACK
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	mouse_pos = get_viewport().get_mouse_position()
	if is_instance_valid(placer):
		placer.position = mouse_pos
		
	if Input.is_action_just_pressed("Interact"):
		match currently_seletected:
			Selected_Purchaseable.LUMBERJACK:
				_spawn(lumberjack)
	
func _physics_process(delta: float) -> void:
	pass

func _on_tab_container_tab_clicked(tab: int) -> void:
	$Control/TabContainer.position.y = Tab_max

func _on_lumberjack_button_pressed() -> void:
	$Control/TabContainer.position.y = Tab_min
	$Control/TabContainer.current_tab = -1
	if is_instance_valid(placer):
		_delete_placement_visualizer()
	_create_placement_visualizer(placer_texture)
	

func _create_placement_visualizer(visual: CompressedTexture2D):
	placer = Sprite2D.new()
	add_child(placer)
	placer.texture = visual
	placer.hframes = 9
	placer.vframes = 1
	placer.frame = 0
	placer.self_modulate = Color(255.014, 255.014, 255.014, 0.525)
	
func _delete_placement_visualizer():
		placer.free()
		
func _spawn(instance:PackedScene):
	if is_instance_valid(instance):
		await get_tree().process_frame
		var spawn = instance.instantiate()
		spawn.global_position = mouse_pos
		owner.add_child(spawn)
