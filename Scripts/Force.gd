## Add this as a var using Force.new(), then set whichever variables you need and emit the  SetupFinished signal. :]

extends RayCast3D
class_name Force3D


signal SetupFinished

@export var DeleteAfterDone: bool = true

@export var F: float = 1.0

@export var Velocity: Vector3 = Vector3(0,0,0)

var Parent: Node3D



func _enter_tree() -> void:
	if get_parent_node_3d().has_method("set_freeze_enabled"):
		Parent = get_parent_node_3d()
	
	debug_shape_custom_color = Color(0.5,0.55,0.85)
	debug_shape_thickness = 25
	position = Parent.global_position
	
	
	
	await SetupFinished
	
	target_position = Vector3.ZERO
	target_position.z = F



func Move() -> void:
	## The Actual Moving function
	if Parent:
		look_at(-Velocity)
		var UsedVelocity = Parent.transform.basis * Velocity * F
		if Parent.has_method("set_freeze_enabled"):
			Parent.linear_velocity = UsedVelocity
			print("UsedVelocity: \n", UsedVelocity)
		
		if DeleteAfterDone:
			await get_tree().create_timer(0.25).timeout
			queue_free()
