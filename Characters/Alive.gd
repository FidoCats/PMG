extends CharacterBody3D
class_name Alive



signal Died

@export_category("Prefrences")
@export var CanRespawn: bool = true
@export var RespawnPos: Vector3 = Vector3(0,15,0)
@export var RespawnTime: float = 1.5
@export var UseNoticableOverride: bool = true
@export var VisibilityOverride: int = 3
@export var NoiseOverride: int = 3 
@export_category("Properties")
@export var Health: float = 100.0
@export var MaxHealth: float = 100.0
@export_category("Nodes")
@export var RespawnSoundPlayer: AudioStreamPlayer3D
@export_category("Resources")
@export var RespawnAudio: AudioStream

var CurrentNoise: int = 1
var CurrentVisibility: int = 1
var Noticability: int = 1

var IsDead: bool = false



func _ready() -> void:
	if not is_in_group("Alive"):
		add_to_group("Alive")
	
	RespawnPos += global_position



func _process(_delta: float) -> void:
	if UseNoticableOverride:
		CurrentNoise = NoiseOverride
		CurrentVisibility = VisibilityOverride
	Noticability = CurrentNoise + CurrentVisibility



func TakeDamage(Damage: float):
	Health -= Damage



func Death():
	IsDead = true
	Died.emit()
	velocity = Vector3.ZERO
	RespawnSoundPlayer.stream = RespawnAudio
	RespawnSoundPlayer.play()
	if CanRespawn:
		await get_tree().create_timer(RespawnTime).timeout
		ResetValues()



func ResetValues():
	Health = MaxHealth
	global_transform.origin = RespawnPos
	velocity = Vector3.ZERO
	rotation = Vector3(0,0,0)
	IsDead = false
	global_position = RespawnPos
	RespawnSoundPlayer.stream = RespawnAudio
	RespawnSoundPlayer.play()
	set_process(true)
	set_physics_process(true)
	#print(self, " Reset!")
	#print(self, " Can Process: ", can_process())
