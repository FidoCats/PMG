extends RigidBody3D



@export var DestroyEverything: bool = false
@export var Ray: RayCast3D

var _body: Node3D



func _process(_delta: float) -> void:
	_body = Ray.get_collider()
	if Input.is_action_just_pressed("LMB"):
		Fire()



func Fire():
	if _body != null:
		if DestroyEverything == true and not _body.is_in_group("Undeletable"):
			_body.queue_free()
		else:
			_body.queue_free()
