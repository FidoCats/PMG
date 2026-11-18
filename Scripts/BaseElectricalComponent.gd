extends Node3D
class_name BaseElectricalComponent



signal Powered 

@export var IsEnd: bool = false
@export var IsStart: bool = false
@export var MinInput: float = 1.0
@export var MaxInput: float = 2.0
@export var IsBriged: bool = true

var IsPowered: bool = false
var ElectricalInput: float = 0.0
var ElectricalOutput: float = 0.0



func _ready() -> void:
	if not is_in_group("Electrical"):
		add_to_group("Electrical")



func _process(_delta: float) -> void:
	if IsBriged:
		if IsEnd:
			ElectricalOutput = 0.0
		else:
			ElectricalOutput = ElectricalInput
		
		if IsStart:
			ElectricalInput = 0.0
	else:
		ElectricalInput = 0.0
		ElectricalOutput = 0.0
	
	if ElectricalInput >= MinInput and ElectricalInput <= MaxInput:
		IsPowered = true
		Powered.emit()
	else:
		IsPowered = false
