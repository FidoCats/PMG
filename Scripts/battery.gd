extends RigidBody3D
class_name Battery



var ElectricalInput: float
var ElectricalOutput: float
var StoredElectricity: float



func _enter_tree() -> void:
	if not is_in_group("Electrical"):
		add_to_group("Electrical")



func _process(_delta: float) -> void:
	ElectricalOutput = StoredElectricity
