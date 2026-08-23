extends Node
class_name CameraSystem



@export var NumberLabel: Label3D
@export var ViewPort: SubViewport

var CurrentChild: Camera3D

var Parent

var CameraCount: int
var CurrentCamera: int

var Camera1: Camera3D
var Camera2: Camera3D
var Camera3: Camera3D
var Camera4: Camera3D
var Camera5: Camera3D



func _ready() -> void:
	Parent = get_parent()
	if Parent is InteractionComponent:
		Parent.Player_interacted.connect(SwitchCurrentCamera)
		#print("Interaction Signal Connected!")
	
	#Camera1 = Parent.get_parent().Camera1
	#Camera2 = Parent.get_parent().Camera2
	#Camera3 = Parent.get_parent().Camera3
	#Camera4 = Parent.get_parent().Camera4
	#Camera5 = Parent.get_parent().Camera5
	#
	#if ViewPort:
		#Camera1.reparent(ViewPort,true)
		#Camera2.reparent(ViewPort,true)
		#Camera3.reparent(ViewPort,true)
		#Camera4.reparent(ViewPort,true)
		#Camera5.reparent(ViewPort,true)
	
	CameraCount = ViewPort.get_child_count() - 1
	CurrentCamera = 1
	
	



func _get_configuration_warnings() -> PackedStringArray:
	if Parent is not InteractionComponent:
		return["This  node needs an InteractionComponent parent."]
	else:
		return[]



func SwitchCurrentCamera(_parent) -> void: # For Interaction to go through a Node variable is needed here. I know kinda stupid, just dont ask questions... :] -Fido
	if CurrentCamera < CameraCount:
		CurrentCamera += 1
	elif CurrentCamera > CameraCount:
		CurrentCamera = 1
	else:
		CurrentCamera = 1
	
	print("Camera Count: ", CameraCount, " Current Camera: ", CurrentCamera)



func _process(_delta: float) -> void:
	CurrentChild = ViewPort.get_child(CurrentCamera)
	
	if CurrentChild and NumberLabel:
		CurrentChild.make_current()
		NumberLabel.text = str(CurrentCamera)
