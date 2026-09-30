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
		if CanDispense:
			NameLabel.text = GivenItem.name
		else:
			NameLabel.text = "Please wait..."
		PrintSprite.texture = GivenItem.icon
		
		CollisionArea.body_entered.connect(Touched)



func Use(_body: Node3D, _user: Node3D):
	if CanDispense:
		if _user.has_method("get_inventory") or _user.is_class("Player"):
			CanDispense = false
			#var UserInventory: PlayerInventory = _user.get_inventory()
			var UserInventory: PlayerInventory = _user.player_inventory
			print(UserInventory)
			PrintSprite.visible = true
			UserInventory.add_item(GivenItem)
			await get_tree().create_timer(CoolDownTime).timeout
			PrintSprite.visible = false
			CanDispense = true
			print("Dispensed!")



func Touched(_body: Node3D):
	Use(self, _body)



func Interact(_body: Node3D, _user: Node3D):
	Use(_body, _user)
	#print("Interacted")
