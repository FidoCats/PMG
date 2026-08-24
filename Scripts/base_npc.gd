extends CharacterBody3D
class_name BaseNPC



@export_category("Debug: ")
@export var CanMove: bool = true
@export var CanThink: bool = true
@export_category("Prefrences: ")
## Hearing
@export var HearDistance: float = 30.0 #50.0
@export var HearChance: int = 2
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
var IsWandering: bool = true
var IsPatroling: bool = false
var IsPursuing: bool = false

var IsBored: bool = false

var PursuedPerson: Node3D
var WanderPos: Vector3

var IsDead: bool = false



func _ready() -> void:
	StateTimer.timeout.connect(StateChange)
	BoredTimer.timeout.connect(GetBored)
	
	FeelAreaShape.shape.radius = FeelDistance
	FeelArea.body_entered.connect(AttemptFeel)
	HearAreaShape.shape.radius = HearDistance
	HearArea.body_entered.connect(AttemptHear)
	TouchAreaShape.shape.radius = TouchDistance
	TouchArea.body_entered.connect(HurtPlayer)



func _process(_delta: float) -> void:
	$Label3D.text = str("Bored: ", IsBored, " Pursuing: ", PursuedPerson, "WanderPos: ", WanderPos, " StateTimer: ", StateTimer.wait_time, " BoredTimer: ", BoredTimer.wait_time)

	if PursuedPerson != null:
		IsPursuing = true
		Pursue(_delta)
	
	if IsBored and IsWandering and PursuedPerson != null:
		Wander(_delta)
	
	if SightLine.get_collider() != null and CanSee:
		PursuedPerson = SightLine.get_collider()



func StateChange():
	if IsBored:
		var RandomInt: int = randi_range(0,3)
		if RandomInt == 3:
			IsWandering = true
			PursuedPerson = null
	else:
		IsBored = true
	StateTimer.start()



func GetBored():
	IsBored = true
	PursuedPerson = null
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
		var WasFelt = randi_range(1,FeelChance)
		if WasFelt == 1:
			IsBored = false
			PursuedPerson = _body
			print("I feel ", PursuedPerson)



func Pursue(_delta):
	if WillPursue:
		if PursuedPerson.has_user_signal("Noticable"):
			global_position = Vector3(move_toward(global_position.x, PursuedPerson.global_position.x, _delta),move_toward(global_position.y, PursuedPerson.global_position.y, _delta),move_toward(global_position.z, PursuedPerson.global_position.z, _delta))
			look_at(Vector3(PursuedPerson.global_position.x,0,PursuedPerson.global_position.z))
			print("Im pursuing ", PursuedPerson)
	#else:
		#print(PursuedPerson, " is not interesting. :<")



func Wander(_delta):
	global_position = Vector3(move_toward(global_position.x, WanderPos.x, _delta),move_toward(global_position.y, WanderPos.y, _delta),move_toward(global_position.z, WanderPos.z, _delta))
	look_at(WanderPos)



func HurtPlayer(_body, UsedDamage):
	if IsAgressive:
		if _body.has_method("TakeDamage"):
			UsedDamage = AttackDamage
			_body.TakeDamage(UsedDamage)



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
