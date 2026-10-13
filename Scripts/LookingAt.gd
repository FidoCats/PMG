extends RayCast3D
class_name LookAtRayCast

@export var ParentPlayer: Player

var LookingAt: Node3D = null



func _ready() -> void:
	target_position.z = ParentPlayer.InteractDistance	



func _process(_delta: float) -> void:
	LookingAt = get_collider()
	if ParentPlayer.is_multiplayer_authority():
		if Input.is_action_pressed("Interact"):
			interact()



func interact():
	if ParentPlayer.CanInteract:
		if LookingAt and LookingAt.has_user_signal("interacted"): 
			ParentPlayer.CanInteract = false
			LookingAt.emit_signal("interacted", ParentPlayer)
			await get_tree().create_timer(ParentPlayer.InteractCoolDown).timeout
			ParentPlayer.CanInteract = true
