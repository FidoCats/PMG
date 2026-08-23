extends RayCast3D
class_name LookAtRayCast

var LookingAt: Node3D = null



func interact():
	if LookingAt and LookingAt.has_user_signal("interacted"): 
		LookingAt.emit_signal("interacted")

func _input(event):
	if event.is_action_pressed("Interact"):
		interact()



func _process(_delta: float) -> void:
	LookingAt = get_collider()
