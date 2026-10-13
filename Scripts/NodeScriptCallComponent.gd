@tool

extends Node
class_name NodeScriptCallComponent



@export var DesiredNode: Node3D



func _ready() -> void:
	if get_parent() is InteractionComponent:
		get_parent().Player_interacted.connect(FireNodeScript)



func _get_configuration_warnings() -> PackedStringArray:
	if get_parent() is not InteractionComponent:
		return["This  node needs an InteractionComponent parent."]
	else:
		return[]



func FireNodeScript(_body: Node3D, _user: Node3D):
	if DesiredNode.has_method("Interact"):
		DesiredNode.Interact(_body, _user)
		print("script fired")
	else:
		push_error("No Interact() method found in DesiredNode script!")
