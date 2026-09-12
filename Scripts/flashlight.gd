extends Node3D



@export var LightMesh: MeshInstance3D
@export var SpotLight: SpotLight3D

var FLASHLIGHT



func _ready() -> void:
	FLASHLIGHT = ItemDatabase.get_item("FLASHLIGHT")
	SpotLight.visible = FLASHLIGHT.special_value_1
	print(FLASHLIGHT.special_value_1)



func _process(_delta: float) -> void:
	#if not get_parent().IsMultiplayerAuthority: return
	
	#if Input.is_action_just_pressed("RMB") and visible == true:
		#SpotLight.visible = false
		#LightMesh.material_override.set("rim_enabled", false)
	#elif Input.is_action_just_pressed("RMB") and visible == false:
		#SpotLight.visible = true
		#LightMesh.material_override.set("rim_enabled", true)

	if Input.is_action_just_pressed("RMB") and SpotLight.visible == false:
		SpotLight.visible = true
		LightMesh.material_override.set("rim_enabled", true)
		FLASHLIGHT.special_value_1 = 1.0
	elif Input.is_action_just_pressed("RMB") and SpotLight.visible == true:
		SpotLight.visible = false
		LightMesh.material_override.set("rim_enabled", false)
		FLASHLIGHT.special_value_1 = 0.0
