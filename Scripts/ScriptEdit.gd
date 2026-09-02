extends CodeEdit



## Write Your Debuging Code in This Function. :3 ##
func Run(): # This Function is Connected to the Button
	pass


















	## Do NOT Alter the Code Here Please! ^^ ##

@export var File: String
@export var RunButton: Button
@export var SaveButton: Button
@export var HideButton: Button

@export var player: Player



func _ready() -> void:
	print(File)
	
	var LoadedFile = FileAccess.open(File,FileAccess.READ)
	text = LoadedFile.get_as_text()
	
	SaveButton.pressed.connect(Save)
	RunButton.pressed.connect(Run)
	HideButton.pressed.connect(VisiToggle)



func _process(_delta: float) -> void:
	if Global.UseDebug == true:
		HideButton.visible = true
	else:
		HideButton.visible = false
	
	



func Save():
	var SavedFile = FileAccess.open(File, FileAccess.WRITE)
	SavedFile.store_string(text)



func VisiToggle():
	if visible == true:
		visible = false
	elif visible == false:
		visible = true
