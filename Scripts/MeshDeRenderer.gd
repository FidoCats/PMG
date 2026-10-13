extends Node3D
class_name MeshUnRender



@export var AffectedNode: Node3D
@export var DelayTimer: Timer
@export var Delay: float = 1

var Authority: Node3D



func _ready() -> void:
	DelayTimer.timeout.connect(Update)
	DelayTimer.wait_time = Delay
	DelayTimer.start()



func _process(_delta: float) -> void:
	Authority = _get_local_player()



func Update():
	if Authority: #and AffectedNode and DelayTimer:
		if Authority.global_position.distance_to(AffectedNode.global_position) >= Global.RenderDistance:
			#if AffectedNode.visible == true:
				AffectedNode.visible = false
				#print("AN.vis == ", visible)
		else:
			#if AffectedNode.visible == false:
				AffectedNode.visible = true
				#print("AN.vis == ", visible)
		DelayTimer.start()
		#print("Updated!")



func _get_local_player() -> Player:
	var local_player_id = multiplayer.get_unique_id()
	if Global.PlayerContainer:
		if Global.PlayerContainer.has_node(str(local_player_id)):
			return Global.PlayerContainer.get_node(str(local_player_id)) as Player
		return null
	else:
		return null
