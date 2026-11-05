extends Control
class_name MainMenuUI

signal host_pressed(nickname: String, skin: Color)#, species: Player.SpeciesEnum)
signal join_pressed(nickname: String, skin: Color, address: String)
signal quit_pressed

@onready var mesh_input: OptionButton = $Profile/MeshInput
@onready var color_input: ColorPickerButton = $Profile/ColorOverlay
@onready var species_input: OptionButton = $Profile/MeshInput
@onready var nick_input: LineEdit = $Profile/NickInput
@onready var address_input: LineEdit = $AddressInput



func _on_host_pressed():
	var nickname: String = nick_input.text.strip_edges()
	var skin: Color = color_input.color #skin_input.text.strip_edges().to_lower()
	#print(Player.SpeciesEnum.get(0))#mesh_input.selected))
	#await get_tree().create_timer(0.1).timeout
	#var species: Player.SpeciesEnum = Player.SpeciesEnum.get(mesh_input.selected)
	
	host_pressed.emit(nickname, skin)#, species)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_join_pressed():
	var nickname: String = nick_input.text.strip_edges()
	var skin: Color = color_input.color #skin_input.text.strip_edges().to_lower()
	#var species: Player.SpeciesEnum = Player.SpeciesEnum.get(mesh_input.selected)
	var address: String = address_input.text.strip_edges()
	join_pressed.emit(nickname, skin, address)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_quit_pressed():
	quit_pressed.emit()

func show_menu():
	show()
	$SpringArm3D/Camera3D.current = true

func hide_menu():
	hide()
	$SpringArm3D/Camera3D.current = false

func is_menu_visible() -> bool:
	return visible

func get_nickname() -> String:
	return nick_input.text.strip_edges()

func get_skin() -> String:
	#return skin_input.text.strip_edges().to_lower()
	return mesh_input.get_item_text(mesh_input.get_selected_id())

func get_address() -> String:
	return address_input.text.strip_edges()



# Mine! ^^ -Fido
func _on_title_pressed() -> void:
	$Main/Title/FidoSprite.visible = true
	$Main/Title/AudioStreamPlayer2D.play()
	$Main/Title/AudioStreamPlayer2D2.play()
	$Main/Title/FidoSprite.scale = lerp($Main/Title/FidoSprite.scale, Vector2(0.175, 0.175), 0.01)
	await get_tree().create_timer(1.5).timeout
	$Main/Title/FidoSprite.scale = Vector2(0.35, 0.35)
	$Main/Title/FidoSprite.visible = false



func _ready():
	for i in Player.SpeciesEnum:
		$Profile/MeshInput.add_item(str(i))



func _process(_delta: float) -> void:
	if is_menu_visible():
		if Global.UseDebug:
			if Input.is_action_just_pressed("QuickHost"):
				_on_host_pressed()
			if Input.is_action_just_pressed("QuickJoin"):
				_on_join_pressed()

## END ##



func _on_create_pressed() -> void:
	if $HostPanel.visible == false:
		$HostPanel.visible = true
		$AddressInput.visible = true
	else:
		$HostPanel.visible = false
		$AddressInput.visible = false

func _on_connect_pressed() -> void:
	if $JoinPanel.visible == false:
		$JoinPanel.visible = true
		$AddressInput.visible = true
	else:
		$JoinPanel.visible = false
		$AddressInput.visible = false

func _on_profile_pressed() -> void:
	if $Profile.visible == false:
		$Profile.visible = true
	else:
		$Profile.visible = false

func _on_settings_pressed() -> void:
	if $Settings.visible == false:
		$Settings.visible = true
	else:
		$Settings.visible = false


func _on_skin_input_item_selected(_index: int) -> void:
	Network.player_info.set("species", Player.SpeciesEnum.get(_index))
	print(Player.SpeciesEnum.get(_index), Network.player_info.get("species"), mesh_input.get_selected_id())

func _on_color_overlay_color_changed(_color: Color) -> void:
	Network.player_info.set("skin",_color)

func _on_day_night_cycle_toggle_toggled(_toggled_on: bool) -> void:
	Network.UseDayNightCycle = _toggled_on

func _on_keep_inventory_toggled(_toggled_on: bool) -> void:
	Network.KeepInventory = _toggled_on

func _on_h_slider_value_changed(_value: float) -> void:
	Network.MAX_PLAYERS = int(_value)
	$HostPanel/HSlider/Label.text = str("MaxPlayers","\n",int(_value))
