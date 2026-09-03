extends Control



signal disconnect_pressed

@onready var NameLabel: Label = $Cursor/LookAtName
@onready var TypeLabel: Label = $Cursor/Tip
@onready var Cursor: Sprite2D = $Cursor
@onready var PeerLabel: RichTextLabel = $Menu/PeerLabel

@onready var LookAtRay: LookAtRayCast = $"../FPCamera/LookingAt"

@onready var player = $".."

@onready var BaseCursor = preload("res://Stuff/Images/cursor.png")
@onready var InteractCursor = preload("res://Stuff/Images/CursorInteract.png")



func _process(_delta: float) -> void:
	var GlobalMousePos: Vector2 = get_global_mouse_position()
	
	## remove later!!!!
	#$Label.text = str("IsDead: ", $"..".IsDead)
	
	if not is_multiplayer_authority():
		visible = false
	else:
		visible = true
	
	Cursor.position = GlobalMousePos
	
	if PeerLabel:
		if %Menu.visible == true:
			if multiplayer.get_peers() != null:
				PeerLabel.text = str(multiplayer.get_peers())
			#if Network.players != null:
				#PeerLabel.text = str("Players: ", "\n", Network.players.get("nick"))
	
	if player.LookAtRay != null:
		if player.LookAtRay.LookingAt != null:
			#if NameLabel and TypeLabel and TypeLabel.text == "" and NameLabel.text == "":
				NameLabel.text = LookAtRay.LookingAt.name
				if player.LookAtRay.LookingAt.has_method("TakeDamage"):
					TypeLabel.text = str("Health: ", player.LookAtRay.LookingAt.Health)
				else:
					TypeLabel.text = LookAtRay.LookingAt.get_class()
	if player.LookAtRay.LookingAt == null:
		if NameLabel and TypeLabel:
			NameLabel.text = ""
			TypeLabel.text = ""



		if player.LookAtRay.LookingAt and player.LookAtRay.LookingAt.has_node("InteractionComponent") or player.LookAtRay.LookingAt and player.LookAtRay.LookingAt.has_signal("interacted"):
			Cursor.texture = InteractCursor
		else:
			Cursor.texture = BaseCursor



func _on_continue_pressed() -> void:
	%Menu.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$"..".InputBlocked = false
func _on_exit_pressed() -> void:
	#disconnect_pressed.emit()
	OS.kill(OS.get_process_id())
