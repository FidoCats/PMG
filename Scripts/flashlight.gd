extends Node3D



@export var LightMesh: MeshInstance3D
@export var SpotLight: SpotLight3D



func _process(_delta: float) -> void:
	#if not get_parent().IsMultiplayerAuthority: return
	
	if Input.is_action_just_pressed("RMB") and visible == true:
		SpotLight.visible = false
		LightMesh.material_override.set("rim_enabled", false)
	elif Input.is_action_just_pressed("RMB") and visible == false:
		SpotLight.visible = true
		LightMesh.material_override.set("rim_enabled", true)
