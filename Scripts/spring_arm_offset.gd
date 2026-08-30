extends Node3D
class_name SpringArmCharacter



@export_category("Objects")
@export var _spring_arm: SpringArm3D = null

func _unhandled_input(_event) -> void:

	if (_event is InputEventMouseMotion) and is_multiplayer_authority():
		#rotate_y(-_event.relative.x * 0.005 * Global.Sensitivity)
		#_spring_arm.rotate_x(-_event.relative.y * 0.005 * Global.Sensitivity)
		#_spring_arm.rotation.x = clamp(_spring_arm.rotation.x, -PI/6, PI/36)
		
		if Input.is_action_pressed("MoveTPCamera"):
			#$"../..".rotation_degrees += rotation_degrees * _event.relative.x * 0.005 * Global.Sensitivity
			
			#rotation_degrees.y -= _event.screen_relative.x * 0.25 * Global.Sensitivity
			#_spring_arm.rotation_degrees.x -= _event.screen_relative.y * 0.25 * Global.Sensitivity
			#_spring_arm.rotation_degrees.x = clamp(_spring_arm.rotation_degrees.x,-90,90)
			_spring_arm.rotation_degrees.y -= _event.screen_relative.x * 0.25 * Global.Sensitivity
			#$"../..".rotation_degrees.y -= _event.screen_relative.x * 0.25 * Global.Sensitivity
		
			rotation_degrees = Vector3(0,0,0)
			_spring_arm.rotation_degrees.x -= _event.screen_relative.y * 0.25 * Global.Sensitivity
			_spring_arm.rotation_degrees.x = clamp(_spring_arm.rotation_degrees.x,-90,90)
