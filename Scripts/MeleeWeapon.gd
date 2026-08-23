extends Node3D
class_name IsMelee



@export_category("Prefrences: ")
@export var Damage: float = 1.0
@export var StabTime: float = 0.25
@export var Cooldown: float = 0.5
@export_category("Nodes: ")
@export_category("(You still need to connect the body entered signal!!)")
@export var DamageArea: Area3D

var CanUse: bool = true



func _process(_delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	if Input.is_action_just_pressed("LMB"):
		if CanUse:
			Use()



func Use():
	CanUse = false
	DamageArea.monitoring = true
	await get_tree().create_timer(StabTime).timeout
	DamageArea.monitoring = false
	print("on cooldown")
	await get_tree().create_timer(Cooldown).timeout
	CanUse = true



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("TakeDamage"):
		body.TakeDamage(50.0)
		print("owie")
	
	#if body.has_method("React"):
		#body.React(Reactions.Angry)
		#print("whyd u do dat??? >:[")
