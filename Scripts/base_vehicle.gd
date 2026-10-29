extends VehicleBody3D
class_name BaseVehicle



@export_category("Prefrences")
@export var Acceleration: float = 1.0
@export var Speed: float = 1.0
@export var MaxSpeed: float = 100.0
@export var ReverseDivider: float = 1.05
@export var SteerLimit: float = 0.5
@export var SteerSpeed: float = 1.5
@export var BrakeStrength: float = 10.0
@export var BrakeDamp: float = 1.5
@export var Turbo: float = 100.0
@export var EngineOn: bool = false
@export var EngineForce: float = 50.0
@export var MaxHealth: float = 100.0
@export var Health: float = 100.0
@export var UseSeatControl: bool = true
@export var Seat: Seat3D
@export var UseElectricity: bool = false
@export var ElectricalInput: float = 0
@export var MinElectricalInput: float = 400#V
#@export var MaxElectricalInput = 
@export var PowerInput: float
@export var EnginePitchModifier: float = 10.0
@export_category("Assets")
@export_category("Nodes")
@export var EngineSound: AudioStreamPlayer3D
@export var CollideSound: AudioStreamPlayer3D
@export var DamageArea: Area3D
@export var SteeringWheel: RigidBody3D

var UsedBy: Node3D = null
var EnginePitch: float
var SteerTarget: float = 0.0
var PreviousSpeed: float = 0.0
var IsDead: bool = false



func _ready() -> void:
	if UseSeatControl and Seat:
		Seat.Used.connect(Pilot)
		Seat.UnUsed.connect(Pilot)
	Health = MaxHealth
	if DamageArea:
		DamageArea.body_entered.connect(Hit)



func _physics_process(_delta: float) -> void:
	if UsedBy != null:
		if UsedBy != self:
			if UsedBy.is_in_group("Alive") or UsedBy.is_class("Player"):
				Drive(_delta)
	
	if Health <= 0.0 and not IsDead:
		Death()
	
	if ElectricalInput > 0.0:
		PowerInput = ElectricalInput
	else:
		PowerInput = 1.0
	
	#EngineSound.playing = EngineOn
	if EngineOn:
		if not EngineSound.playing:
			EngineSound.play()
		EnginePitch = 0.05 + linear_velocity.length() / (EngineForce * 0.5) * PowerInput * (EnginePitchModifier / 10)
		EngineSound.pitch_scale = lerpf(EngineSound.pitch_scale, EnginePitch, 0.25)
	else:
		EngineSound.stop()
	
	if abs(linear_velocity.length() - PreviousSpeed) > 1.0:
		CollideSound.play()



func Pilot(User: Node3D):
	if User != null:
		if User != self:
			if User.is_in_group("Alive") or User.is_class("Player"):
				UsedBy = User
	else:
		UsedBy = null



func Drive(_delta: float):
# add movement here
	#if Global.UseDebug:
		#print(UsedBy, " is driving ", self)
	if UsedBy != null:
		if UsedBy.is_multiplayer_authority():
			
			
			if Input.is_action_just_pressed(&"Reload"):
				EngineOn = !EngineOn
				if Global.UseDebug:
					print("Engine: ", EngineOn)
			
			SteerTarget = Input.get_axis(&"Right",&"Left")
			SteerTarget *= SteerLimit
			if SteeringWheel:
				SteeringWheel.rotation.z = lerp(SteeringWheel.rotation.z, -SteerTarget, 0.25)
			else:
				pass
			
			if EngineOn == true:
				if Input.is_action_pressed(&"Up"):
					var Velocity = linear_velocity.length()
					if Velocity < MaxSpeed:
						engine_force = lerpf(engine_force, MaxSpeed, Speed * 0.1 * PowerInput * Acceleration)
				else:
					engine_force = lerpf(engine_force, 0.0, Speed * 0.1 * PowerInput * Acceleration)
				if Input.is_action_pressed(&"Down"):
					var Velocity = linear_velocity.length()
					if Velocity < MaxSpeed:
						engine_force = -lerpf(engine_force, MaxSpeed, Speed * 0.5 * PowerInput / ReverseDivider)
				else:
					engine_force = lerpf(engine_force, 0.0, Speed * 0.1 * PowerInput)
				if Input.is_action_pressed("Jump") and not Seat.JumpExit:
					#brake = lerp(brake, BrakeStrength, 1)
					#brake = BrakeStrength
					engine_force = lerpf(engine_force, 0.0, Speed * 0.1 * PowerInput * Acceleration)
					#linear_damp = linear_damp * BrakeDamp * BrakeStrength / linear_velocity.length() * 500
					linear_damp = BrakeDamp * BrakeStrength / linear_velocity.length()
				else:
					#brake = lerp(brake, 0.0, 1)
					brake = 0.0
					linear_damp = 0.0
				if Input.is_action_pressed("Run"):
					var Velocity = linear_velocity.length()
					if Velocity > 0:
						if engine_force < MaxSpeed:
							engine_force += Turbo
						elif Velocity < 0:
							if engine_force > -MaxSpeed:
								engine_force -= Turbo
					else:
						if EngineForce > -MaxSpeed:
							engine_force -= Turbo
				if Input.is_action_just_released("Run") and not Input.is_action_pressed("Up") and not Input.is_action_pressed("Down"):
					engine_force = lerpf(engine_force, 0.0, Speed * 0.1 * PowerInput * Acceleration)
				
				steering = move_toward(steering, SteerTarget, SteerSpeed * _delta)
				PreviousSpeed = linear_velocity.length()
				
			else:
				engine_force = lerpf(engine_force, 0.0, 50.0)



@rpc("any_peer","call_local")
func Hit(_Body: Node3D):
	var Velocity = linear_velocity.length()
	if Velocity >= 10:
		if _Body.is_class("Player") or _Body.is_in_group("Alive") or _Body.has_method("TakeDamage"):
			if _Body != self:
				_Body.TakeDamage.rpc(abs(Velocity) * 2)
		if _Body.has_method("set_freeze_enabled") or _Body.is_class("CharacterBody3D") or _Body.is_in_group("Alive"):
			_Body.global_rotation = DamageArea.global_rotation
			var Force = Force3D.new()
			_Body.add_child(Force,true)
			#Force.global_position = _Body.global_position
			Force.F = Velocity
			Force.SetupFinished.emit()
			TakeDamage.rpc(abs(Velocity) / 2)



@rpc("any_peer","call_local")
func TakeDamage(Damage: float):
	Health -= Damage



@rpc("any_peer","call_local")
func Death():
	IsDead = true
	queue_free()
