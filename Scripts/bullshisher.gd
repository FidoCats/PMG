extends RigidBody3D



@export var SceneTable: Array[PackedScene]
@export var Spawner: Marker3D



func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("LMB"):
		var ChosenScene: PackedScene = SceneTable.pick_random()
		match ChosenScene.resource_name:
			_:
				pass
		
		if ChosenScene != null:
			var Scene: Node3D = ChosenScene.instantiate()
			Global.ProjectileSpawner.add_child(Scene)
			Scene.global_transform = Spawner.global_transform
