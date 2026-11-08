extends Panel



@onready var SpeedLabel = $Speed
@onready var CurrentSpeedLabel = $CurrentSpeed
@onready var ActionLabel = $CurrentAction
@onready var InfoPanel: Panel = $"../InfoPanel"
@onready var NoticabilityMeter: TextureProgressBar = $"../InfoPanel/Noticability"


var player: Player



func _ready() -> void:
	 #Vector2(0,0) #Vector2(320,225)
	#player = get_tree().edited_scene_root
	player = $"../../.."



func _process(_delta: float) -> void:
	if player:
		CurrentSpeedLabel.text = str("Speed: \n", snappedf(player.CurrentSpeed,0.01), " m/s")
		SpeedLabel.text = str("Max: \n", player.Speed, " m/s")
		
		var PlayerNoticability: float = player.Noticability
		NoticabilityMeter.value = PlayerNoticability
