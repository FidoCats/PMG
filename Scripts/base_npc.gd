extends CharacterBody3D
class_name BaseNPC



@export_category("Debug: ")
@export var CanMove: bool = true
@export var CanThink: bool = true
@export_category("Prefrences: ")
## Hearing
@export var HearDistance: float = 30.0 #50.0
@export var HearChance: int = 1 #2
## Feeling
@export var FeelDistance: float = 15.0
@export var FeelChance: int = 1
## Too close
@export var TouchDistance = 2.0
## Other
@export var CanHear: bool = true
@export var CanSee: bool = true
@export var CanFeel: bool = true
@export var CanTouch: bool = true
@export var IsAgressive: bool = true
@export var WillPursue: bool = true

@export var CanRespawn: bool = true
@export var RespawnPos: Vector3 = Vector3(-200,15,0)

@export var MaxHealth: float = 100.0
@export var Health: float = 100.0
@export var AttackDamage: float = 10
@export var Speed: float = 5.0

@export_category("Nodes: ")
@export var CollisonShape: CollisionShape3D
@export var MainMesh: MeshInstance3D
@export var AudioPlayer: AudioStreamPlayer3D
@export var SightLine: RayCast3D
@export var FeelArea: Area3D
@export var FeelAreaShape: CollisionShape3D
@export var HearArea: Area3D
@export var HearAreaShape: CollisionShape3D
@export var TouchArea: Area3D
@export var TouchAreaShape: CollisionShape3D
@export var BoredTimer: Timer
@export var StateTimer: Timer
@export var RespawnAudioStream: AudioStreamPlayer3D
@export_category("Resources: ")
@export var RespawnStream: AudioStream

## States
var IsWandering: bool = false #true
var IsPatroling: bool = true #false
var IsPursuing: bool = false

var IsBored: bool = false

var PursuedPerson: Node3D
var WanderPos: Vector3

var IsDead: bool = false

var Direction: Transform3D



func _ready() -> void:
	StateTimer.timeout.connect(StateChange)
	BoredTimer.timeout.connect(GetBored)
	
	#FeelAreaShape.shape.radius = FeelDistance
	FeelArea.body_entered.connect(AttemptFeel)
	#HearAreaShape.shape.radius = HearDistance
	HearArea.body_entered.connect(AttemptHear)
	#TouchAreaShape.shape.radius = TouchDistance
	TouchArea.body_entered.connect(HurtPlayer)
	
	Direction = global_transform
	Direction.origin = Vector3()



func _process(_delta: float) -> void:
	$Label3D.text = str("Bored: ", IsBored, " Pursuing: ", PursuedPerson, "WanderPos: ", WanderPos, " StateTimer: ", StateTimer.wait_time, " BoredTimer: ", BoredTimer.wait_time)

	if IsPursuing == true:
		#if PursuedPerson != null:
			Pursue(_delta)
	
	if IsBored and IsWandering and PursuedPerson != null:
		Wander(_delta)
	
	if SightLine.get_collider() != null and CanSee:
		PursuedPerson = SightLine.get_collider()
	
	## Path Testing
	#if Input.is_action_pressed("ui_accept"):
		#var PathLength: float = 22.0
		#if $"..".progress_ratio <=  PathLength:
	#if IsPatroling:
		#$"..".progress_ratio += 0.005 * _delta * Speed
		#print($"..".progress_ratio, ", ", $"..".progress)
		#else:
			#$"..".progress = 0.0
			#$"..".progress_ratio = 0.0
	#elif Input.is_action_pressed("ui_cancel"):
		#$"..".progress_ratio -= 0.05 * _delta * Speed
		#print($"..".progress_ratio, " , ", $"..".progress)



func StateChange():
	if IsBored:
		var RandomInt: int = randi_range(0,3)
		match RandomInt:
			1:
				print(">w<")
			2:
				IsWandering = false
				IsPatroling = true
				PursuedPerson = null
			3:
				IsWandering = true
				IsPatroling = false
				PursuedPerson = null
	else:
		IsBored = true
	StateTimer.start()
	print("TimeLeft: ",StateTimer.time_left)



func GetBored():
	if PursuedPerson != null:
		if global_position.distance_to(PursuedPerson.global_position) > 50:
			IsBored = true
			PursuedPerson = null
			IsPursuing = false
			IsPatroling = false
			IsWandering = false
			print("Im bored!")



func AttemptHear(_body):
	if CanHear:
		var HasHeard = randi_range(1,HearChance)
		if HasHeard == 1 and CanHear:
			IsBored = false
			PursuedPerson = _body
			print("I hear ", PursuedPerson)



func AttemptFeel(_body):
	if CanFeel:
		#var WasFelt = randi_range(1,FeelChance)
		#if WasFelt == 1:
			IsBored = false
			PursuedPerson = _body
			IsPursuing = true
			print("I feel ", PursuedPerson)



func Pursue(_delta):
	if WillPursue:
		if PursuedPerson != null and PursuedPerson.is_in_group("Alive") and PursuedPerson != self:
			if global_position.distance_to(PursuedPerson.global_position) > 0.5:
				#look_at(Vector3(PursuedPerson.global_position.x,0,PursuedPerson.global_position.z))
				#velocity = Vector3(0,0,-1).rotated(global_rotation,global_rotation.y)
				#velocity = velocity.normalized() * Speed
				#move_and_slide()
				look_at(Vector3(PursuedPerson.global_position.x,1.0,PursuedPerson.global_position.z))
				#global_position = PursuedPerson.global_position
				var Velocity: Vector3 = Direction.origin / _delta * Speed
				velocity.x = Velocity.x
				velocity.z = Velocity.z
				velocity += get_gravity() * _delta
				print("Im pursuing ", PursuedPerson)
		else:
			print(PursuedPerson, " is not interesting. :<")



func Wander(_delta):
	#global_position = Vector3(move_toward(global_position.x, WanderPos.x, _delta),move_toward(global_position.y, WanderPos.y, _delta),move_toward(global_position.z, WanderPos.z, _delta))
	WanderPos = Vector3(randf_range(global_position.x - 25, global_position.x + 25), global_position.y, randf_range(global_position.z - 25,global_position.z + 25))
	look_at(WanderPos)
	velocity = Vector3(0,0,-1).rotated(global_rotation,global_rotation.y)
	velocity = velocity.normalized() * Speed
	move_and_slide()



func HurtPlayer(_body): #, UsedDamage):
	if IsAgressive:
		if _body.has_method("TakeDamage"):
			_body.TakeDamage(AttackDamage)



func TakeDamage(Damage: float):
	Health -= Damage



func Death():
	IsDead = true
	velocity = Vector3.ZERO
	RespawnAudioStream.stream = RespawnStream
	RespawnAudioStream.play()
	ResetValues()



func ResetValues():
	Health = MaxHealth
	if CanRespawn:
		global_transform.origin = RespawnPos
	velocity = Vector3.ZERO
	rotation = Vector3(0,0,0)
	IsDead = false
	global_position = RespawnPos
	RespawnAudioStream.stream = RespawnStream
	RespawnAudioStream.play()
	set_process(true)
	set_physics_process(true)
	print(self, " Reset!")
	print(self, " Can Process: ", can_process())
