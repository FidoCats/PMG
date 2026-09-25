# Tis the Tutorial mans making AKA:
# DO NOT UNDER ANY CIRCUMSTANCE MESS WITH IT!
# heh nah jus kidding its messable with :3
# also there is no one here who am i talking to??§

@tool

extends Node
class_name InteractionComponent

var parent
#var player

var InteractTip = "E to interact"

signal Player_interacted(object: Node3D, who: Node3D)

func _ready() -> void:
	parent = get_parent()
	Connect_parent()

func _get_configuration_warnings() -> PackedStringArray:
	if parent is not RigidBody3D or parent is not StaticBody3D or parent is not RigidBody2D or parent is not StaticBody2D or not parent.is_in_group("Interactable"):
		return["Parent Node is not an Aplicable Node or is null!"]
	else:
		return[]

func _process(_delta: float) -> void:
	if not is_multiplayer_authority(): return

func Interact(User: Node3D) -> void:
	Player_interacted.emit(parent, User)
	print(User, " interacted with ", parent)

func Connect_parent() -> void:
	parent.add_user_signal("interacted")
	
	parent.connect("interacted",Callable(self, "Interact"))
