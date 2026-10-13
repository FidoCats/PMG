extends BaseElectricalComponent
class_name DebugElectricityGenerator



@export var OutputLabel: Label3D



func _process(_delta: float) -> void:
	ElectricalOutput = 10.0
	
	OutputLabel.text = str("Output: ", ElectricalOutput)
