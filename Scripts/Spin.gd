extends SpringArm3D



@export_category("Use: ")
@export var AutoSpin: bool = false
@export var MouseReact: bool = true
@export_category("Amount: ")
@export var SpinAmount: float = 5.0
@export var Sensitivity: float = 0.05
@export var ThresholdL: float = 75.0
@export var ThresholdR: float = 25.0
@export_category("Nodes")
@export var MousePosGetterNode: Node2D



#func _unhandled_input(_event: InputEvent) -> void:
	#if _event is InputEventMouseMotion and MouseReact:
		#rotation_degrees.y += _event.relative.x
		#



func _process(_delta: float):
	if AutoSpin:
		rotation_degrees.y += SpinAmount * 0.01
	elif MouseReact:
		var MousePos = MousePosGetterNode.get_local_mouse_position()
		if MousePos.x > ThresholdR:
			rotation_degrees.y += MousePos.x * 0.005 * Sensitivity
		if -MousePos.x > ThresholdL:
			rotation_degrees.y += -MousePos.x * 0.01 * Sensitivity
