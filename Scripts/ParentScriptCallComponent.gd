extends Node
class_name ParentScriptCallComponent



var Parent



func _ready() -> void:
	Parent = get_parent()
	if Parent is InteractionComponent:
		Parent.Player_interacted.connect(FireParentScript)



func _get_configuration_warnings() -> PackedStringArray:
	if Parent is not InteractionComponent:
		return["This  node needs an InteractionComponent parent."]
	else:
		return[]



func FireParentScript(_body: Node3D):
	if Parent.get_parent().has_method("Interact"):
		Parent.get_parent().Interact(_body)
		print("script fired")
	else:
		push_error("No Interact() method found in parent script!")
