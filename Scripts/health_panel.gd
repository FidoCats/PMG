extends Panel



func _ready() -> void:
	$ProgressBar.max_value = lerp($ProgressBar.value, $"../../..".MaxHealth, 0.5)



func _process(_delta: float) -> void:
	$ProgressBar.value = $"../../..".Health
	
	if not is_multiplayer_authority():
		visible = false
	else:
		visible = true
	
	
