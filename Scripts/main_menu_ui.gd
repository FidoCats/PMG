extends Control
class_name MainMenuUI

signal host_pressed(nickname: String, skin: String)
signal join_pressed(nickname: String, skin: String, address: String)
signal quit_pressed

@onready var skin_input: LineEdit = $MainContainer/MainMenu/Option2/SkinInput
@onready var nick_input: LineEdit = $MainContainer/MainMenu/Option1/NickInput
@onready var address_input: LineEdit = $MainContainer/MainMenu/Option3/AddressInput

func _ready():
	pass

func _on_host_pressed():
	var nickname = nick_input.text.strip_edges()
	var skin = skin_input.text.strip_edges().to_lower()
	host_pressed.emit(nickname, skin)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_join_pressed():
	var nickname = nick_input.text.strip_edges()
	var skin = skin_input.text.strip_edges().to_lower()
	var address = address_input.text.strip_edges()
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
	return skin_input.text.strip_edges().to_lower()

func get_address() -> String:
	return address_input.text.strip_edges()



# Mine! ^^ -Fido
func _on_title_pressed() -> void:
	$MainContainer/Title/FidoSprite.visible = true
	$MainContainer/Title/AudioStreamPlayer2D.play()
	$MainContainer/Title/AudioStreamPlayer2D2.play()
	$MainContainer/Title/FidoSprite.scale.y = lerp($MainContainer/Title/FidoSprite.scale.y, 0.025, 0.01)
	await get_tree().create_timer(1.5).timeout
	$MainContainer/Title/FidoSprite.scale.y = 0.1
	$MainContainer/Title/FidoSprite.visible = false
