extends RayCast3D
class_name UnderRayCast

var Under: Node3D = null

func _process(_delta: float) -> void:
	Under = get_collider()
