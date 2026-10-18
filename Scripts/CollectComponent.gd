extends Node
class_name CollectComponent



@export var Enabled: bool = false
@export var CollectableItemID: String = "FLASHLIGHT"



func _ready() -> void:
	if get_parent() is InteractionComponent:
		get_parent().Player_interacted.connect(Collect)



func Collect(_Body: Node3D, _User: Node3D):
	var item = ItemDatabase.get_item(CollectableItemID)
	var inventory: PlayerInventory = _User.player_inventory
	inventory.add_item(item)
	await get_tree().create_timer(0.1).timeout
	get_parent().get_parent().queue_free()
