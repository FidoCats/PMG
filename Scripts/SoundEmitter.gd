extends BaseElectricalComponent
class_name SoundEmitter



@export var Looping: bool = false
@export var Stream: AudioStream
@export var AudioPlayer: AdvancedAudioPlayer3D

var HasPlayed: bool = false



func _process(_delta: float) -> void:
	AudioPlayer.Looping = Looping
	
	if ElectricalInput > 0.0:
		if not AudioPlayer.playing:
			if not Looping:
				if not HasPlayed:
					HasPlayed = true
					AudioPlayer.Play.rpc(Stream,0.0,1)
			#else:
				#AudioPlayer.Play(Stream,0.0,1)
	
		
		if IsPowered:
			AudioPlayer.pitch_scale = 1
		else:
			var PitchCalc = (1+(((MaxInput - MinInput)-ElectricalInput) / 2))
			if PitchCalc > 0.0:
				AudioPlayer.pitch_scale = PitchCalc
			else:
				AudioPlayer.pitch_scale = 1.0
	
	else:
		HasPlayed = false
		AudioPlayer.playing = false
