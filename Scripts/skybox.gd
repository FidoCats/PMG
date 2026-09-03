extends Node3D



@export_category("Prefrences")
@export var MorningEnv: Environment
@export var DayEnv: Environment
@export var EveningEnv: Environment
@export var NightEnv: Environment
@export_category("Nodes")
@export var Clock: Timer
@export var EnviromentNode: WorldEnvironment
@export var LightNode: DirectionalLight3D





func _ready() -> void:
	if Network.UseDayNightCycle == true:
		Clock.timeout.connect(Switch)
		Switch()



func _process(_delta: float) -> void:
	if Network.UseDayNightCycle == true:
		match WorldTime.CurrentCycle:
			0:
				if LightNode.rotation_degrees.x != 90.0:
					LightNode.rotation_degrees.x += 0.01 * Clock.wait_time * _delta
			1:
				if LightNode.rotation_degrees.x != 180.0:
					LightNode.rotation_degrees.x += 0.01 * Clock.wait_time * _delta
			2:
				if LightNode.rotation_degrees.x != 270.0:
					LightNode.rotation_degrees.x += 0.01 * Clock.wait_time * _delta
			3:
				if LightNode.rotation_degrees.x != 360.0:
					LightNode.rotation_degrees.x += 0.01 * Clock.wait_time * _delta



func Switch():
	if not WorldTime.CurrentCycle > WorldTime.Cycles.size():
		WorldTime.CurrentCycle += 1
	else: WorldTime.CurrentCycle = 0
	
	
	
	match WorldTime.CurrentCycle:
		0:
			LightNode.rotation_degrees.x = 0.0
			EnviromentNode.environment = MorningEnv
		1:
			LightNode.rotation_degrees.x = -90.0
			EnviromentNode.environment = DayEnv
		2:
			LightNode.rotation_degrees.x = 180.0
			EnviromentNode.environment = EveningEnv
		3:
			LightNode.rotation_degrees.x = 90.0
			EnviromentNode.environment = NightEnv
