extends Node3D
class_name CollisionNoise



signal Sense(_Body: Node3D)

@export var AffectedNode: RigidBody3D
@export var MaxCollisonCount: int = 1
@export var CollisionSoundPlayer: AudioStreamPlayer3D
@export var ParticleMaker: GPUParticles3D
@export var MeshNode: MeshInstance3D

var CurrentNoise: int = 0
#var CurrentVisibility: int = 0
var Noticability: int = 0



func _ready() -> void:
	if AffectedNode:
		AffectedNode.contact_monitor = true
		AffectedNode.max_contacts_reported = MaxCollisonCount
		AffectedNode.body_entered.connect(Collide)
		AffectedNode.add_user_signal("Sense")
	if ParticleMaker:
		ParticleMaker.one_shot = true
		if MeshNode:
			ParticleMaker.draw_pass_1.surface_set_material(0,MeshNode.mesh.get("material"))
	if CollisionSoundPlayer:
		CollisionSoundPlayer.finished.connect(EndSound)
	add_to_group("Alive")



func Collide(_body: Node3D):
	if AffectedNode.linear_velocity.length() > 5 / AffectedNode.mass:
		if _body.has_method("TakeDamage"):
			_body.TakeDamage.rpc(AffectedNode.linear_velocity.length() * AffectedNode.mass / 4)
	
	if CollisionSoundPlayer:
		if AffectedNode.has_method("set_linear_velocity"):
			if AffectedNode.linear_velocity.length() > 1:
				CollisionSoundPlayer.play()
		else:
			CollisionSoundPlayer.play()
	if ParticleMaker:
		ParticleMaker.restart()
	
	CurrentNoise = 5
	Noticability = CurrentNoise
	#print(AffectedNode.Noticability)
	#if AffectedNode.is_in_group("Alive"):
		#print("I AM ALIVE")
	
	#AffectedNode.Sense.emit(AffectedNode)



## The Node is Undetectable, it needs to Be a CollisionBody
func EndSound():
	CurrentNoise = 0
	Noticability = CurrentNoise
