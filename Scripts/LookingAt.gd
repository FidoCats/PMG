extends RayCast3D
class_name LookAtRayCast

@export var ParentPlayer: Player

var LookingAt: Node3D = null



func _input(event):
	if ParentPlayer.is_multiplayer_authority():
		if event.is_action_pressed("Interact"):
			interact()



func interact():
	if LookingAt and LookingAt.has_user_signal("interacted"): 
		#LookingAt.player = ParentPlayer 
		LookingAt.emit_signal("interacted", ParentPlayer)



func _process(_delta: float) -> void:
	LookingAt = get_collider()
	
