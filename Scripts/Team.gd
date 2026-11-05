extends Node
class_name Team



#var color: Color
#var max_players: int

var Properties: Dictionary = {
	"color" = Color(255,255,255),
	"max_players" = 0
}
var Players: Array = []



@rpc("any_peer","call_local")
func AddPlayer(node: Node):
	if Properties.get("max_players") != 0:
		if Players.max() <= Properties.get("max_players"):
			Players.append(node)
	elif Properties.get("max_players") == -1:
		pass
	else:
		Players.append(node)
