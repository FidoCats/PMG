@tool

extends Node
class_name PickUpComponent 

@export var pickup_distance : Vector3 = Vector3(0,0,-Global.ObjectDistance)

var parent
var IsPickedUp: bool = false
var picked_up : bool = false
var IsThrown: bool = false

const pickup_lerp : float = 0.175



func _ready() -> void:
	parent = get_parent()
	if parent is InteractionComponent:
		parent.Player_interacted.connect(update_state)

func _get_configuration_warnings() -> PackedStringArray:
	if parent is not InteractionComponent:
		return["This  node needs an InteractionComponent parent."]
	else:
		return[]

func _notification(what: int) -> void:
	if what == NOTIFICATION_ENTER_TREE:
		parent = get_parent()
		update_configuration_warnings()

func update_state(interactable: Node3D) -> void:
	if picked_up:
		if IsPickedUp == false:
			picked_up = false
			Global.object = null
			interactable.freeze = false
			IsPickedUp = true
	else:
		Global.object = interactable
		interactable.freeze = true
		picked_up = true
		IsPickedUp = false

func _physics_process(_delta: float) -> void:
	if picked_up:
		var camera_transform = Global.FPCamera.global_transform
		Global.object.global_transform = Global.object.global_transform.interpolate_with(camera_transform.translated_local(Vector3(0,0,-Global.ObjectDistance)),pickup_lerp)
		if Input.is_action_just_pressed("ObjectFreeze"):
					picked_up = false
					Global.object.global_position.z -= 0 
					Global.object = null
					IsPickedUp = false
	
	## Cant pickup stuff if standing on
	#Global.AboveRay.Above == Global.LookAtRay.LookingAt:
		#picked_up = false
		#Global.object = null
		#interactable.freeze = false
		#IsPickedUp = true
	
	## Other Features, so far unused

			#IsPickedUp = false
		#if Input.is_action_just_pressed("R"):
			#Global.object.global_rotate(Global.CurrentAxis,45.0)
		#pickup_distance = Vector3(0,0,-Global.ObjectDistance)
	#
	#if IsThrown == true:
		#Global.object.transform.basis = Global.FPCamera.transform.basis
		#Global.object.global_position.z -= 1
