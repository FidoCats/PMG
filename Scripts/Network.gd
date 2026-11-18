extends Node

@export var PlayerScene: PackedScene = preload("res://Characters/Player.tscn")

var SERVER_ADDRESS: String = "127.0.0.1"
var SERVER_PORT: int = 1234 #8080
var MAX_PLAYERS : int = 10

#var EnetPeer = ENetMultiplayerPeer.new()

## Gamerules? -Fido :3
var UseDayNightCycle: bool = true
var KeepInventory: bool = false
var SpawnRadius: float = 10

var Players: Array[Node]
var players = {}
var player_info = {
	"nick" : "host",
	"skin" : Color(0,0,0,0),
	"species" : Player.SpeciesEnum.Felmitt,
	"team": Team.new(),
	"team_color": Team.new().Properties.get("color"),
	"op": true,
	"spawnperms": true
}

#signal player_connected(peer_id, player_info)
#signal server_disconnected
signal PlayerConnect(PeerID, PlayerInfo)
signal PlayerDisconnect(PeerID, PlayerInfo)
signal ServerDisconnect

var NameArray:Array[String] = ["Goobus","wawa","ethio","Amsterdam","Copperliscious","Blue","Orange","Oblong","Shape","Lithium","Uranium","Thermonuclear","John"]



#func _ready() -> void:
	#multiplayer.server_disconnected.connect(_on_connection_failed)
	#multiplayer.connection_failed.connect(_on_server_disconnected)
	#multiplayer.peer_disconnected.connect(_on_player_disconnected)
	#multiplayer.peer_connected.connect(_on_player_connected)
	#multiplayer.connected_to_server.connect(_on_connected_ok)
#
#func start_host(nickname: String, skin_color_str: Color):#, species: Player.SpeciesEnum):
	#var peer = ENetMultiplayerPeer.new()
	#var error = peer.create_server(SERVER_PORT, MAX_PLAYERS)
	#if error:
		#return error
	#multiplayer.multiplayer_peer = peer
#
	#if !nickname or nickname.strip_edges() == "":
		#nickname = "Host_" + str(multiplayer.get_unique_id())
#
	#player_info["nick"] = nickname
	#player_info["skin"] = skin_color_str #skin_str_to_e(skin_color_str)
##	player_info["species"] = species
	#
	#if DisplayServer.get_name() == "headless":
		#return
#
	#players[1] = player_info
	#player_connected.emit(1, player_info)
#
#func join_game(nickname: String, skin_color_str: Color, address: String = SERVER_ADDRESS):
	#var peer = ENetMultiplayerPeer.new()
	#var error = peer.create_client(address, SERVER_PORT)
	#if error:
		#return error
#
	#multiplayer.multiplayer_peer = peer
#
	#if !nickname or nickname.strip_edges() == "":
		#nickname = "Player_" + str(multiplayer.get_unique_id())
#
	##var skin_enum = skin_str_to_e(skin_color_str)
#
#
#
	#player_info["nick"] = nickname
	#player_info["skin"] = skin_color_str
	##player_info["species"] = species
#
#func _on_connected_ok():
	#var peer_id = multiplayer.get_unique_id()
	#players[peer_id] = player_info
	#player_connected.emit(peer_id, player_info)
#
#func _on_player_connected(id):
	#if DisplayServer.get_name() == "headless":
		#return
	#_register_player.rpc_id(id, player_info)
#
#@rpc("any_peer", "reliable")
#func _register_player(new_player_info):
	#var new_player_id = multiplayer.get_remote_sender_id()
	#players[new_player_id] = new_player_info
	#player_connected.emit(new_player_id, new_player_info)
#
#func _on_player_disconnected(id):
	#
	#players.erase(id)
#
#func _on_connection_failed():
	#multiplayer.multiplayer_peer = null
#
#func _on_server_disconnected():
	#multiplayer.multiplayer_peer = null
	#players.clear()
	#server_disconnected.emit()
#
## This could be doing something
#func skin_str_to_e(s):
	#match s.to_lower():
		#"blue": return Character.SkinColor.BLUE
		#"yellow": return Character.SkinColor.YELLOW
		#"green": return Character.SkinColor.GREEN
		#"red": return Character.SkinColor.RED
		#_: return Character.SkinColor.BLUE



# This part is mine!!! -Fido
#func _ready() -> void:
	#multiplayer.connected_to_server.connect(HostConnect)
	#multiplayer.peer_connected.connect(PeerConnect)
	#multiplayer.peer_disconnected.connect(PeerDisconnect)



func _ready() -> void:
	multiplayer.server_disconnected.connect(HostDisconnect)
	multiplayer.connection_failed.connect(ConnectFail)
	multiplayer.peer_disconnected.connect(PeerDisconnect)
	multiplayer.peer_connected.connect(PeerConnect)
	multiplayer.connected_to_server.connect(_on_connected_ok)



func HostGame(Nickname: String, SkinColor: Color, Species: Player.SpeciesEnum):
	print("HostGame")
	var EnetPeer = ENetMultiplayerPeer.new()
	var error = EnetPeer.create_server(SERVER_PORT,MAX_PLAYERS)
	if error:
		return error
	multiplayer.multiplayer_peer = EnetPeer
	multiplayer.peer_connected.connect(AddPlayer)
	
	if DisplayServer.get_name() == "headless":
		return
	
	if not Nickname or Nickname.strip_edges() == "":
		Nickname = str(NameArray.pick_random()," ",NameArray.pick_random(),": ",multiplayer.get_unique_id())
	
	player_info["nick"] = Nickname
	player_info["skin"] = SkinColor
	player_info["species"] = Species
	
	players[multiplayer.get_unique_id()] = player_info
	PlayerConnect.emit(multiplayer.get_unique_id(), player_info)



func JoinGame(Nickname: String, SkinColor: Color, Species: Player.SpeciesEnum, Address: String = "127.0.0.1", Port: int = SERVER_PORT):
	print("JoinGame")
	var EnetPeer = ENetMultiplayerPeer.new()
	var error = EnetPeer.create_client(Address,Port)
	if error:
		return error
	multiplayer.peer_connected.connect(AddPlayer)
	multiplayer.peer_disconnected.connect(RemovePlayer)
	#multiplayer.connected_to_server.connect(PeerConnect)
	multiplayer.multiplayer_peer = EnetPeer
	
	if not Nickname or Nickname.strip_edges() == "":
		Nickname = str(NameArray.pick_random()," ",NameArray.pick_random(),": ",multiplayer.get_unique_id())
	
	player_info["nick"] = Nickname
	player_info["skin"] = SkinColor
	player_info["species"] = Species
	
	#players[1] = player_info
	players[multiplayer.get_unique_id()] = player_info
	PlayerConnect.emit(multiplayer.get_unique_id(), player_info)



func AddPlayer(PeerID: int, PlayerInfo):
	#if PeerID == 1:
		#return
	
	var PlayerInstance = PlayerScene.instantiate()
	PlayerInstance.name = str(PeerID)
	Global.PlayerContainer.add_child(PlayerInstance,true)
			 #Network.
	var nick = players[PeerID]["nick"]
	PlayerInstance.nickname.text = nick

	var skin_color: Color = PlayerInfo["skin"]
	var species: Player.SpeciesEnum = PlayerInfo["species"]
	PlayerInstance.set_player_skin(skin_color, species)



func RemovePlayer(PeerID: int):
	if PeerID == 1:
		HostDisconnect()
	
	var DesiredPlayerID: = (Players.find_custom(func(item): return item.name == str(PeerID)))
	if DesiredPlayerID != -1:
		Players[DesiredPlayerID].queue_free()



func ConnectFail():
	print("Connection FAILED!")



func HostConnect():
	#AddPlayer(multiplayer.get_unique_id(),player_info)
	pass



func HostDisconnect():
	#RemovePlayer(multiplayer.get_unique_id())
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	DisconnectSignals()
	get_tree().reload_current_scene()



func PeerConnect(PeerID: int):
	if DisplayServer.get_name() == "headless":
		return
	
	_register_player.rpc_id(PeerID, player_info)
	
	#AddPlayer(multiplayer.get_unique_id(),player_info)



func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	PlayerConnect.emit(peer_id, player_info)



@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	PlayerConnect.emit(new_player_id, new_player_info)



func PeerDisconnect():
	RemovePlayer(multiplayer.get_unique_id())



func DisconnectSignals():
	#multiplayer.connected_to_server.disconnect(HostConnect)
	multiplayer.peer_connected.disconnect(PeerConnect)
	multiplayer.peer_disconnected.disconnect(PeerDisconnect)



#func _ready() -> void:
	#multiplayer.server_disconnected.connect(_on_connection_failed)
	#multiplayer.connection_failed.connect(_on_server_disconnected)
	#multiplayer.peer_disconnected.connect(_on_player_disconnected)
	#multiplayer.peer_connected.connect(_on_player_connected)
	#multiplayer.connected_to_server.connect(_on_connected_ok)
#
#func HostGame(nickname: String, skin_color_str: Color):#, species: Player.SpeciesEnum):
	#var peer = ENetMultiplayerPeer.new()
	#var error = peer.create_server(SERVER_PORT, MAX_PLAYERS)
	#if error:
		#return error
	#multiplayer.multiplayer_peer = peer
#
	#if !nickname or nickname.strip_edges() == "":
		#nickname = "Host_" + str(multiplayer.get_unique_id())
#
	#player_info["nick"] = nickname
	#player_info["skin"] = skin_color_str #skin_str_to_e(skin_color_str)
##	player_info["species"] = species
	#
	#if DisplayServer.get_name() == "headless":
		#return
#
	#players[1] = player_info
	#player_connected.emit(1, player_info)
#
#func JoinGame(nickname: String, skin_color_str: Color, address: String = SERVER_ADDRESS):
	#var peer = ENetMultiplayerPeer.new()
	#var error = peer.create_client(address, SERVER_PORT)
	#if error:
		#return error
#
	#multiplayer.multiplayer_peer = peer
#
	#if !nickname or nickname.strip_edges() == "":
		#nickname = "Player_" + str(multiplayer.get_unique_id())
#
	##var skin_enum = skin_str_to_e(skin_color_str)
#
#
#
	#player_info["nick"] = nickname
	#player_info["skin"] = skin_color_str
	##player_info["species"] = species
#
#func _on_connected_ok():
	#var peer_id = multiplayer.get_unique_id()
	#players[peer_id] = player_info
	#player_connected.emit(peer_id, player_info)
#
#func PlayerConnected(id):
	#if DisplayServer.get_name() == "headless":
		#return
	#_register_player.rpc_id(id, player_info)
#
#@rpc("any_peer", "reliable")
#func _register_player(new_player_info):
	#var new_player_id = multiplayer.get_remote_sender_id()
	#players[new_player_id] = new_player_info
	#player_connected.emit(new_player_id, new_player_info)
#
#func _on_player_disconnected(id):
	#
	#players.erase(id)
#
#func _on_connection_failed():
	#multiplayer.multiplayer_peer = null
#
#func _on_server_disconnected():
	#multiplayer.multiplayer_peer = null
	#players.clear()
	#server_disconnected.emit()
#
## This could be doing something
#func skin_str_to_e(s):
	#match s.to_lower():
		#"blue": return Character.SkinColor.BLUE
		#"yellow": return Character.SkinColor.YELLOW
		#"green": return Character.SkinColor.GREEN
		#"red": return Character.SkinColor.RED
		#_: return Character.SkinColor.BLUE
