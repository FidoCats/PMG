@tool

extends RigidBody3D
class_name Seat3D


@export_category("Prefrences")
@export var MeshColor: Color = Color(0.1,0.20,0.25,1)
@export var SpriteTexture: Texture2D = preload("res://Stuff/Images/Red_X.png")
@export var SizeOverride: bool = true
@export var Size: Vector3 = Vector3(0.85,0.50,0.85)
#@export var CustomMesh: Mesh = null
@export_category("Nodes")
@export var CollisionShape: CollisionShape3D
@export var MeshInstance: MeshInstance3D
@export var Sprite: Sprite3D
@export var Area: Area3D
@export var AreaCollision: CollisionShape3D

var UsedBy: Node3D



func _ready() -> void:
	if MeshInstance:
		MeshInstance.material_override.set("albedo", MeshColor)
		if SizeOverride and MeshInstance.mesh == BoxMesh:
			MeshInstance.mesh.set("size", Size)
	if CollisionShape and CollisionShape.shape == BoxShape3D:
		if SizeOverride:
			CollisionShape.shape.set("size", Size)
	if Area:
		Area.body_entered.connect(Sit)
		Area.body_exited.connect(Sit)
	if AreaCollision and AreaCollision.shape == BoxShape3D:
		AreaCollision.shape.set("size", Vector3(Size.x,Size.y * 1.25, Size.z))



func Interact(Parent: Node3D, User: Node3D) -> void:
	Sit(User,Parent)



func Sit(_Who: Node3D, _OnWhat: Node3D) -> void:
	if _OnWhat == null:
		_OnWhat = self
	if _Who != null:
		if _Who.is_in_group("Alive") or _Who.is_class("Player"):
			if UsedBy == null:
				UsedBy = _Who
				UsedBy.global_position = _OnWhat.global_position
				print("Parent: ", _OnWhat, "Player: ", _Who)
			else:
				UsedBy.global_position = Vector3(_OnWhat.global_position.x, _OnWhat.global_position.y + 1, _OnWhat.global_position.z)
				UsedBy = null
				print("Parent: ", _OnWhat, "Player: ", _Who)
	print("Used By: ", UsedBy)



func _physics_process(_delta: float) -> void:
	if UsedBy!= null:
		if UsedBy.is_multiplayer_authority():
			if not Input.is_action_pressed("Jump"):
				if UsedBy.has_method("freeze"):
					UsedBy.freeze()
				else:
					UsedBy.global_position = self.global_position
			elif Input.is_action_just_pressed("Jump"):
				Sit(UsedBy, self)
	
	if is_queued_for_deletion():
		Sit(UsedBy, self)
