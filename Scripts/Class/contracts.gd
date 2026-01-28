extends Control

var label1
var label2
var label3
var goods_wanted
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Global.contract_won:
		$Contracts.hide()
		label1 = Label.new()
		add_child(label1)
		label1.position = Vector2(0, 20)
		label1.text = "Lumber" + str(Global.goods_delivered) + "/" + str(goods_wanted)
	else:
		pass
		#$No_Contracts.text = "No Contracts"
		
