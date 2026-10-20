extends Node



@export var FilePath: String = "res://Config/Configuration.cfg"

var Config: ConfigFile = ConfigFile.new()



func _ready() -> void:
	Load(FilePath)



func Set(Section: String, Variable: String, Value: Variant):
	Config.set_value(Section, Variable, Value)



func Save(PathToFile: String):
	var TrySave = Config.save(PathToFile)
	if TrySave != OK:
		push_error("Couldn't Save File")
		return
	
	## Setters
	Set("Debug","UseDebug",Global.UseDebug)



func Load(PathToFile: String):
	var TryLoad = Config.load(PathToFile)
	if TryLoad != OK:
		push_error("Couldn't Load File")
		return
	
	#for item in Config.get_sections():
		#



func Get(Section: String, Variable: String, Value: Variant):
	Config.get_value(Section,Variable,Value)
