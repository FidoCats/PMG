# Im stupid and cant make anything functional but dont take this as negative i love living its so fun!! /\ w /\ -Fido

#@tool might be the multiplayer issue

extends Node



signal Alive

var object: Node3D = null
var ObjectDistance: float = 2.5
var FPCamera: Camera3D
var HandsOccupied: bool = false

var Sensitivity: float = 1.0
var PlayerCharacterId: String = "Felmitt" # Default = "Felmitt"
var UseDebug: bool = true

var ProjectileSpawner: MultiplayerSpawner
var ObjectSpawner: MultiplayerSpawner
var MapNode: MultiplayerSpawner

var Damage: float = 0

# Da Leftovers (Someone come eat them plspls)




func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Fullscreen") and ProjectSettings.get_setting("display/window/size/mode") == 0:
		ProjectSettings.set_setting("display/window/size/mode", 4)
	elif Input.is_action_just_pressed("Fullscreen") and ProjectSettings.get_setting("display/window/size/mode") == 4:
		ProjectSettings.set_setting("display/window/size/mode", 0)
