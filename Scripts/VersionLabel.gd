extends Label



var Name = ProjectSettings.get_setting("application/config/name")
var Version = ProjectSettings.get_setting("application/config/version")
var VersionDescription = ProjectSettings.get_setting("application/config/description")



func _ready() -> void:
	text = str(Name, " ", Version)
	tooltip_text = str(VersionDescription)
