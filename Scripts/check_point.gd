extends StaticBody3D

var CPPos: Vector3 = Vector3(0, 0, 0)



func _process(_delta: float) -> void:
	CPPos = Vector3(get_parent().global_position.x, (get_parent().global_position.y + 1.0), get_parent().global_position.z)



func _on_area_3d_body_entered(_body: Node3D) -> void:
	if _body.has_method("ResetValues"):
		_body.RespawnPos = CPPos
		print("Set ", _body.name, "'s Respawn position to ", CPPos)
		print("RespawnPos: ", _body.RespawnPos)
	else:
		pass
