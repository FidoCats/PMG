## For easiest use; add the desired scene. Then Pick PinBodies you desire to connect and it should work

extends BaseElectricalComponent
class_name Wire



@export var WireBody: RigidBody3D
@export var Pin1: PinJoint3D
@export var Pin2: PinJoint3D
@export var PinBody1: RigidBody3D
@export var PinBody2: RigidBody3D
@export var READ_ONLY: String = "PinBody1 is Input, PinBody2 is Output"

@export_enum("Start", "Middle", "End") var Segment = "Middle"

#var ElectricalInput: float
#var ElectricalOutput: float
var Parent: RigidBody3D



func _enter_tree() -> void:
	Parent = get_parent() as RigidBody3D
	
	if not is_in_group("Electrical"):
		add_to_group("Electrical")
	
	
	
	if Pin1 and PinBody1:
		Pin1.node_a = get_path_to(WireBody)
		Pin1.node_b = get_path_to(PinBody1)
		#Pin1.node_b = get_path_to(Parent)
	if Pin2 and PinBody2:
		Pin2.node_a = get_path_to(WireBody)
		Pin2.node_b = get_path_to(PinBody2)
		#Pin2.node_b = get_path_to(Parent)



func _process(_delta: float) -> void:
	if PinBody1.is_in_group("Electrical"):
		ElectricalInput = PinBody1.ElectricalOutput * _delta
	if PinBody2.is_in_group("Electrical"):
		PinBody2.ElectricalInput = ElectricalOutput * _delta

	ElectricalOutput = ElectricalInput

	#if ElectricalInput > 0:
	print(self.name, ".EInput ", ElectricalInput)
	#if ElectricalOutput > 0:
	print(self.name, ".EOutput ", ElectricalOutput)
