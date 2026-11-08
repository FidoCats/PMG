extends RigidBody3D
class_name IsMelee



@export_category("Prefrences: ")
@export var Damage: float = 20.0
@export var StabTime: float = 0.25
@export var Cooldown: float = 0.5
@export_category("Nodes: ")
@export var DamageArea: Area3D

var CanUse: bool = true



func _ready() -> void:
	DamageArea.body_entered.connect(_on_area_3d_body_entered)



func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("LMB"):
		Use()



func Use():
	if CanUse:
		CanUse = false
		DamageArea.monitoring = true
		await get_tree().create_timer(StabTime).timeout
		DamageArea.monitoring = false
		print("on cooldown")
		await get_tree().create_timer(Cooldown).timeout
		CanUse = true



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("TakeDamage"):
		body.TakeDamage.rpc(Damage)
		print("owie")
	
	#if body.has_method("React"):
		#body.React(Reactions.Angry)
		#print("whyd u do dat??? >:[")
