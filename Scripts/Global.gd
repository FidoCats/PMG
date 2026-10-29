# Im stupid and cant make anything functional but dont take this as negative i love living its so fun!! /\ w /\ -Fido

#@tool might be the multiplayer issue

extends Node



#signal Alive


var ObjectDistance: float = 2.5
var FPCamera: Camera3D
var HandsOccupied: bool = false

var Sensitivity: float = 1.0
var PlayerCharacterId: String = "Felmitt" # Default = "Felmitt"
var RenderDistance: float = 50
var UseDebug: bool = true

var ProjectileSpawner: Node3D
var ProjectileSyncronizer: MultiplayerSpawner
var ObjectSpawner: Node3D
var ObjectSyncronizer: MultiplayerSpawner
var MapNode: Node3D
var BlockGrid: GridMap
var StructureSpawner
var PlayerContainer: Node3D

## Da Leftovers (Someone come eat them plspls)
var Damage: float = 0
var object: Node3D = null



func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed("Fullscreen") and ProjectSettings.get_setting("display/window/size/mode") == 0:
		#ProjectSettings.set_setting("display/window/size/mode", 4)
		#ProjectSettings.save()
	#elif Input.is_action_just_pressed("Fullscreen") and ProjectSettings.get_setting("display/window/size/mode") == 4:
		#ProjectSettings.set_setting("display/window/size/mode", 0)
		#ProjectSettings.save()
	
	if Input.is_action_just_pressed("Fullscreen") and get_window().mode == Window.MODE_WINDOWED:
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	elif Input.is_action_just_pressed("Fullscreen") and get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
		get_window().mode = Window.MODE_WINDOWED
