## For easiest use; add the desired scene. Then Pick PinBodies you desire to connect and it should work

extends BaseElectricalComponent
class_name Wire



@export var WireBody: RigidBody3D
@export var Pin1: PinJoint3D
@export var Pin2: PinJoint3D
@export var InNode: BaseElectricalComponent
@export var OutNode: BaseElectricalComponent


@export_enum("Start", "Middle", "End") var Segment = "Middle"



func _ready() -> void:
	Pin1.node_a = get_path_to(InNode)
	Pin1.node_b = get_path_to(self)
	Pin2.node_a = get_path_to(self)
	Pin2.node_b = get_path_to(OutNode)



func _process(_delta: float) -> void:
	if InNode and not InNode.IsEnd:
		ElectricalInput = InNode.ElectricalOutput
	else:
		InNode = null
	if OutNode and not OutNode.IsStart:
		OutNode.ElectricalInput = ElectricalOutput
	else:
		OutNode = null
	
	ElectricalOutput = ElectricalInput
