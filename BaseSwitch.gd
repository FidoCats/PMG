extends BaseElectricalComponent
class_name BaseSwitch



signal Switched(On: bool)

@export var On: bool = false
@export var Toggle: bool = true
@export var PressTime: float = 0.75
@export var ButtonMesh: MeshInstance3D
@export var ButtonTravelAmount: float = 0.75

var ButtonStartPosition: float



func _ready() -> void:
	ButtonStartPosition = ButtonMesh.position.y
	IsBriged = On
	if ButtonMesh:
		if On:
			ButtonMesh.position.y = (ButtonStartPosition - ButtonTravelAmount)
		else:
			ButtonMesh.position.y = ButtonStartPosition



func Interact(_Body: Node3D, _User: Node3D):
	On = !On
	IsBriged = On
	Switched.emit(On)
	if ButtonMesh:
		if On:
			ButtonMesh.position.y = (ButtonStartPosition - ButtonTravelAmount)
		else:
			ButtonMesh.position.y = ButtonStartPosition
	if not Toggle:
		await get_tree().create_timer(PressTime).timeout
		On = !On
		IsBriged = On
		Switched.emit(On)
		if ButtonMesh:
			if On:
				ButtonMesh.position.y = ButtonStartPosition
			else:
				ButtonMesh.position.y = (ButtonStartPosition - ButtonTravelAmount)
	print("Switched to ", On)
