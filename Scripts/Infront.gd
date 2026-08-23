extends RayCast3D
class_name InfrontRayCast

var Infront: Node3D = null

func _process(_delta: float) -> void:
	Infront = get_collider()
