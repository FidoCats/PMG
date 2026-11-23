extends Alive
class_name BaseNPC



signal Sense(_Body: Node3D)

@export_category("Debug: ")
@export var UseLabelForDebug: bool = false
@export var CanThink: bool = true
@export_category("Prefrences: ")
## Hearing
@export var HearDistance: float = 50.0
@export var HearChance: int = 2
## Sensing
@export var SenseDistance: float = 30.0
@export var SenseChance: int = 1
## Too close
@export var TouchDistance = 2.5
## Attacking
@export var AttackDistance: float = 2.0
## Stop
@export var StopDistance: float = 1.45
## Other
@export var CanHear: bool = true
@export var CanSee: bool = true
@export var CanSense: bool = true
@export var CanTouch: bool = true
@export var IsAgressive: bool = true
@export var CanAttack: bool = true
@export var WillPursue: bool = true
@export var CanMove: bool = true
@export var CanJump: bool = true
@export var UseWindJump: bool = true
@export var UseGravity: bool = true
@export var StopOnAttack: bool = true
@export_enum("Melee","Ranged") var Personality = "Melee"

@export_category("Properties")
@export var AttackDamage: float = 10
@export var Speed: float = 3.0
@export var AttackCoolDown: float = 1.0
@export var JumpVelocity: float = 5.5
@export var LungeForce: float = 2.5
@export var JumpWindup: float = 0.25
@export var WanderDistance = 25.0

@export_category("Nodes: ")
@export var CollisonShape: CollisionShape3D
@export var MainMesh: MeshInstance3D
@export var AudioPlayer: AudioStreamPlayer3D
@export var InfrontRay: RayCast3D
@export var FloorInfrontRay: RayCast3D
@export var UnderRay: RayCast3D
@export var AboveRay: RayCast3D
@export var SightLine: RayCast3D
@export var SenseArea: Area3D
@export var SenseAreaShape: CollisionShape3D
@export var HearArea: Area3D
@export var HearAreaShape: CollisionShape3D
@export var TouchArea: Area3D
@export var TouchAreaShape: CollisionShape3D
@export var BoredTimer: Timer
@export var StateTimer: Timer
@export var NavAgent: NavigationAgent3D
@export var AlertAudioPlayer: AudioStreamPlayer3D
@export var Holding: Marker3D
@export_category("Resources: ")

## States
var IsWandering: bool = false #true
var IsPatroling: bool = false
var IsPursuing: bool = false
var IsFleeing: bool = false

var IsBored: bool = false

var PursuedPerson: Node3D
var WanderPos: Vector3

var Origin: Vector3
var NavLocation: Vector3

var WanderTarget: Node3D

var CanUseWeapon: bool = true



# Leftovers for tommorows linner. :3
var Direction: Transform3D



func _ready() -> void:
	StateTimer.timeout.connect(StateChange)
	BoredTimer.timeout.connect(GetBored)
	
	#NavAgent.target_reached.connect(Stop)
	
	#SenseAreaShape.shape.radius = SenseDistance
	SenseArea.body_entered.connect(AttemptSense)
	#HearAreaShape.shape.radius = HearDistance
	#Sense.connect(AttemptSense)
	HearArea.body_entered.connect(AttemptHear)
	#TouchAreaShape.shape.radius = TouchDistance
	TouchArea.body_entered.connect(AttemptTouch)
	
	if Holding.get_child_count() > 0:
		PickupWeapon(Holding.get_child(0))
	
	#Sense.connect(Pursue)
	
	#NavAgent.target_reached.connect(Reached)
	# Change NavAgent.target_desired_distance to make NPC stay away. (ranged enemies)
	
	#NavAgent.velocity_computed.connect(NavAgentAvoidanceCalculator)
	# Also this code does not account for avoidance being enabled. :]
	
	NavAgent.max_speed = Speed
	
	await get_tree().create_timer(0.01 * get_process_delta_time()).timeout
	
	WanderTarget = Marker3D.new()#Marker3D.new()
	get_parent().add_child(WanderTarget)
	
	Wander(get_process_delta_time())
	
	if Holding.get_child(0) != null:
		if Holding.get_child(0).has_method("Reload"):
			Holding.get_child(0).Reload()



func _physics_process(_delta: float) -> void:
	if UseLabelForDebug:
		$Label3D.text = str("Bored: ", IsBored, " Pursuing: ", PursuedPerson, "WanderPos: ", WanderPos, " StateTimer: ", StateTimer.time_left, " BoredTimer: ", BoredTimer.time_left)
	
	if UseGravity:
		if not is_on_floor():
			velocity.y += get_gravity().y * _delta
	
	move_and_slide()
	
	if not IsDead:
		Origin = global_transform.origin
		NavLocation = NavAgent.get_next_path_position()
		
		## FOR TESTING ONLY, REMOVE LATER!
		#IsPursuing = true
		#print("PursuedPerson is: ", PursuedPerson)
		
		
		
		## Basic Process Ifs
		
		
		
		if IsPursuing == true:
			if PursuedPerson != null:
				if PursuedPerson != self:
					if PursuedPerson.is_in_group("Alive"):
						Pursue(_delta, PursuedPerson)
					#elif PursuedPerson.is_in_group("Player"):
						#Pursue(_delta, PursuedPerson)
					elif PursuedPerson.is_in_group("Noticable"):
						Pursue(_delta, PursuedPerson)
						print("IsPursuing == true, Pursuing: ", PursuedPerson)
		
		if IsWandering and PursuedPerson == null:
			WanderPos = Vector3(randf_range(global_position.x - WanderDistance, global_position.x + WanderDistance), global_position.y, randf_range(global_position.z - WanderDistance,global_position.z + WanderDistance))
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
					Wander(get_process_delta_time())
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
		if global_position.distance_to(PursuedPerson.global_position) > SenseDistance:
			IsBored = true
			IsPursuing = false
			PursuedPerson = null
			IsPatroling = false
			IsWandering = false
	StateChange()
			#print("Im bored!")



func AttemptHear(_body):
	if CanHear:
		if _body != null:
			if _body != self:
				if _body.is_in_group("Alive"):
					if _body.CurrentNoise > 0:
						var HasHeard = randf_range(0, HearChance / _body.CurrentNoise)
						if HasHeard == 0 and CanHear:
							#if _body.CurrentNoise > 0:
								if AlertAudioPlayer:
									AlertAudioPlayer.play()
								IsBored = false
								PursuedPerson = _body
								IsPursuing = true
								#print("I hear ", PursuedPerson)
				elif _body.is_in_group("Noticable"):
					#var HasHeard = randf_range(0, HearChance)
					#if HasHeard == 0 and CanHear:
						if AlertAudioPlayer:
							AlertAudioPlayer.play()
						IsBored = false
						PursuedPerson = _body
						IsPursuing = true
						Pursue(get_process_delta_time(), PursuedPerson)
						print("I heard you!!!!! Oh youre nothing")



func AttemptSense(_body):
	if CanSense:
		if _body != null:
			if _body.is_in_group("Alive"):
				if _body != self:
					if _body.Noticability > 0:
						var WasFelt = randf_range(0, SenseChance / _body.Noticability)
						if WasFelt == 0:
							#if _body.Noticability > 0:
								if AlertAudioPlayer:
									AlertAudioPlayer.play()
								IsBored = false
								PursuedPerson = _body
								IsPursuing = true
								#print("I Sense ", PursuedPerson)



func AttemptTouch(_body: Node3D):
	if CanTouch:
		if _body != null:
			if _body != self:
				if _body.is_in_group("Alive"):
					if _body.Noticability > 0:
						if AlertAudioPlayer:
							AlertAudioPlayer.play()
						IsBored = false
						IsPursuing = true
						PursuedPerson = _body
				elif is_in_group("Noticable"):
					if AlertAudioPlayer:
							AlertAudioPlayer.play()
					IsBored = false
					IsPursuing = true
					PursuedPerson = _body
					print("WUHH!?!?!")



#@rpc("any_peer","call_local")
func Move(_delta, Target: Node3D, TargetPos: Vector3 = Target.global_position):#, UsePos: bool = false, TargetPos: Vector3 = Vector3.ZERO):
	## PROBABLY WILL CAUSE PROBLEMS PLEASE REMOVE
	#set_multiplayer_authority(str(Target.name).to_int())
	
	if CanThink and CanMove:
		if not IsBored:
			#if Target or TargetPos:
				#
				#if not UsePos:
					#TargetPos = Target.global_position
				
				
				
				SetTargetPosition(TargetPos)#TargetPos)
				
				
				
				## Movement
				if NavAgent.get_navigation_map().is_valid():
					if global_position.distance_to(TargetPos) > StopDistance and NavAgent.is_target_reachable():#global_position != NavAgent.get_final_position():
						
						var Velocity: Vector3 = (NavLocation - Origin).normalized() * Speed
						
						velocity = velocity.move_toward(Velocity, 0.05 * Speed)
						rotation.x = 0.0
						#print("schmove")
					else:
						velocity = Vector3.ZERO
					move_and_slide()
				else:
					global_position.move_toward(NavLocation, _delta) #Target.global_position)
					#print("schmove but altfire")
					move_and_slide()
				
				
				## Jump
				if FloorInfrontRay.get_collider() == null:
					Jump(true)
				if InfrontRay.get_collider() != null:
					if InfrontRay.get_collider() != PursuedPerson:
						if PursuedPerson:
							if global_position.distance_to(PursuedPerson.global_position) < NavAgent.get_path_length():
								Jump()
						else:
							Jump()
				
				
				
				# Removed for Strafing and RangedNPC Reasons :] -Fido
				## LookAt
				#if UnderRay.get_collider() != null:
					#var LookPos = Vector3(NavLocation.x, global_position.y + 0.5 - 0.5, NavLocation.z)
					#if LookPos != Origin:
						#look_at(LookPos)
					
					#print("Moving Toward ", Target, " at Position ", Target.global_position)



func Jump(IsLong: bool = false):
	if CanJump:
		
		if UseWindJump:
			Stop(JumpWindup)
		
		if is_on_floor() and  velocity.y < JumpVelocity and AboveRay.get_collider() == null:
			if not IsLong:
				velocity.y = JumpVelocity + (LungeForce / 2)
			else:
				velocity.y = JumpVelocity
			
			if IsLong:
				if InfrontRay.get_collider() == null:
					velocity -= (transform.basis * Vector3(0,0,LungeForce))



func Stop(StopTime: float = 1):
	CanMove = false
	await get_tree().create_timer(StopTime).timeout
	CanMove = true


#func Reached():
	#if IsWandering:
		#Wander(_delta)



#func NavAgentAvoidanceCalculator(SafeVelocity):
	#velocity = velocity.move_toward(SafeVelocity, 0.25)
	#move_and_slide()

#@rpc("any_peer","call_local")
func Pursue(_delta, Target: Node3D):
	if IsPursuing:
		if WillPursue:
			if Target != null:
				if Target != self:
					if Health > 5:
						if Target.is_in_group("Alive") and not Target.is_in_group("Neutral"):
							if Target.Noticability != 0:
								if Personality == "Melee" or Holding.get_child(0) == null:
									if global_position.distance_to(Target.global_position) < SenseDistance:
										IsBored = false
										Move(_delta,Target)
										if UnderRay.get_collider() != null:
											var LookPos = Vector3(NavLocation.x, global_position.y + 0.5 - 0.5, NavLocation.z)
											if LookPos != Origin:
												look_at(LookPos)
										BoredTimer.start()
										#print("Noticability: ", Target.Noticability)
										#print("Im pursuing ", Target)
										if global_position.distance_to(Target.global_position) < AttackDistance:
											if CanAttack:
												HurtPlayer(Target)
											#print("I just hit ", Target)
									else:
										velocity = Vector3(0,velocity.y,0)
										WanderPos = Vector3(randf_range(global_position.x - WanderDistance, global_position.x + WanderDistance), global_position.y, randf_range(global_position.z - WanderDistance,global_position.z + WanderDistance))
										Wander(_delta)
										#print(Target, " is not interesting. :<")
								else:
									if Holding.get_child(0) != null:
										self.look_at(Vector3(Target.global_position.x,global_position.y + 0.75,Target.global_position.z))
										rotation_degrees.x = 0.0
										var TargetVelocity: Vector3 = (Target.transform.basis * Target.velocity)
										Holding.look_at(Vector3(Target.global_position.x,Target.global_position.y + 0.5, Target.global_position.z) + (-TargetVelocity / global_position.distance_to(Target.global_position)),Vector3.UP,true)
										
										if SightLine.get_collider() != Target:
											Move(_delta,Target)
											#velocity = (transform.basis * TargetVelocity)
										if global_position.distance_to(Target.global_position) > (HearDistance - TouchDistance):
											Move(_delta,Target)
										
										#var Rot = abs(Holding.rotation_degrees)
										#Rot = -Rot
										#var Weapon: RigidBody3D = Holding.get_child(0)
										#Weapon.position = Holding.position
										if SightLine.get_collider() == Target or global_position.distance_to(Target.global_position) <= TouchDistance:
											UseWeapon()
							else:
								GetBored()
						## Object Notice Code !!! # Noticable # Lure # Distraction
						#elif Target.is_in_group("Noticable"):
							##await Target.Sense
							#if global_position.distance_to(Target.global_position) < SenseDistance:
								#print("Hoh? Wuhs dis???")
								#IsBored = false
								#Move(_delta,Target)
								#if UnderRay.get_collider() != null:
									#var LookPos = Vector3(NavLocation.x, global_position.y + 0.5 - 0.5, NavLocation.z)
									#if LookPos != Origin:
										#look_at(LookPos)
								#BoredTimer.start()
							#elif global_position.distance_to(Target.global_position) <= TouchDistance:
								#HurtPlayer(Target)
								#await get_tree().create_timer(1).timeout
								#Wander(_delta)
								#PursuedPerson = null
								#IsPursuing = false
								#print("Anyways! :3")
							#else:
								#velocity = Vector3(0,velocity.y,0)
								#WanderPos = Vector3(randf_range(global_position.x - WanderDistance, global_position.x + WanderDistance), global_position.y, randf_range(global_position.z - WanderDistance,global_position.z + WanderDistance))
								#Wander(_delta)




func Wander(_delta):
	if global_position.distance_to(WanderPos) <= 0.75:
		WanderPos = Vector3(randf_range(global_position.x - WanderDistance, global_position.x + WanderDistance), global_position.y, randf_range(global_position.z - WanderDistance,global_position.z + WanderDistance))
		IsBored = false
		IsWandering = true
		IsPursuing = false
		PursuedPerson = null
		IsPatroling = false
		WanderTarget.position = WanderPos
	else:
		if PursuedPerson == null:
			SetTargetPosition(WanderTarget.position)
			Move(_delta,WanderTarget)
			if UnderRay.get_collider() != null:
				var LookPos = Vector3(NavLocation.x, global_position.y + 0.5 - 0.5, NavLocation.z)
				if LookPos != Origin:
					look_at(LookPos)
	
	#print("Jdu na vandr......")



func SetTargetPosition(TargetPos: Vector3) -> Vector3:
	var ReturnPos: Vector3
	if NavAgent:
		NavAgent.target_position = TargetPos
		ReturnPos = NavAgent.target_position
	return ReturnPos
	## TargetPos needs to be global_position!!
	#print("TargetPos set to ", NavAgent.target_position)



func HurtPlayer(_body): #, DamageType):
	if _body:
		if IsAgressive:
			if CanAttack:
				if _body.has_method("TakeDamage"):
					CanAttack = false
					if AlertAudioPlayer:
						AlertAudioPlayer.play()
					CanAttack = false
					CanMove = false
					_body.TakeDamage.rpc(AttackDamage)
					await get_tree().create_timer(AttackCoolDown).timeout
					CanMove = true
					CanAttack = true
					if _body.Health <= 0:
						PursuedPerson = null
						IsPursuing = false
						GetBored()
				else:
					GetBored()



func PickupWeapon(Weapon: RigidBody3D = Holding.get_child(0)):
	if Weapon != null:
		if Weapon.has_method("Enable"):
			Weapon.freeze = true
			Weapon.Enable(true)
			print(Weapon.name,".Enabled: ",Weapon.Enabled)
			#Weapon.Enabled = true
			Weapon.position = Vector3.ZERO
			Weapon.rotation = Vector3.ZERO
		if Weapon.has_method("SetUser"):
			Weapon.SetUser(self)
		#print(Weapon)
	if Weapon.has_method("Reload"):
		Weapon.Reload()



func DropWeapon(ChosenWeapon = Holding.get_child(0)):
	if ChosenWeapon != null:
		var Weapon:RigidBody3D = ChosenWeapon
		Global.ObjectSpawner.add_child(Weapon,true)
		ChosenWeapon.queue_free()
		Weapon.global_transform = Holding.global_transform
		if Weapon.has_method("Enable"):
			Weapon.Enable(false)
		if Weapon.has_method("SetUser"):
			Weapon.SetUser(null)



func UseWeapon():
	var Weapon = Holding.get_child(0)
	
	if Weapon != null:
		if IsAgressive:
			if CanUseWeapon:
			
				CanUseWeapon = false
				if Weapon.has_method("ShootBullet"):
					if Weapon.Ammo > 0:
						if Weapon.CanFire:
							Weapon.ShootBullet("Semi")
							Weapon.CanFire = false
							
							#await get_tree().create_timer(5).timeout
							await get_tree().create_timer(60/Weapon.RPM * 2.5).timeout
							Weapon.CanFire = true
					else:
						if Health > 5:#Health / 20:
							if not Weapon.IsReloading:
								Weapon.Reload()
						else:
								Weapon.ShootBullet("Semi")
								Weapon.ShootBullet("Semi")
								Weapon.ShootBullet("Semi")
								Weapon.Reload()
				CanUseWeapon = true



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
