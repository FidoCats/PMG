extends Alive
class_name BaseNPC



@export_category("Debug: ")
@export var UseLabelForDebug: bool = false
@export var CanThink: bool = true
@export_category("Prefrences: ")
## Hearing
@export var HearDistance: float = 50.0
@export var HearChance: int = 2
## Feeling
@export var FeelDistance: float = 30.0
@export var FeelChance: int = 1
## Too close
@export var TouchDistance = 2.5
## Attacking
@export var AttackDistance: float = 2.0
## Stop
@export var StopDistance: float = 1.45
## Other
@export var CanHear: bool = true
@export var CanSee: bool = true
@export var CanFeel: bool = true
@export var CanTouch: bool = true
@export var IsAgressive: bool = true
@export var WillPursue: bool = true
@export var CanMove: bool = true
@export var UseGravity: bool = true

@export var StopOnAttack: bool = true
@export var WanderDistance = 15.0

@export_category("Properties")
@export var AttackDamage: float = 10
@export var Speed: float = 3.0
@export var CanAttack: bool = true
@export var AttackCoolDown: float = 1
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
@export var NavAgent: NavigationAgent3D
@export_category("Resources: ")

## States
var IsWandering: bool = false #true
var IsPatroling: bool = false
var IsPursuing: bool = false

var IsBored: bool = false

var PursuedPerson: Node3D
var WanderPos: Vector3

var Origin: Vector3
var NavLocation: Vector3



# Leftovers for tommorows linner. :3
var Direction: Transform3D



func _ready() -> void:
	StateTimer.timeout.connect(StateChange)
	BoredTimer.timeout.connect(GetBored)
	
	#FeelAreaShape.shape.radius = FeelDistance
	FeelArea.body_entered.connect(AttemptFeel)
	#HearAreaShape.shape.radius = HearDistance
	HearArea.body_entered.connect(AttemptHear)
	#TouchAreaShape.shape.radius = TouchDistance
	TouchArea.body_entered.connect(AttemptTouch)
	
	#NavAgent.target_reached.connect(HurtPlayer)
	# Change NavAgent.target_desired_distance to make NPC stay away. (ranged enemies)
	
	#NavAgent.velocity_computed.connect(NavAgentAvoidanceCalculator)
	# Also this code does not account for avoidance being enabled. :]
	
	NavAgent.max_speed = Speed



func _physics_process(_delta: float) -> void:
	if UseLabelForDebug:
		$Label3D.text = str("Bored: ", IsBored, " Pursuing: ", PursuedPerson, "WanderPos: ", WanderPos, " StateTimer: ", StateTimer.time_left, " BoredTimer: ", BoredTimer.time_left)
	
	if UseGravity:
		velocity.y += get_gravity().y * _delta
	move_and_slide()
	
	if not IsDead:
		Origin = global_transform.origin
		NavLocation = NavAgent.get_next_path_position()
		
		## FOR TESTING ONLY REMOVE LATER
		#IsPursuing = true
		#print("PursuedPerson is: ", PursuedPerson)
		
		
		
		## Basic Process Ifs
		
		
		
		if IsPursuing == true:
			if PursuedPerson != null:
				if PursuedPerson.is_in_group("Alive") and PursuedPerson != self:
					Pursue(_delta, PursuedPerson)
					#print("IsPursuing == true, Pursuing: ", PursuedPerson)
		
		if IsBored and IsWandering and PursuedPerson != null:
			Wander(_delta)
		
		if SightLine.get_collider() != null:
			if CanSee:
				if SightLine.get_collider() != null:
					if SightLine.get_collider().is_in_group("Alive"):
						if SightLine.get_collider() != self:
							if SightLine.get_collider().Noticability > 0:
								PursuedPerson = SightLine.get_collider()
								IsPursuing = true
		
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
		if not IsPursuing:
			var RandomInt: int = randi_range(0,3)
			match RandomInt:
				0:
					## Wander
					IsWandering = true
					IsPatroling = false
					IsPursuing = false
					PursuedPerson = null
					#print("Ima jus wander...")
				1:
					## Patrol
					IsWandering = false
					IsPatroling = true
					IsPursuing = false
					PursuedPerson = null
					#print("On Patrol! Reporting For DUTY!!!")
	else:
		IsBored = true
	StateTimer.start()
	#print("TimeLeft: ",StateTimer.time_left)



func GetBored():
	if PursuedPerson != null:
		if global_position.distance_to(PursuedPerson.global_position) > FeelDistance:
			IsBored = true
			IsPursuing = false
			PursuedPerson = null
			IsPatroling = false
			IsWandering = false
			#print("Im bored!")



func AttemptHear(_body):
	if CanHear:
		if _body != null:
			if _body.is_in_group("Alive"):
				if _body != self:
					var HasHeard = randi_range(1,HearChance)
					if HasHeard == 1 and CanHear:
						if _body.CurrentNoise >= 1:
							IsBored = false
							PursuedPerson = _body
							IsPursuing = true
							#print("I hear ", PursuedPerson)



func AttemptFeel(_body):
	if CanFeel:
		if _body != null:
			if _body.is_in_group("Alive"):
				if _body != self:
					if _body.CurrentNoise >= 1:
						var WasFelt = randi_range(1,FeelChance)
						if WasFelt == 1:
							IsBored = false
							PursuedPerson = _body
							IsPursuing = true
							#print("I feel ", PursuedPerson)



func AttemptTouch(_body: Node3D):
	if CanTouch:
		if _body != null:
			if _body.is_in_group("Alive"):
				if _body != self:
					if _body.Noticability >= 1:
						IsBored = false
						IsPursuing = true
						PursuedPerson = _body



func Move(_delta, Target: Node3D, UsePos: bool = false, TargetPos: Vector3 = Vector3.ZERO):
	if CanThink and CanMove:
		if not IsBored:
			if Target or TargetPos:
				if not UsePos:
					TargetPos = Target.global_position
				
				SetTargetPosition(TargetPos)#Target.global_position)
				
				if not global_position.distance_to(TargetPos) < StopDistance:#global_position != NavAgent.get_final_position():
					
					var Velocity: Vector3 = (NavLocation - Origin).normalized() * Speed
					
					velocity = velocity.move_toward(Velocity, 0.25)
					move_and_slide()
					
					look_at(Vector3(NavLocation.x, 1.65, NavLocation.z))
					
					#print("Moving Toward ", Target, " at Position ", Target.global_position)
				else:
					velocity = Vector3.ZERO



#func NavAgentAvoidanceCalculator(SafeVelocity):
	#velocity = velocity.move_toward(SafeVelocity, 0.25)
	#move_and_slide()


func Pursue(_delta, Target: Node3D):
	if IsPursuing:
			if WillPursue:
				if Target != null:
					if Target.is_in_group("Alive") and not Target.is_in_group("Neutral"):
						if Target != self:
							if Target.Noticability != 0:
								if global_position.distance_to(Target.global_position) < FeelDistance:
									IsBored = false
									Move(_delta,Target)
									BoredTimer.start()
									#print("Noticability: ", Target.Noticability)
									#print("Im pursuing ", Target)
									if global_position.distance_to(Target.global_position) < AttackDistance:
										HurtPlayer(Target)
										#print("I just hit ", Target)
								else:
									Wander(_delta)
									#print(Target, " is not interesting. :<")
							else:
								GetBored()



func Wander(_delta):
	WanderPos = Vector3(randf_range(global_position.x - WanderDistance, global_position.x + WanderDistance), global_position.y, randf_range(global_position.z - WanderDistance,global_position.z + WanderDistance))
	IsPursuing = false
	PursuedPerson = null
	IsPatroling = false
	Move(_delta,null,true,WanderPos)
	print("Jdu na vandr......")



func SetTargetPosition(TargetPos: Vector3):
	NavAgent.target_position = TargetPos
	# TargetPos needs to be global_position!!
	#print("TargetPos set to ", NavAgent.target_position)



func HurtPlayer(_body): #, UsedDamage):
	if _body:
		if IsAgressive:
			if CanAttack:
				if _body.has_method("TakeDamage"):
					_body.TakeDamage(AttackDamage)
					CanAttack = false
					CanMove = false
					
					await get_tree().create_timer(AttackCoolDown).timeout
					CanMove = true
					CanAttack = true
					if _body.Health <= 0:
						PursuedPerson = null
						IsPursuing = false



#func TakeDamage(Damage: float):
	#Health -= Damage
#
#
#
#func Death():
	#IsDead = true
	#velocity = Vector3.ZERO
	#RespawnAudioStream.stream = RespawnStream
	#RespawnAudioStream.play()
	#if CanRespawn:
		#await get_tree().create_timer(RespawnTime).timeout
		#ResetValues()
#
#
#
#func ResetValues():
	#Health = MaxHealth
	#global_transform.origin = RespawnPos
	#velocity = Vector3.ZERO
	#rotation = Vector3(0,0,0)
	#IsDead = false
	#global_position = RespawnPos
	#RespawnAudioStream.stream = RespawnStream
	#RespawnAudioStream.play()
	#set_process(true)
	#set_physics_process(true)
	#print(self, " Reset!")
	#print(self, " Can Process: ", can_process())
