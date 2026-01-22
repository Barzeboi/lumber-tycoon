extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Collectable_Lumber")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	Events.emit_signal("collect", self)
	await get_tree().create_timer(0.3).timeout
	queue_free()
