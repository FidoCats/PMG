extends RigidBody3D
class_name Electromotor



@export_category("Prefrences")
@export var Speed: float = 5
@export_category("Nodes")
@export var Joint: Generic6DOFJoint3D
@export var OrientationSwitch: InteractionButton
@export var SpeedLabel: Label3D



func _ready() -> void:
	OrientationSwitch.pressed.connect(Switch)



func _process(_delta: float) -> void:
	Joint.set("linear_motor_x/target_velocity", Speed)
	print(Joint.get("linear_motor_x/target_velocity"))
	SpeedLabel.text = str("Speed: ", Speed)



func Switch():
	Speed = -Speed
