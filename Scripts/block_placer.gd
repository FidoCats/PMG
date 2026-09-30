extends Node3D



@export var Sprite: Sprite3D
@export var RayCast: RayCast3D
@export var BlockLibrary: MeshLibrary
@export var PlacementGrid: GridMap = Global.BlockGrid
@export var PlaceCoolDown: float = 0.1
@export var BreakCoolDown: float = 0.1

var CanPlace: bool = true
var CanBreak: bool = true
var Items
var CurrentItem: int = 0
var Block
var CurrentCell



func _enter_tree() -> void:
	PlacementGrid.mesh_library = BlockLibrary
	Items = BlockLibrary.get_item_list() as Array



func _process(_delta: float) -> void:
	Items = BlockLibrary.get_item_list() as Array
	Block = BlockLibrary.get_item_mesh(CurrentItem)
	CurrentCell = PlacementGrid.get_cell_item(Vector3i(RayCast.get_collision_point()))
	
	if Input.is_action_just_pressed("WheelUp"):
		CurrentItem += 1
	if Input.is_action_just_pressed("WheelDown"):
		CurrentItem -= 1
	if Input.is_action_pressed("LMB") and CanBreak:
		CanBreak = false
		if CurrentCell != -1:
			CurrentCell = -1
			print(CurrentCell)
		await get_tree().create_timer(BreakCoolDown).timeout
		CanBreak = true
	if Input.is_action_pressed("RMB") and CanPlace:
		CanPlace = false
		if CurrentCell == -1:
			CurrentCell = Block
			print(CurrentCell)
			await get_tree().create_timer(PlaceCoolDown).timeout
		CanPlace = true
