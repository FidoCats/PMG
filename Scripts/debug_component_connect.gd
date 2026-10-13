extends BaseElectricalComponent



@export var NodeA: BaseElectricalComponent
@export var NodeB: BaseElectricalComponent
@export var NodeLabel: Label3D
@export var ElectricalLabel: Label3D



func _process(_delta: float) -> void:
	if NodeA:
		ElectricalInput = NodeA.ElectricalOutput
	if NodeB:
		NodeB.ElectricalInput = ElectricalOutput
	
	NodeLabel.text = str("A: ", NodeA, "B: ", NodeB)
	ElectricalLabel.text = str("In: ", ElectricalInput, ", Out: ", ElectricalOutput)
