extends Node3D
class_name CollisionNoise




@export var AffectedNode: RigidBody3D
@export var MaxCollisonCount: int = 1
@export var CollisionSoundPlayer: AudioStreamPlayer3D
@export var ParticleMaker: GPUParticles3D
@export var MeshNode: MeshInstance3D



func _ready() -> void:
	AffectedNode.contact_monitor = true
	AffectedNode.max_contacts_reported = MaxCollisonCount
	AffectedNode.body_entered.connect(Collide)
	ParticleMaker.one_shot = true
	ParticleMaker.draw_pass_1.surface_set_material(0,MeshNode.mesh.get("material"))



func Collide(_body: Node3D):
	if AffectedNode.linear_velocity.length() > 5 / AffectedNode.mass:
		if _body.has_method("TakeDamage"):
			_body.TakeDamage.rpc(AffectedNode.linear_velocity.length() * AffectedNode.mass / 4)
	
	CollisionSoundPlayer.play()
	ParticleMaker.restart()
