extends Node
class_name CollectComponent



@export var CollectableItemID: String = "FLASHLIGHT"

var CollectableItem



func _ready() -> void:
	CollectableItem = ItemDatabase.get_item(CollectableItemID)
	
	Player_interacted.connect(Collect)



func Collect(object: Node3D):
	
