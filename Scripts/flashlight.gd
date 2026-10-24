extends RigidBody3D
class_name Flashlight



@export var Enabled: bool = false
@export var LightMesh: MeshInstance3D
@export var SpotLight: SpotLight3D
@export var Collect: CollectComponent
@export var Collider: CollisionShape3D
@export var AudioPlayer: AudioStreamPlayer3D
@export var OnSound: AudioStream
@export var OffSound: AudioStream

var FLASHLIGHT



func _ready() -> void:
	FLASHLIGHT = ItemDatabase.get_item("FLASHLIGHT")
	SpotLight.visible = FLASHLIGHT.special_value_1
	print(FLASHLIGHT.special_value_1)
	freeze = true



func _process(_delta: float) -> void:
	#if not get_parent().IsMultiplayerAuthority: return
	
	#if Input.is_action_just_pressed("RMB") and visible == true:
		#SpotLight.visible = false
		#LightMesh.material_override.set("rim_enabled", false)
	#elif Input.is_action_just_pressed("RMB") and visible == false:
		#SpotLight.visible = true
		#LightMesh.material_override.set("rim_enabled", true)

	if Input.is_action_just_pressed("RMB") and SpotLight.visible == false:
		Switch(true)
	elif Input.is_action_just_pressed("RMB") and SpotLight.visible == true:
		Switch(false)



func Switch(On: bool = true):
	SpotLight.visible = On
	LightMesh.material_override.set("rim_enabled", On)
	FLASHLIGHT.special_value_1 = float(On)
	if On == true:
		AudioPlayer.stream = OnSound
	else:
		AudioPlayer.stream = OffSound
	AudioPlayer.play()



func Enable(On: bool = false) -> bool:
	Enabled = On
	if Collect:
		Collect.Enabled = !On
	if is_class("RigidBody3D"):
		freeze = Enabled
		Collider.disabled = On
	return Enabled
