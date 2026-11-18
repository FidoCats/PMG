extends BaseElectricalComponent #RigidBody3D
class_name ElectricalCrank



@export var EndTimer: Timer

#var ElectricalInput: float
#var ElectricalOutput: float
var IsCranking: bool = false
var CrankOutput: float = 12.0



func _ready() -> void:
	if not is_in_group("Electrical"):
		add_to_group("Electrical")
	
	EndTimer.timeout.connect(EndCrank)



func Interact(_Body: Node3D, _User: Node3D):
	IsCranking = true
	ElectricalOutput = CrankOutput
	var FinalRotation = rotation_degrees.z + 45
	for f in FinalRotation:
	#while rotation_degrees.z != FinalRotation:
		rotation_degrees.z = lerp(rotation_degrees.z, FinalRotation, 0.25)
	print(ElectricalOutput)
	EndTimer.start()
	#print(ElectricalOutput)
	#print("Crank Rotated")



func EndCrank():
	if IsCranking:
		ElectricalOutput = 0.0
		IsCranking = false
		#print("Crank Stopped")
