extends RayCast3D
class_name AboveRayCast

var Above: Node3D = null

func _process(_delta: float) -> void:
	Above = get_collider()
