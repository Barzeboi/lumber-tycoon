extends Resource
class_name TaskManager

var priority: int = 1 : set = _set_priority, get = _get_priority
var max_priority: int = 3
@export var tasks: Dictionary = {"Chopping": 1, "Carrying": 1, "Idle": 1}

func _set_priority(priority) -> void:
	priority += 1
	
func _get_priority() -> int:
	return priority
