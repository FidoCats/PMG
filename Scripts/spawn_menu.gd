extends Control



func _process(_delta: float) -> void:
	if not is_multiplayer_authority():
		visible = false
	
	if $"..".InputBlocked == false:
		if Input.is_action_just_pressed("Spawnmenu") and visible == false:
			visible = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.is_action_just_pressed("Spawnmenu") and visible == true:
			visible = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



func _on_categories_tab_clicked(_tab: int) -> void:
	if _tab == 0:
		$Props.visible = true
	else:
		$Props.visible = false
	if _tab == 1:
		$Melee.visible = true
	else:
		$Melee.visible = false
	if _tab == 2:
		$Guns.visible = true
	else:
		$Guns.visible = false
	if _tab == 3:
		$Items.visible = true
	else:
		$Items.visible = false
	if _tab == 4:
		$Entities.visible = true
	else:
		$Entities.visible = false
	if _tab == 5:
		$NPCs.visible = true
	else:
		$NPCs.visible = false
	if _tab == 6:
		$Others.visible = true
	else:
		$Others.visible = false



@onready var BoxPreload = preload("res://Scenes/box.tscn") 
@onready var BigBoxPreload = preload("res://Scenes/LargeBox.tscn")
func _on_props_item_clicked(_index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	match _index:
		0:
			var Box: Node3D = BoxPreload.instantiate()
			Global.ObjectSpawner.add_child(Box)
			Box.global_position = $"../FPCamera".global_position
			Box.global_basis = $"../FPCamera".global_basis
			Box.global_position.z -= 2.5
		1:
			var BigBox: Node3D = BigBoxPreload.instantiate()
			Global.ObjectSpawner.add_child(BigBox)
			BigBox.global_position = $"../FPCamera".global_position
			BigBox.global_basis = $"../FPCamera".global_basis
			BigBox.global_position.z -= 2.5

func _on_melee_item_clicked(_index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	var CurrentPlayerInventory: PlayerInventory = $"..".player_inventory
	match _index:
		0:
			var spear = ItemDatabase.get_item("SPEAR")
			CurrentPlayerInventory.add_item(spear)

func _on_guns_item_clicked(_index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	var CurrentPlayerInventory: PlayerInventory = $"..".player_inventory
	match _index:
		0:
			var uspm = ItemDatabase.get_item("USPM")
			CurrentPlayerInventory.add_item(uspm)
		1:
			var m870 = ItemDatabase.get_item("M870")
			CurrentPlayerInventory.add_item(m870)

@onready var WeedFishPreload = preload("res://Scenes/seaweed.tscn")
func _on_entities_item_clicked(_index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	match _index:
		0:
			var WeedFish: Node3D = WeedFishPreload.instantiate()
			Global.ObjectSpawner.add_child(WeedFish)
			WeedFish.global_position = $"../FPCamera".global_position
			WeedFish.global_basis = $"../FPCamera".global_basis
			WeedFish.global_position.z -= 2.5

func _on_npcs_item_clicked(_index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	pass

func _on_items_item_clicked(_index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	var CurrentPlayerInventory: PlayerInventory = $"..".player_inventory
	match _index:
		0:
			var flashlight = ItemDatabase.get_item("FLASHLIGHT")
			CurrentPlayerInventory.add_item(flashlight)

func _on_others_item_clicked(_index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	pass

@onready var BallpitMapPreload = preload("res://Scenes/Maps/ball_pit.tscn")
@onready var KingdomsMapPreload = preload("res://Scenes/Maps/kingdoms.tscn")
@onready var IslandTownPreload = preload("res://Scenes/Maps/m2_island_town.tscn")
func _on_maps_item_clicked(_index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	#if $"..".IsAdmin == true:
		match _index:
			0:
				#if Global.MapNode.get_child_count() > 0:
					#Global.MapNode.remove_child(get_child(0))
				#var MapNode: Node3D = Global.MapNode.spawn_path
				$"..".Teleport($"..", Vector3(0,25,0))
			1:
				#if Global.MapNode.get_child_count() > 0:
					#Global.MapNode.remove_child(get_child(0))
				#var BallpitMap: Node3D = BallpitMapPreload.instantiate()
				#Global.MapNode.add_child(BallpitMap)
				$"..".Teleport($"..", Vector3(500,5,0))
			2:
				#if Global.MapNode.get_child_count() > 0:
					#Global.MapNode.remove_child(get_child(0))
				#var KingdomsMap: Node3D = KingdomsMapPreload.instantiate()
				#Global.MapNode.add_child(KingdomsMap)
				$"..".Teleport($"..", Vector3(0,25,200))
			3:
				#if Global.MapNode.get_child_count() > 0:
					#Global.MapNode.remove_child(get_child(0))
				#var IslandTown: Node3D = IslandTownPreload.instantiate()
				#Global.MapNode.add_child(IslandTown)
				$"..".Teleport($"..", Vector3(0,25,-2000))
			4:
				#if Global.MapNode.get_child_count() > 0:
					#Global.MapNode.remove_child(get_child(0))
				#var IslandTown: Node3D = IslandTownPreload.instantiate()
				#Global.MapNode.add_child(IslandTown)
				$"..".Teleport($"..", Vector3(-200,25,0))




func _on_close_pressed() -> void:
	$".".visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
