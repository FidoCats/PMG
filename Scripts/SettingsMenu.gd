extends Panel



@export var KeyBindList: ItemList
@export var UseDebugBox: CheckBox

@export var FilePath: String = "res://Config/Configuration.cfg"



func _ready() -> void:
	visibility_changed.connect(Update)
	
	UseDebugBox.toggled.connect(UseDebug)
	#var InputList = Input.is_anything_pressed()
	#for i in InputList:
		##ProjectSettings.get_setting()
		#print(InputList)



func Update():
	if visible == false:
		SettingSaver.Load(FilePath)
	else:
		SettingSaver.Save(FilePath)



func UseDebug(On: bool):
	Global.UseDebug = On
