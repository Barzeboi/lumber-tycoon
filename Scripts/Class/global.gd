extends Node

@onready var grown_trees = get_tree().get_nodes_in_group("Grown_Trees")
@onready var planted_trees = get_tree().get_nodes_in_group("Planted_Trees")
@onready var growing_trees = get_tree().get_nodes_in_group("Growing_Trees")
@onready var chopped_trees = get_tree().get_nodes_in_group("Chopped_Trees")
@onready var crates = get_tree().get_nodes_in_group("Crates")
var cash = 10000
var contract
var contract_won = false
var goods_delivered: int

enum ContractType{
	LUMBER,
	PLANKS,
	FURNITURE
}

enum Purchased{
	NONE,
	LUMBERJACK,
	PLANTER,
	COURIER,
	LUMBERMILL
}

var purchased: Purchased = Purchased.NONE
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	grown_trees = get_tree().get_nodes_in_group("Grown_Trees")
	chopped_trees = get_tree().get_nodes_in_group("Chopped_Trees")
	crates = get_tree().get_nodes_in_group("Crates")
