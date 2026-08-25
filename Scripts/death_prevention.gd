extends Area3D



func _on_body_entered(_body: Node3D) -> void:
	if _body.has_method("Death"):
		_body.Death()
	else:
		if not _body.is_class("Area3D"):
			_body.position = Vector3(0,5,0)
