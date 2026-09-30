extends StaticBody3D
class_name InteractionButton



signal pressed
signal up
signal down



@export_category("Prefrences")
@export var Toggle: bool = false
@export var Pressed: bool = false
@export var CoolDown: float = 0.25
@export var PressTime: float = 0.1
@export_category("Nodes")
@export var MeshInstance: MeshInstance3D
@export_category("Assets")
@export var UpMat: StandardMaterial3D = load("res://Stuff/Materials/Orange.tres")
@export var DownMat: StandardMaterial3D = load("res://Stuff/Materials/Bron.tres")

var CanPress: bool = true



func _process(_delta: float) -> void:
	if Pressed:
		MeshInstance.material_overlay = DownMat
		down.emit()
	else:
		MeshInstance.material_overlay = UpMat
		up.emit()



func Press() -> void:
	CanPress = false
	Pressed = !Pressed
	pressed.emit()
	await get_tree().create_timer(PressTime).timeout
	if not Toggle:
		Pressed = !Pressed
	await get_tree().create_timer(CoolDown).timeout
	CanPress = true



func Interact(_body: Node3D, _user: Node3D):
	Press()
