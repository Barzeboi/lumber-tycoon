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
@export var state: TreeState
@export var previous_state: TreeState
var health = 8
var full_health = 8
var chopped = false
var chopping = false
var planted = false
var watered = false
@onready var lumber = materials.Lumber
@onready var spawn_points = [$SpawnHolder/lumber_spawn, $SpawnHolder/lumber_spawn2, $SpawnHolder/lumber_spawn3, $SpawnHolder/lumber_spawn4, $SpawnHolder/lumber_spawn5]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.connect("chop", _chop)
	Events.connect("planted", _planted)
	_change_state(TreeState.CHOPPED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	match state:
		TreeState.GROWN:
			if chopping == true:
				_change_state(TreeState.CHOPPING)
		TreeState.CHOPPING:
			if health <= 0:
				_change_state(TreeState.CHOPPED)
		TreeState.CHOPPED:
			if planted == true:
				_change_state(TreeState.PLANTED)
		TreeState.PLANTED:
			if watered == true:
				_change_state(TreeState.GROWING)
				
func _change_state(new_state: TreeState):
	if state == new_state: return
	previous_state = state
	_exit_state(state)
	state = new_state
	_enter_state(state)
	
func _exit_state(s:TreeState):
	match s:
		TreeState.CHOPPING:
			chopping = false
		TreeState.CHOPPED:
			chopped = false

func _enter_state(s:TreeState):
	match s:
		TreeState.GROWN:
			health = full_health
			add_to_group("Grown_Trees")
			_animation_state(state)
		TreeState.CHOPPING:
			_animation_state(state)
		TreeState.CHOPPED:
			chopped = true
			remove_from_group("Grown_Trees")
			add_to_group("Chopped_Trees")
			_spawn()
			_animation_state(state)
		TreeState.PLANTED:
			print("planted")
			remove_from_group("Chopped_Trees")
			add_to_group("Planted_Trees")
			_animation_state(state)
		TreeState.GROWING:
			$planted_timer.start()
			_animation_state(state)
	
func _chop(id, damage: float):
	var instanceid = get_instance_id()
	if is_same(id,instanceid):
		health -= damage
		chopping = true
	
func _planted(id):
	var instance_id = get_instance_id()
	if is_same(id,instance_id):
		health = full_health
		planted = true
		chopped = false
		#print(name + ": " + str(state))
		statechanged.emit()

func _spawn():
	for positions in spawn_points:
		var new_log = lumber.instantiate()
		owner.owner.add_child(new_log)
		new_log.transform = positions.global_transform

func _animation_state(s:TreeState):
	match s:
		TreeState.PLANTED:
			pass
		TreeState.GROWN:
			$GrownSprite.visible = true
			$ChoppedSprite.visible = false
		TreeState.GROWING:
			pass
		TreeState.CHOPPING:
			pass
		TreeState.CHOPPED:
			$CollisionShape2D.disabled = true
			$GrownSprite.visible = false
			$ChoppedSprite.visible = true

func _on_tree_area_body_entered(body: Node2D) -> void:
	chopper = body

func _on_tree_area_body_exited(_body: Node2D) -> void:
	await get_tree().process_frame
	chopper = null


func _on_planted_timer_timeout() -> void:
	_change_state(TreeState.GROWN)
