extends Node3D

# No worky yet. :[

func _on_save_pressed() -> void:
	add_child(Global.SpawnedObjects)
	var Path = "res://Saves/Build.tscn"
	if not FileAccess.file_exists(Path):
		print("thing not found :[")
		return
	var SavedScene = load(Path) as PackedScene
	if SavedScene:
		var NodeTree = SavedScene.instantiate()
		get_tree().root.add_child(NodeTree)
	else:
		print("has not been loaded")
	
func _on_load_pressed() -> void:
	var RootNode:Node = $"."
	var Path: String
	Path = "res://Saves/Build.tscn"
	var Scene = PackedScene.new()
	for child in RootNode.get_children():
		child.owner = RootNode
	var result = Scene.pack(RootNode)
	if result == OK:
		ResourceSaver.save(Scene,Path)
