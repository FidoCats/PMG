extends Node3D
class_name BaseElectricalComponent



@export var IsEnd: bool = false
@export var IsStart: bool = false

var ElectricalInput: float = 0.0
var ElectricalOutput: float = 0.0



func _ready() -> void:
	if not is_in_group("Electrical"):
		add_to_group("Electrical")



func _process(_delta: float) -> void:
	if not IsEnd:
		#if ElectricalOutput != ElectricalInput:
			ElectricalOutput = ElectricalInput
			#print(ElectricalInput)
	else:
			ElectricalOutput = 0.0
	
	if IsStart:
		ElectricalInput = 0.0
