extends Panel



@onready var SpeedLabel = $Speed
@onready var CurrentSpeedLabel = $CurrentSpeed
@onready var ActionLabel = $CurrentAction
@onready var InfoPanel: Panel = $"../InfoPanel"
@onready var NoticabilityMeter: TextureProgressBar = $"../InfoPanel/Noticability"

var DesiredPosition: Vector2
var player: Player



func _ready() -> void:
	DesiredPosition = position
	#player = get_tree().edited_scene_root
	player = $"../../.."



func _process(_delta: float) -> void:
	if DesiredPosition:
		if position != DesiredPosition:
			position.x = lerp(position.x, DesiredPosition.x + player.velocity.x, player.CurrentSpeed)
			position.y = lerp(position.y, DesiredPosition.y + player.velocity.z, player.CurrentSpeed)
		elif position != DesiredPosition and player.CurrentSpeed < 5.0:
			position = lerp(position, DesiredPosition, player.velocity.x) #Vector2(player.velocity.x,player.velocity.y))
	if player:
		CurrentSpeedLabel.text = str("Speed: \n", snappedf(player.CurrentSpeed,0.01), " m/s")
		SpeedLabel.text = str("Max: \n", player.Speed, " m/s")
		
		var PlayerNoticability: float = player.Noticability
		NoticabilityMeter.value = PlayerNoticability
