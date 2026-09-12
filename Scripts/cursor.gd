extends Control



#signal disconnect_pressed

@onready var NameLabel: Label = $Cursor/LookAtName
@onready var TypeLabel: Label = $Cursor/Tip
@onready var Cursor: Sprite2D = $Cursor
@onready var PeerLabel: RichTextLabel = $Menu/PeerLabel

@onready var LookAtRay: LookAtRayCast = $"../FPCamera/LookingAt"

@onready var player = $".."

@onready var BaseCursor = preload("res://Stuff/Images/cursor.png")
@onready var InteractCursor = preload("res://Stuff/Images/CursorInteract.png")

var LookingAt: Node3D



func _process(_delta: float) -> void:
	var GlobalMousePos: Vector2 = get_global_mouse_position()
	LookingAt = player.LookAtRay.LookingAt
	
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
		if LookingAt != null:
			#if NameLabel and TypeLabel and TypeLabel.text == "" and NameLabel.text == "":
				NameLabel.text = LookingAt.name
				if LookingAt.has_method("TakeDamage") or LookingAt.is_in_group("Alive"):
					TypeLabel.text = str("Health: ", LookingAt.Health)
				else:
					TypeLabel.text = LookAtRay.LookingAt.get_class()
	if LookingAt == null:
		if NameLabel and TypeLabel:
			NameLabel.text = ""
			TypeLabel.text = ""



		if LookingAt and LookingAt.has_user_signal("interacted"):
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
