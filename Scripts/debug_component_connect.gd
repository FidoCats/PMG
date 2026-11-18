extends BaseElectricalComponent



@export var InNode: BaseElectricalComponent
@export var OutNode: BaseElectricalComponent
@export var NodeLabel: Label3D
@export var ElectricalLabel: Label3D



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
	
	NodeLabel.text = str("In: ", InNode, "Out: ", OutNode)
	ElectricalLabel.text = str("Input: ", ElectricalInput, ", Output: ", ElectricalOutput)
