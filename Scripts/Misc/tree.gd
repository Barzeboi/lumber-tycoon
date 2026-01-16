extends StaticBody2D

var materials: Materials = Materials.new()
var chopper
signal statechanged
signal done_chopping
enum TreeState {
	PLANTED,
	GROWING,
	GROWN,
	CHOPPING,
	CHOPPED
}
@export var state: TreeState = TreeState.GROWN
@export var previous_state: TreeState
var health = 8
var full_health = 8
var chopped = false
var chopping = false
var watered = false
@onready var lumber = materials.Lumber
@onready var spawn_points = [$SpawnHolder/lumber_spawn.position, $SpawnHolder/lumber_spawn2.position, $SpawnHolder/lumber_spawn3.position, $SpawnHolder/lumber_spawn4.position, $SpawnHolder/lumber_spawn5.position]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_tree_state()
	statechanged.connect(_tree_state)


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	
	
	if chopped == true:
		state = TreeState.CHOPPED
		statechanged.emit()
	
	if chopping == true:
		state = TreeState.CHOPPING
		statechanged.emit()
		#print(name + ": " + str(chopper))
	
func _chop():
	health -= 1
	chopping = true
	
func _planted():
	health = full_health
	state = TreeState.PLANTED
	chopped = false
	#print(name + ": " + str(state))
	statechanged.emit()
	
func _change_state(new_state: TreeState):
	if state == new_state: return
	previous_state = state
	_exit_state(state)
	state = new_state
	_enter_state(state)
	
	
func _exit_state(state:TreeState):
	match state:
		TreeState.CHOPPING:
			chopping = false
		TreeState.CHOPPED:
			chopped = false

func _enter_state(state:TreeState):
	match state:
		TreeState.GROWN:
			health = full_health

func _spawn():
	for positions in spawn_points:
		var new_log = lumber.instantiate()
		new_log.global_position = position
		owner.add_child(new_log)

func _tree_state():
	match state:
		TreeState.PLANTED:
			remove_from_group("Chopped_Trees")
			add_to_group("Planted_Trees")
		TreeState.GROWN:
			add_to_group("Grown_Trees")
			$GrownSprite.visible = true
			$ChoppedSprite.visible = false
		TreeState.GROWING:
			remove_from_group("Planted_Trees")
			add_to_group("Growing_Trees")
		TreeState.CHOPPING:
			pass
		TreeState.CHOPPED:
			remove_from_group("Grown_Trees")
			add_to_group("Chopped_Trees")
			$CollisionShape2D.disabled = true
			$GrownSprite.visible = false
			$ChoppedSprite.visible = true
			_spawn()
			done_chopping.emit()

func _on_tree_area_body_entered(body: Node2D) -> void:
	chopper = body

func _on_tree_area_body_exited(body: Node2D) -> void:
	await get_tree().process_frame
	chopper = null
