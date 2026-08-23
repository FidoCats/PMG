extends RigidBody3D



var ExplodeTimer: SceneTreeTimer
var HasExploded: bool = false
var IsThrown: bool = false
var Parent



func _ready() -> void:

	Parent = get_parent()
	await get_tree().create_timer(0.05).timeout
	IsThrown = true
	
	ExplodeTimer = get_tree().create_timer(3)

	rotation.y = 0.0
	await ExplodeTimer.timeout
	HasExploded = true
	$Area3D.monitoring = true
	await get_tree().create_timer(0.1).timeout
	queue_free()



# Need to make Transform origin be Player Holding
func _physics_process(delta: float) -> void:
	var CollisionCount = get_contact_count()
	rotation.x = 0.0
	rotation.z = 0.0
	if CollisionCount < 1 and IsThrown == true:
		position += transform.basis.z * 5 * delta
	else:
		position -= Vector3(0,0,0)

	if IsThrown == true:
		$Label3D.text = str(snapped(ExplodeTimer.time_left,0.1))



func Explode():
	HasExploded = true



func _on_area_3d_body_entered(_body: Node3D) -> void:
	if HasExploded == true:
		if _body.is_class("RigidBody3D"):
			_body.global_position += Vector3(randf_range(-2.5,2.5),1,randf_range(-2.5,2.5)) / _body.scale
		if _body.has_method("Death"):
			_body.Death()
		if _body.has_method("Explode"):
			_body.Explode()
