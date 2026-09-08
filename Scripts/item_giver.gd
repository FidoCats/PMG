extends Node3D
class_name ItemGiver



@export_category("Item")
@export var ItemId: String = "USPM"
@export var ItemCount: int = 1
@export_category("Properties")
@export var CoolDownTime: float = 1.0
@export var Enabled: bool = true
@export_category("Nodes")
@export var Sprite: Sprite3D
@export var CollisionArea: Area3D
@export var NameLabel: Label3D
@export var PrintSprite: Sprite3D

var GivenItem: Item
var CanDispense: bool = true



func _ready() -> void:
	if Enabled == true:
		GivenItem = ItemDatabase.get_item(ItemId)
		Sprite.texture = GivenItem.icon
		NameLabel.text = GivenItem.name
		PrintSprite.texture = GivenItem.icon
		
		CollisionArea.body_entered.connect(Touched)



func Touched(_body: Node3D):
	if _body.is_class("get_inventory"):
		CanDispense = false
		var UserInventory: PlayerInventory = _body.player_inventory
		#var UserInventory: PlayerInventory = _body.get_inventory()
		PrintSprite.visible = true
		UserInventory.add_item(GivenItem)
		await get_tree().create_timer(CoolDownTime).timeout
		PrintSprite.visible = false
		CanDispense = true
		print("Dispensed!")



func Interact(_body: Node3D):
	Touched(_body)
	print("Interacted")
