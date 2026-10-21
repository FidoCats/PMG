#@tool

extends Node
class_name PickUpComponent 

@export var pickup_distance : Vector3 = Vector3(0,0,-Global.ObjectDistance)

var parent
var IsPickedUp: bool = false
var picked_up : bool = false
var IsThrown: bool = false
var player: Node3D
var object: Node3D = null

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

#@rpc("authority", "call_remote", "reliable", 0)
func update_state(interactable: Node3D, interactor: Node3D) -> void:
	
	if picked_up: # this is place
		if IsPickedUp == false:
			picked_up = false
			object = null
			interactable.freeze = false
			IsPickedUp = true
			player = interactor
	else: # this is pick up
		object = interactable
		interactable.freeze = true
		picked_up = true
		IsPickedUp = false
		player = null

func _physics_process(_delta: float) -> void:
	if picked_up:
		if object != null:
			var camera_transform = Global.FPCamera.global_transform
			object.global_transform = object.global_transform.interpolate_with(camera_transform.translated_local(Vector3(0,0,-Global.ObjectDistance)),pickup_lerp)
			if Input.is_action_just_pressed("ObjectFreeze"):
						picked_up = false
						object.global_position.z -= 0 
						object = null
						IsPickedUp = false
			if Input.is_action_just_pressed("Parry"):
				picked_up = false
				if object.has_method("is_freeze_enabled"):
					object.freeze = false
				object = null
				IsPickedUp = false
	
	
	## Other Features, so far unused
		## Cant pickup stuff if standing on
			#Global.UnderRay.Under == Global.LookAtRay.LookingAt:
				#picked_up = false
				#object = null
				#interactable.freeze = false
				#IsPickedUp = true
			
			#IsPickedUp = false
		#if Input.is_action_just_pressed("R"):
			#object.global_rotate(Global.CurrentAxis,45.0)
		#pickup_distance = Vector3(0,0,-objectDistance)
	#
	#if IsThrown == true:
		#object.transform.basis = Global.FPCamera.transform.basis
		#object.global_position.z -= 1
