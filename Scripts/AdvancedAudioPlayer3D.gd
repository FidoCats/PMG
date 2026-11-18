extends AudioStreamPlayer3D
class_name AdvancedAudioPlayer3D



@export var Looping: bool = false



func _ready() -> void:
	if autoplay:
		Play.rpc()



@rpc("any_peer","call_local")
func Play(Stream: AudioStream = stream, TimeStamp: float = 0.0, PitchOffset: float = 1.5):
	stream = Stream
	pitch_scale = randf_range(1, PitchOffset)
	play(TimeStamp)
	await finished
	if Looping:
		Play.rpc()
		print("Looped!")
	#print("Played: ", Stream)



@rpc("any_peer","call_local")
func Pause():
	var PlayPos: float = get_playback_position()
	print("PlayPos: ", PlayPos)
	if playing:
		playing = false
	else:
		Play.rpc(stream,PlayPos)
