extends SpringArm3D



@export_category("Use: ")
@export var AutoSpin: bool = false
@export var MouseReact: bool = true
@export_category("Amount: ")
@export var SpinAmount: float = 5.0
@export var Sensitivity: float = 0.05
@export var Middle: float = ProjectSettings.get_setting("display/window/size/viewport_width") / 2
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
		Middle = ProjectSettings.get_setting("display/window/size/viewport_width") / 2
		MousePosGetterNode.position.x = Middle
		var MousePos = MousePosGetterNode.get_global_mouse_position()
		if MousePos.x > 0:
			rotation_degrees.y += MousePos.x * 0.025 * Sensitivity
		if MousePos.x < 0:
			rotation_degrees.y += MousePos.x * 0.025 * Sensitivity
