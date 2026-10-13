extends CharacterBody3D
class_name BaseNPC



@export_category("Debug: ")

@export var CanThink: bool = true
@export_category("Prefrences: ")
## Hearing
@export var HearDistance: float = 50.0
@export var HearChance: int = 1 #2
## Feeling
@export var FeelDistance: float = 30.0
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
@export var CanMove: bool = true

@export var StopOnAttack: bool = true
@export var CanRespawn: bool = true
@export var RespawnPos: Vector3 = Vector3(-200,15,0)
@export var RespawnTime: float = 1.5

@export var MaxHealth: float = 100.0
@export var Health: float = 100.0
@export var AttackDamage: float = 10
@export var Speed: float = 5.0
@export var CanAttack: bool = true
@export var AttackCoolDown: float = 0.75

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
@export var NavAgent: NavigationAgent3D
@export_category("Resources: ")
@export var RespawnStream: AudioStream

## States
var IsWandering: bool = false #true
var IsPatroling: bool = false
var IsPursuing: bool = false

var IsBored: bool = false

var PursuedPerson: Node3D
var WanderPos: Vector3

var IsDead: bool = false

var Origin: Vector3
var NavLocation: Vector3


# Leftovers for tommorows linner. :3
var Direction: Transform3D



func _ready() -> void:
	## Enable Later
	StateTimer.timeout.connect(StateChange)
	BoredTimer.timeout.connect(GetBored)
	
	#FeelAreaShape.shape.radius = FeelDistance
	FeelArea.body_entered.connect(AttemptFeel)
	#HearAreaShape.shape.radius = HearDistance
	HearArea.body_entered.connect(AttemptHear)
	#TouchAreaShape.shape.radius = TouchDistance
	TouchArea.body_entered.connect(AttemptTouch)
	
	NavAgent.target_reached.connect(HurtPlayer)
	# Change NavAgent.target_desired_distance to make NPC stay away. (ranged enemies)
	#NavAgent.velocity_computed.connect(NavAgentAvoidanceCalculator)
	# Also this code does not account for avoidance being enabled. :]



func _physics_process(_delta: float) -> void:
	$Label3D.text = str("Bored: ", IsBored, " Pursuing: ", PursuedPerson, "WanderPos: ", WanderPos, " StateTimer: ", StateTimer.wait_time, " BoredTimer: ", BoredTimer.wait_time)
	
	velocity.y += get_gravity().y * _delta
	move_and_slide()
	
	Origin = global_transform.origin
	NavLocation = NavAgent.get_next_path_position()
	
	## FOR TESTING ONLY REMOVE LATER
	#IsPursuing = true
	#print("PursuedPerson is: ", PursuedPerson)
	
	
	
	## Basic Process Ifs
	if Health <= 0:
		Death()
	
	
	
	if IsPursuing == true:
		if PursuedPerson != null and not PursuedPerson.is_class("CSGBox3D"):
			if PursuedPerson.is_in_group("Alive") and PursuedPerson != self:
				Pursue(_delta, PursuedPerson)
				#print("IsPursuing == true, Pursuing: ", PursuedPerson)
	
	#if IsBored and IsWandering and PursuedPerson != null:
		#Wander(_delta)
	
	if SightLine.get_collider() != null and CanSee:
		if PursuedPerson != null:
			if PursuedPerson.is_in_group("Alive") and PursuedPerson != self:
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
		if global_position.distance_to(PursuedPerson.global_position) > FeelDistance:
			IsBored = true
			PursuedPerson = null
			IsPursuing = false
			IsPatroling = false
			IsWandering = false
			print("Im bored!")



func AttemptHear(_body):
	#if CanHear:
		#var HasHeard = randi_range(1,HearChance)
		#if HasHeard == 1 and CanHear:
			#if PursuedPerson != null:
				#if PursuedPerson.is_in_group("Alive") and PursuedPerson != self:
					#IsBored = false
					#PursuedPerson = _body
					#IsPursuing = true
					#print("I hear ", PursuedPerson)
			pass



func AttemptFeel(_body):
	if CanFeel:
		#var WasFelt = randi_range(1,FeelChance)
		#if WasFelt == 1:
		if _body != null:
			if _body.is_in_group("Alive"):
				if _body != self:
					IsBored = false
					PursuedPerson = _body
					IsPursuing = true
					print("I feel ", PursuedPerson)



func AttemptTouch(_body: Node3D):
	if CanTouch:
		IsBored = false
		IsPursuing = true
		PursuedPerson = _body



func Move(_delta, Target: Node3D):
	if CanThink and CanMove:
		SetTargetPosition(Target.global_position)
		
		var Velocity: Vector3 = (NavLocation - Origin).normalized() * Speed
		
		velocity = velocity.move_toward(Velocity, 0.25)
		move_and_slide()
		
		look_at(Vector3(NavLocation.x, 1.65, NavLocation.z))
		
		print("Moving Toward ", Target, " at Position ", Target.global_position)



#func NavAgentAvoidanceCalculator(SafeVelocity):
	#velocity = velocity.move_toward(SafeVelocity, 0.25)
	#move_and_slide()


func Pursue(_delta, Target: Node3D):
	if WillPursue:
		if Target != null:
			if Target.is_in_group("Alive"):
				if Target != self:
					if global_position.distance_to(Target.global_position) < FeelDistance:
						Move(_delta,Target)
						print("Im pursuing ", Target)
						if global_position.distance_to(Target.global_position) < TouchDistance:
							HurtPlayer(Target)
							print("I just hit ", Target)
					else:
						print(Target, " is not interesting. :<")



func Wander(_delta):
	##global_position = Vector3(move_toward(global_position.x, WanderPos.x, _delta),move_toward(global_position.y, WanderPos.y, _delta),move_toward(global_position.z, WanderPos.z, _delta))
	#WanderPos = Vector3(randf_range(global_position.x - 25, global_position.x + 25), global_position.y, randf_range(global_position.z - 25,global_position.z + 25))
	#look_at(WanderPos)
	#velocity = Vector3(0,0,-1).rotated(global_rotation,global_rotation.y)
	#velocity = velocity.normalized() * Speed
	#move_and_slide()
	pass



func SetTargetPosition(TargetPos: Vector3):
	NavAgent.target_position = TargetPos
	# TargetPos needs to be global_position!!
	print("TargetPos set to ", NavAgent.target_position)



func HurtPlayer(_body): #, UsedDamage):
	if _body:
		if IsAgressive:
			if CanAttack:
				if _body.has_method("TakeDamage"):
					CanAttack = false
					CanMove = false
					_body.TakeDamage(AttackDamage)
					await get_tree().create_timer(AttackCoolDown).timeout
					CanMove = true
					CanAttack = true
					if _body.Health <= 0:
						PursuedPerson = null
						IsPursuing = false



func TakeDamage(Damage: float):
	Health -= Damage



func Death():
	IsDead = true
	velocity = Vector3.ZERO
	RespawnAudioStream.stream = RespawnStream
	RespawnAudioStream.play()
	if CanRespawn:
		await get_tree().create_timer(RespawnTime).timeout
		ResetValues()



func ResetValues():
	Health = MaxHealth
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
