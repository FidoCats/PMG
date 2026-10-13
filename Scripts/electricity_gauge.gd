extends BaseElectricalComponent #RigidBody3D
class_name ElectricalGauge



@export var GaugeLabel: Label3D

#var ElectricalInput: float
#var ElectricalOutput: float



func _ready() -> void:
	if not is_in_group("Electrical"):
		add_to_group("Electrical")



func _process(_delta: float) -> void:
	if GaugeLabel.text != str(ElectricalInput):
		GaugeLabel.text = str(ElectricalInput)
		ElectricalOutput = ElectricalInput
	
	ElectricalOutput = ElectricalInput
	
	#print(ElectricalInput)
