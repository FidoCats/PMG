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
	
	if Health <= 0.0 and not IsDead:
		Death()



@rpc("any_peer","call_remote")
func TakeDamage(Damage: float):
	Health -= Damage



@rpc("any_peer","call_remote")
func Death():
	IsDead = true
	Died.emit()
	if Global.UseDebug:
		print(self, " Died!!")
	if CanRespawn:
		await get_tree().create_timer(RespawnTime).timeout
		if IsDead:
			#ResetCharacter()
			ResetValues()



@rpc("any_peer","call_remote")
func ResetValues():
	Health = MaxHealth
	global_transform.origin = RespawnPos
	velocity = Vector3.ZERO
	rotation = Vector3(0,0,0)
	global_position = RespawnPos
	#await RespawnAudioStream.finished
	RespawnSoundPlayer.stream = RespawnAudio
	set_process(true)
	set_physics_process(true)
	if Global.UseDebug:
		print(self, " Reset!")
		print(self, " Can Process: ", can_process())
	IsDead = false
