@tool

extends RigidBody3D
class_name Seat3D



signal Used(User)
signal UnUsed(User)

@export_category("Prefrences")
@export var MeshColor: Color = Color(0.1,0.20,0.25,1)
@export var SpriteTexture: Texture2D = preload("res://Stuff/Images/Red_X.png")
@export var SizeOverride: bool = true
@export var Size: Vector3 = Vector3(0.85,0.50,0.85)
@export var UseTouch: bool = true
@export var UseInteract: bool = true
@export var JumpExit: bool = true
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
		MeshInstance.material_override.set("albedo_color", MeshColor)
		if SizeOverride and MeshInstance.mesh == BoxMesh:
			MeshInstance.mesh.set("size", Size)
	if CollisionShape and CollisionShape.shape == BoxShape3D:
		if SizeOverride:
			CollisionShape.shape.set("size", Size)
	if Area:
		Area.body_entered.connect(BodyEntered)
		Area.body_exited.connect(BodyExited)
	if AreaCollision and AreaCollision.shape == BoxShape3D:
		AreaCollision.shape.set("size", Vector3(Size.x,Size.y * 1.25, Size.z))
	if Sprite and SpriteTexture:
		Sprite.texture = SpriteTexture



func Interact(Parent: Node3D, User: Node3D) -> void:
	if UseInteract:
		Sit(User,Parent)



func Sit(_Who: Node3D, _OnWhat: Node3D = null) -> void:
	if _OnWhat == null:
		_OnWhat = self
	if _Who != null:
		if _Who.is_in_group("Alive") or _Who.is_class("Player"):
			if UsedBy == null and UsedBy != self:
				UsedBy = _Who
				Used.emit(_Who)
				UsedBy.global_position = _OnWhat.global_position
				if UsedBy.has_method("Sit"):
					UsedBy.Sit()
				#print("Parent: ", _OnWhat, "Player: ", _Who)
			else:
				UsedBy.global_position = Vector3(_OnWhat.global_position.x, _OnWhat.global_position.y + 2, _OnWhat.global_position.z)
				if UsedBy.has_method("UnCrouch"):
					UsedBy.UnCrouch()
				UnUsed.emit(null)
				UsedBy = null
				#print("Parent: ", _OnWhat, "Player: ", _Who)
			#print("Used By: ", UsedBy)



func BodyEntered(_body):
	if UseTouch:
		UsedBy = null
		Sit(_body,self)

func BodyExited(_body):
	if UseTouch:
		UsedBy = _body
		Sit(_body,self)



func _physics_process(_delta: float) -> void:
	if UsedBy != null:
		if UsedBy.is_in_group("Alive") or UsedBy.is_class("Player"):
			if UsedBy != self:
				if UsedBy.is_multiplayer_authority():
					if JumpExit:
						if Input.is_action_just_pressed("Jump") and JumpExit:
							Sit(UsedBy, self)
					if UsedBy != null:
						if UsedBy.has_method("Stop"):
							UsedBy.Stop()
							if UsedBy.has_method("Sit"):
								UsedBy.Sit()
						UsedBy.global_position = self.global_position
	
	if is_queued_for_deletion():
		Sit(UsedBy, self)
