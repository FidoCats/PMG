extends RigidBody3D



@export var MaxCollisonCount: int = 1
@export var CollisionSoundPlayer: AudioStreamPlayer3D
@export var ParticleMaker: GPUParticles3D
@export var MeshNode: MeshInstance3D



func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = MaxCollisonCount
	body_entered.connect(Collide)
	ParticleMaker.one_shot = true
	ParticleMaker.draw_pass_1.surface_set_material(0,MeshNode.mesh.get("material"))



func Collide(_body):
	CollisionSoundPlayer.play()
	ParticleMaker.restart()
