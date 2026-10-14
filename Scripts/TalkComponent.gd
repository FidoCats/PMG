extends Node
class_name TalkComponent



@export var Lines: Array[String] = ["Hi."]
@export var Goodbye: String = "Bye."
@export var DeathMessage: String = "Owie-"
@export var AllowTouch: bool = true
@export var AllowInteract: bool = true
@export var Area: Area3D
@export var StopTimer: Timer
@export var SpeakLabel = Label3D
@export var SpeakerNode: Node3D



func _ready() -> void:
	if get_parent() is InteractionComponent:
		get_parent().Player_interacted.connect(Interact)
	if AllowTouch:
		Area.body_entered.connect(Touch)
		Area.body_exited.connect(TooFar)
	if SpeakerNode:
		if SpeakerNode.has_signal("Died"):
			SpeakerNode.Died.connect(Died)
	
	StopTimer.timeout.connect(TimeOut)
	
	SpeakLabel.text = ""



func Speak():
	var PickedLine = Lines.pick_random()
	SpeakLabel.text = str(PickedLine)
	StopTimer.start()



func Interact(_Body: Node3D, _User: Node3D):
	if AllowInteract:
		Speak()



func Touch(_Body):
	if AllowTouch:
		Speak()



func TimeOut():
	SpeakLabel.text = ""



func TooFar(_body):
	SpeakLabel.text = Goodbye
	await get_tree().create_timer(1).timeout
	SpeakLabel.text = ""



func Died():
	SpeakLabel.text = DeathMessage
	await get_tree().create_timer(1).timeout
	SpeakLabel.text = ""
