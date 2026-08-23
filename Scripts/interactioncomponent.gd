# Tis the Tutorial mans making AKA:
# DO NOT UNDER ANY CIRCUMSTANCE MESS WITH IT!
# heh nah jus kidding its messable with :3
# also there is no one here who am i talking to??§

extends Node
class_name InteractionComponent

var parent
var InteractTip = "E to interact"

signal Player_interacted(object: Node3D)

func _ready() -> void:
	parent = get_parent()
	Connect_parent()

func _process(_delta: float) -> void:
	if not is_multiplayer_authority(): return

func Interact() -> void:
	Player_interacted.emit(parent)
	print("Interacted with ", parent)

func Connect_parent() -> void:
	parent.add_user_signal("interacted")
	
	parent.connect("interacted",Callable(self, "Interact"))
