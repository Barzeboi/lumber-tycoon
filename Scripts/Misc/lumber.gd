extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Collectable_Lumber")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	var lumb_id = body.get_instance_id()
	Events.emit_signal("collect",lumb_id,self)
	remove_from_group("Collectable_Lumber")
	queue_free()
