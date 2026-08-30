extends RigidBody3D
var ForcePreload: PackedScene = preload("res://DevTestDemos/force_3d.tscn")



# Will cause problems, delete later!! ^^
func _ready() -> void:
	Global.ObjectSpawner = $"../MultiplayerSpawner"



func _process(_delta: float) -> void:
	$"../Label1".text = str("Pos: ", global_position, "Rot: ", global_rotation_degrees)
	if Input.is_action_just_pressed("ui_accept"):
		var Force: Force3D = ForcePreload.instantiate() as Force3D
		add_child(Force)
		#Force.FinalPosition = Vector3(randf(),randf(),randf())
		#Force.SetupFinished.emit()
		Force.Move()
		$"../Label2".text = str("Force: ", Force, "\n Force: ", Force.get_class())


func _on_v_slider_value_changed(_value: float) -> void:
	$"../Camera3D".fov = _value
