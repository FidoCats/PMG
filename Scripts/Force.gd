# Add this as a var using Force.new(), then set whichever variables you need and emit the  SetupFinished signal. :]

extends RayCast3D
class_name Force3D


signal SetupFinished

@export var DeleteAfterDone: bool = false
@export var UseTimer: bool = false
@export var TimerNode: Timer

@export var FinalPosition: Vector3
@export var StartPosition: Vector3
@export var F: float = 1.0

var Parent: Node3D



func _enter_tree() -> void:
	Parent = get_parent_node_3d()
	#global_position = StartPosition
	target_position = FinalPosition
	#await SetupFinished
	#if StartPosition == Vector3(0,0,0):
		#StartPosition = Parent.global_position
	#Move()
	#if UseTimer:
		#await TimerNode.timeout
		#queue_free()
	#if DeleteAfterDone and Parent.global_position == FinalPosition:
		#queue_free()



func Move() -> void:
	var TargetPosMarker = Marker3D.new()
	var DebugMarkerSprite = Sprite3D.new()
	add_child(TargetPosMarker)
	add_child(DebugMarkerSprite)
	#TargetPosMarker.transform.origin = Parent.transform.origin
	TargetPosMarker.global_position = Parent.global_position + target_position
	TargetPosMarker.look_at(-target_position)
	DebugMarkerSprite.global_transform = TargetPosMarker.global_transform
	DebugMarkerSprite.texture = load("res://Stuff/Images/FluffersDaCat.png")
	if Parent.global_position != target_position:
		#if Parent.global_transform != TargetPosMarker.global_transform:
			#Parent.look_at(TargetPosMarker.global_position)
		#Parent.global_transform = lerp(TargetPosMarker.global_transform, TargetPosMarker.global_transform, F * 0.01) # Doesnt LERP!!!!!!!! AAAAAAAAAAAAAAAAA
		
		
		
		#Parent.global_position = Vector3(lerp(Parent.global_position.x,TargetPosMarker.global_position.x,F * 0.1), lerp(Parent.global_position.y,TargetPosMarker.global_position.y,F * 0.1), lerp(Parent.global_position.z,TargetPosMarker.global_position.z,F * 0.1))
		#Parent.global_position = lerp(Parent.global_position, TargetPosMarker.global_position + Parent.global_position, F * 0.001)
		Parent.global_transform.origin = target_position
		
		Parent.look_at(TargetPosMarker.global_position)
		
		#Parent.global_position.z -= F
		
		print("Moved to: ", Parent.global_position, "Moved by: ", global_position)
	
