extends CharacterBody3D
class_name Player



@onready var nickname: Label3D = $PlayerNick/Nickname

## OnReady stuff
@onready var FPCamera: Camera3D = $FPCamera
@onready var LookAtRay: LookAtRayCast = $FPCamera/LookingAt
@onready var UnderRay: UnderRayCast = $Under
@onready var AboveRay: AboveRayCast = $Above
@onready var InfrontRay: InfrontRayCast = $Infront
@onready var TPCamera: Camera3D = $FPCamera/SpringArmOffset/SpringArm3D/TPCamera
@onready var BaseCollisionShape: CollisionShape3D = $BaseCollisionShape
@onready var CrouchCollisionShape: CollisionShape3D = $CrouchCollisionShape3D
@onready var MainMesh: MeshInstance3D = $MainMesh
@onready var ParryArea: Area3D = $FPCamera/ParryArea
@onready var ParryMesh: MeshInstance3D = $FPCamera/ParryArea/MeshInstance3D

var player_inventory: PlayerInventory

## Prefrences (@export)
#@export_category("Objects: ")
#@export var _body: Node3D = null
#@export var _spring_arm_offset: Node3D = null

@export_category("Player Model Stuff: ")
@export_enum("Felmitt", "Canire", "Aviamn") var Species: int = 1

@export var FelmittModel: Mesh
@export var CaenireModel: Mesh
@export var AviamnnModel: Mesh

@export var UseColorOverride: bool = true
@export var ColorOverride: Color = Color(0,0,255,0.5)

#@onready var _bottom_mesh: MeshInstance3D = get_node("3DGodotRobot/RobotArmature/Skeleton3D/Bottom")
#@onready var _chest_mesh: MeshInstance3D = get_node("3DGodotRobot/RobotArmature/Skeleton3D/Chest")
#@onready var _face_mesh: MeshInstance3D = get_node("3DGodotRobot/RobotArmature/Skeleton3D/Face")
#@onready var _limbs_head_mesh: MeshInstance3D = get_node("3DGodotRobot/RobotArmature/Skeleton3D/Llimbs and head")

## Audio
@onready var RespawnAudioStream: AudioStreamPlayer3D = $Respawn
@onready var DeathSound = preload("res://Stuff/Sounds/8bitAhh.ogg")
@onready var RespawnSound = preload("res://Stuff/Sounds/roblox old sounds bass.wav")

## Throwable stuff
@onready var GrenadePreload = preload("res://Scenes/Items/Throwables/grenade.tscn")
@onready var BallArray: Array[PackedScene] = [preload("res://Scenes/small_blue_ball.tscn"),preload("res://Scenes/small_green_ball.tscn"),preload("res://Scenes/small_red_ball.tscn"),preload("res://Scenes/small_yellow_ball.tscn")]

## Movement Stuff
const BaseSpeed: float = 7.50
const RunSpeed: float = 10.0
const CrouchSpeed: float = 2.5
const JumpVelocity: float = 4.5
const SlideStartSpeed: float = 12.5
const SlideEndSpeed: float = 2.0
const DiveStartSpeed: float = 17.5
const DiveEndSpeed: float = 15.0
const WallRunSpeed: float = 10.5
const CrouchFov: float = 5.0
const RunFov: float = 12.5
const DiveFov: float = 22.5
const SlideFov: float = 25.0
const WalkNoise: int = 1
const WalkVisibility: int = 2
const CrouchNoise: int = 0
const CrouchVisibility: int = 1
const JumpNoise: int = 2
const RunNoise: int = 3
const DiveNoise: int = 3
const SlideNoise: int = 3
const LedgeGrabNoise: int = 1

var Speed: float = BaseSpeed
var CurrentSpeed: float = 0.0
#var SpeedSlowdown: float = 0.0

var ParryDamage: float = 5.0
var ParryReward: float = 2.5
var ParryForce: float = 7.5
var ParryBody: Node3D = null

var SetFov: float
var Fov: float
var CurrentFov: float

var CurrentNoise: int
var CurrentVisibility: int
var Noticability: int

var CanMove: bool = true
var IsWalking: bool = true
var IsCrouching: bool = false
var IsSliding: bool = false
var IsDiving: bool = false
var IsClinging: bool = false
var CanCling: bool = true
var IsWallRunning: bool = true
var CanWallJump: bool = true
var CanParry: bool = true



## Others
@export_category("Propreties")
@export var MaxHealth: float = 100.0
@export var Health: float = MaxHealth # (Add Multilimb one later)
@export var MinCameraPos: int = 0
@export var CameraPos: int = 0
@export var MaxCameraPos = 15
@export var Jumps: int = 2
@export var MaxJumps: int = 2
@export var WallJumps: int = 2
@export var MaxWallJumps: int = 2

@export var KeepInventory: bool = false

var HandsOccupied: bool = false

var SpringArmBaseLength: float

#var ObjectDistance: float = 2.5

var RespawnPos = Vector3(0, 7.5, 0)
var Gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var DesiredGravity: float = Gravity

var InputBlocked: bool = false

var Throwable: int = 0
var CanThrowThrowable = true

var IsDead: bool = false

var PeerList

var Parent: Node3D

var CurrentItem = null

var IsRagdolled: bool = false



enum SpeciesEnum { Felmitt, Canire, Aviamn }



func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	#$FPCamera/SpringArmOffset/SpringArm3D/Camera3D.current = is_multiplayer_authority()
	
	if CameraPos == 0:
		$FPCamera.current = is_multiplayer_authority()
	else:
		$FPCamera/SpringArmOffset/SpringArm3D/TPCamera.current = is_multiplayer_authority()
	
	SetFov = $FPCamera.fov
	Fov = SetFov
	CurrentFov = Fov
	$FPCamera.fov = Fov
	$FPCamera/SpringArmOffset/SpringArm3D/TPCamera.fov = Fov



func _unhandled_input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if !InputBlocked:
			if event is InputEventMouseMotion:
				
				if CameraPos == 0:
					$FPCamera.current = is_multiplayer_authority()
					if not IsSliding and not IsDiving: 
						rotation_degrees.y -= event.screen_relative.x * 0.25 * Global.Sensitivity
						$FPCamera.rotation_degrees.x -= event.screen_relative.y * 0.25 * Global.Sensitivity
						$FPCamera.rotation_degrees.x = clamp($FPCamera.rotation_degrees.x,-90,90)
					if IsSliding or IsDiving: 
						$FPCamera.rotation_degrees.y -= event.screen_relative.x * 0.25 * Global.Sensitivity
						#$FPCamera.rotation_degrees.y = clamp($FPCamera.rotation_degrees.y, -110, 110)
						$FPCamera.rotation_degrees.x -= event.screen_relative.y * 0.25 * Global.Sensitivity
						$FPCamera.rotation_degrees.x = clamp($FPCamera.rotation_degrees.x,-90,90)
				
				else:
					$FPCamera/SpringArmOffset/SpringArm3D/TPCamera.current = is_multiplayer_authority()
					#if not IsSliding and not IsDiving: 
						#rotation_degrees.y -= event.screen_relative.x * 0.25 * Global.Sensitivity
						#$FPCamera/SpringArmOffset/SpringArm3D/TPCamera.rotation_degrees.x -= event.screen_relative.y * 0.25 * Global.Sensitivity
						#$FPCamera/SpringArmOffset/SpringArm3D/TPCamera.rotation_degrees.x = clamp($FPCamera/SpringArmOffset/SpringArm3D/TPCamera.rotation_degrees.x,-90,90)
					#if IsSliding or IsDiving: 
						#$FPCamera/SpringArmOffset/SpringArm3D/TPCamera.rotation_degrees.y -= event.screen_relative.x * 0.25 * Global.Sensitivity
						#$FPCamera/SpringArmOffset/SpringArm3D/TPCamera.rotation_degrees.x -= event.screen_relative.y * 0.25 * Global.Sensitivity
						#$FPCamera/SpringArmOffset/SpringArm3D/TPCamera.rotation_degrees.x = clamp($FPCamera/SpringArmOffset/SpringArm3D/TPCamera.rotation_degrees.x,-90,90)



func _ready():
	Parent = get_parent()
	
	add_user_signal("Noticable")
	
	ParryArea.body_entered.connect(ParryAreaEntered)
	ParryArea.body_exited.connect(ParryAreaExited)
	
	var is_local_player = is_multiplayer_authority()
	var local_client_id = multiplayer.get_unique_id()

	SpringArmBaseLength = $FPCamera/SpringArmOffset/SpringArm3D.spring_length

	print("Debug: Player ", name, " ready - authority: ", get_multiplayer_authority(), ", local client: ", local_client_id, ", is_local: ", is_local_player)

	if is_local_player:
		player_inventory = PlayerInventory.new()
		#_add_starting_items()
	elif multiplayer.is_server():
		player_inventory = PlayerInventory.new()
		#_add_starting_items()
	else:
		if get_multiplayer_authority() == local_client_id:
			request_inventory_sync.rpc_id(1)



func _process(_delta):
## Stuff that needs to always process
	if Health <= 0.0:
		Health = 0.0
		Death()
	
	
	
	if not is_multiplayer_authority(): return
	
	
	
## Setters, Getters
	if is_multiplayer_authority():
		AboveRay.position.y = $FPCamera.position.y
		PeerList = multiplayer.get_peers()
		Global.FPCamera = $FPCamera
		#Global.ObjectDistance = ObjectDistance
		

	$MutlipartBody.visible = IsRagdolled
	CanMove = !IsRagdolled
	if IsRagdolled == true:
		position = $MutlipartBody/Skeleton3D/Botom.position
	else:
		$MutlipartBody/Skeleton3D/Botom.position = position
		$MutlipartBody/Skeleton3D/Botom.rotation = rotation
		$MutlipartBody/Skeleton3D/Botom.rotation = Vector3.ZERO
		$MutlipartBody/Skeleton3D/Botom/Chest.rotation = Vector3.ZERO
		$MutlipartBody/Skeleton3D/Botom/Face.rotation = Vector3.ZERO
		$MutlipartBody/Skeleton3D/Botom/Head.rotation = Vector3.ZERO
		$MutlipartBody/Skeleton3D/Botom/LegL.rotation = Vector3.ZERO
		$MutlipartBody/Skeleton3D/Botom/LegR.rotation = Vector3.ZERO
		$MutlipartBody/Skeleton3D/Botom/ArmL.rotation = Vector3.ZERO
		$MutlipartBody/Skeleton3D/Botom/ArmR.rotation = Vector3.ZERO
		
	
	$MainMesh.visible = !IsRagdolled
	
	$MutlipartBody/Skeleton3D/Botom.freeze = !IsRagdolled
	$MutlipartBody/Skeleton3D/Botom/Chest.freeze = !IsRagdolled
	$MutlipartBody/Skeleton3D/Botom/Face.freeze = !IsRagdolled
	$MutlipartBody/Skeleton3D/Botom/Head.freeze = !IsRagdolled
	$MutlipartBody/Skeleton3D/Botom/LegL.freeze = !IsRagdolled
	$MutlipartBody/Skeleton3D/Botom/LegR.freeze = !IsRagdolled
	$MutlipartBody/Skeleton3D/Botom/ArmL.freeze = !IsRagdolled
	$MutlipartBody/Skeleton3D/Botom/ArmR.freeze = !IsRagdolled
	$MutlipartBody/Skeleton3D/Botom/CollisionShape3D.disabled = !IsRagdolled
	$MutlipartBody/Skeleton3D/Botom/Chest/CollisionShape3D.disabled = !IsRagdolled
	$MutlipartBody/Skeleton3D/Botom/Face/CollisionShape3D.disabled = !IsRagdolled
	$MutlipartBody/Skeleton3D/Botom/Head/CollisionShape3D.disabled = !IsRagdolled
	$MutlipartBody/Skeleton3D/Botom/LegL/CollisionShape3D2.disabled = !IsRagdolled
	$MutlipartBody/Skeleton3D/Botom/LegR/CollisionShape3D.disabled = !IsRagdolled
	$MutlipartBody/Skeleton3D/Botom/ArmL/CollisionShape3D2.disabled = !IsRagdolled
	$MutlipartBody/Skeleton3D/Botom/ArmR/CollisionShape3D.disabled = !IsRagdolled

## Basic ifs
	if CurrentSpeed > BaseSpeed + 0.1 and not is_on_floor_only() and not IsSliding and not IsDiving and not IsWallRunning:
		CanMove = false
	if is_on_floor() and not CanMove or is_on_wall() and not CanMove:
		CanMove = true
	
	if IsSliding and CurrentSpeed <= 1.0:
		UnCrouch()
	
	Noticability = CurrentNoise + CurrentVisibility
	
	
	
	if CurrentFov != Fov:
		CurrentFov = lerp(CurrentFov, Fov, 0.1)
	$FPCamera.fov = CurrentFov
	$FPCamera/SpringArmOffset/SpringArm3D/TPCamera.fov = CurrentFov

	if IsWalking and not IsSliding and not IsCrouching and not IsDiving:
	
		## Reset
		if CurrentSpeed <= 0.5 and CurrentNoise >= WalkNoise:
			CurrentNoise = 0 
			CurrentFov = SetFov
		
		
		
		## Get out of seats and such
		if is_on_floor() and Input.is_action_just_pressed("Jump"):
			CanMove = true
			rotation_degrees = Vector3(0,0,0)



## Other Inputs
	if not InputBlocked:
		if Input.is_action_just_pressed("WheelUp"):
			Global.ObjectDistance += 0.25
			if Global.ObjectDistance > -LookAtRay.target_position.z:
				Global.ObjectDistance = - LookAtRay.target_position.z
			$UI/Cursor/Tip.text = str(Global.ObjectDistance)
			await get_tree().create_timer(0.25).timeout
			$UI/Cursor/Tip.text = ""
		if Input.is_action_just_pressed("WheelDown"):
			Global.ObjectDistance -= 0.25
			if Global.ObjectDistance < 0.25:
				Global.ObjectDistance = 0.25
			$UI/Cursor/Tip.text = str(Global.ObjectDistance)
			await get_tree().create_timer(0.25).timeout
			$UI/Cursor/Tip.text = ""
		
		if Input.is_action_just_pressed("MouseLock"):
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
		if Input.is_action_just_pressed("KillBind"):
			#Health -= randf_range(0.1,100.0)
			TakeDamage(randf_range(0.1,100.0))
	
		if Input.is_action_just_pressed("Ragdoll"):
			$MutlipartBody.position = position
			CameraPos = 1
			IsRagdolled = !IsRagdolled
	
		if Input.is_action_just_pressed("Camera+"):
			CameraPos += 1
			CameraPos = clamp(CameraPos, MinCameraPos, MaxCameraPos)
			if CameraPos > 0:
				$FPCamera/SpringArmOffset/SpringArm3D.spring_length = lerp($FPCamera/SpringArmOffset/SpringArm3D.spring_length, SpringArmBaseLength * CameraPos, 1)
			print(CameraPos)
		if Input.is_action_just_pressed("Camera-"):
			CameraPos -= 1
			CameraPos = clamp(CameraPos, MinCameraPos, MaxCameraPos)
			if CameraPos > 0:
				$FPCamera/SpringArmOffset/SpringArm3D.spring_length = lerp($FPCamera/SpringArmOffset/SpringArm3D.spring_length, SpringArmBaseLength * CameraPos, 1)
			print(CameraPos)
		if Input.is_action_just_pressed("CameraReset"):
			CameraPos = 0
	
	if Input.is_action_just_pressed("Chat") and not InputBlocked:
		InputBlocked = true 
	elif Input.is_action_just_pressed("Chat") and InputBlocked:
		InputBlocked = false
	
	
	
	## Throwables
		if Input.is_action_pressed("Throwable") and CanThrowThrowable:
			match Throwable:
				0:
					CanThrowThrowable = false
					var Grenade: Node3D = GrenadePreload.instantiate()
					Global.ProjectileSpawner.add_child(Grenade)
					#Grenade.global_basis = $FPCamera/Holding.global_basis
					#Grenade.global_position = $FPCamera/Holding.global_position
					#Grenade.global_rotation = $FPCamera.global_rotation
					#Grenade.global_transform.origin = $FPCamera/Holding.global_position
					#Grenade.transform = $FPCamera/Holding.global_transform
					#Grenade.global_basis = $FPCamera/Holding.global_basis
					Grenade.global_transform = $FPCamera/Holding.global_transform
					await get_tree().create_timer(1.0).timeout
					CanThrowThrowable = true
				1:
					CanThrowThrowable = false
					var BallChooser: PackedScene = BallArray[randi_range(0,2)]
					var Ball: Node3D = BallChooser.instantiate()
					Global.ProjectileSpawner.add_child(Ball)
					Ball.transform = $FPCamera/Holding.global_transform
					Ball.global_basis = $FPCamera/Holding.global_basis
					await get_tree().create_timer(0.5).timeout
					CanThrowThrowable = true
				2:
					CanThrowThrowable = false
					var BallChooser: PackedScene = BallArray[randi_range(0,2)]
					var Ball: Node3D = BallChooser.instantiate()
					Global.ProjectileSpawner.add_child(Ball)
					Ball.transform = $FPCamera/Holding.global_transform
					Ball.global_basis = $FPCamera/Holding.global_basis
					CanThrowThrowable = true
		if Input.is_action_just_pressed("SwitchThrowable"):
			if Throwable <= 2 and Throwable >= 0:
				Throwable += 1
			else:
				Throwable = 0







## Pause Menu
	if Input.is_action_just_pressed("ui_cancel") and %Menu.visible == false:
		%Menu.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		InputBlocked = true
	elif Input.is_action_just_pressed("ui_cancel") and %Menu.visible == true:
		%Menu.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		InputBlocked = false



func _physics_process(delta):
	if not is_multiplayer_authority(): return

	var current_scene = get_tree().get_current_scene()
	if current_scene and is_on_floor():
		var should_freeze = false
		if current_scene.has_method("is_chat_visible") and current_scene.is_chat_visible():
			should_freeze = true
		elif current_scene.has_method("is_inventory_visible") and current_scene.is_inventory_visible():
			should_freeze = true

		if should_freeze:
			freeze()
			return

	if is_on_floor():
		if Jumps != MaxJumps:
			Jumps = MaxJumps
		if WallJumps != MaxWallJumps:
			WallJumps = MaxWallJumps
		if IsWallRunning:
			IsWallRunning = false
	
	if not is_on_floor():
		velocity.y -= DesiredGravity * delta
	
	#if not is_on_floor() and not is_on_wall():
		#if CurrentSpeed < DiveEndSpeed and CurrentSpeed >= BaseSpeed:
			#Speed = lerp(Speed, Speed * 1.15, 0.5)



## Input / Movement stuff :]
	if InputBlocked == false:
	## If Statement Movement
		if not IsSliding and not IsDiving and not IsDead:
			IsWalking = true
	
		if IsWalking:
			MovementBasic()
			DesiredGravity = Gravity
			if CurrentSpeed <= BaseSpeed + 0.1:
				Fov = SetFov
	
	## Input Press
		if Input.is_action_just_pressed("Jump"):
			Jump()
		if Input.is_action_pressed("Crouch") and CurrentSpeed < RunSpeed:
			Crouch()
		if Input.is_action_pressed("Run") and not IsSliding and not IsDiving and not IsCrouching and is_on_floor():
			Run()
		if Input.is_action_just_pressed("Crouch") and Input.is_action_pressed("Run") and is_on_floor():
			Slide()
		if Input.is_action_pressed("Crouch") and CurrentSpeed > BaseSpeed + 0.1 and not is_on_floor() and not is_on_wall():
			Dive()
		if Input.is_action_pressed("RMB") and CurrentItem == null:
			LedgeHold()
		if Input.is_action_just_pressed("Parry"): #and CanParry:
			print("F Pressed")
			Parry(ParryBody)
	
	## Input Release
		if Input.is_action_just_released("Crouch"):
			UnCrouch()

	## Other Movement ifs
	if is_on_wall() and not IsClinging:
		WallRun()


	move_and_slide()





func MovementBasic() -> void:
	if CanMove:
		var _input_direction: Vector2 = Vector2.ZERO
		if is_multiplayer_authority():
			_input_direction = Input.get_vector("Right","Left","Down","Up")
		var _direction: Vector3 = transform.basis * Vector3(_input_direction.x, 0, _input_direction.y).normalized()
		#if _body:
			#_direction = _direction.rotated(Vector3.UP, _spring_arm_offset.rotation.y)

		if _direction:
			velocity.x = _direction.x * CurrentSpeed
			velocity.z = _direction.z * CurrentSpeed
			#if _body:
				#_body.apply_rotation(velocity)
			if CurrentSpeed > Speed:
				CurrentSpeed -= 0.1
				if CurrentSpeed > Speed and CurrentSpeed < Speed + 0.11:
					CurrentSpeed = Speed
			
			
			
			if CurrentSpeed < Speed:
				CurrentSpeed += 0.1
			elif not is_on_floor():
				if CurrentSpeed < Speed * 1.25:
					CurrentSpeed += 0.1
		else:
			velocity.x = move_toward(velocity.x, 0, CurrentSpeed)
			velocity.z = move_toward(velocity.z, 0, CurrentSpeed)
			
			Speed = BaseSpeed
			if CurrentSpeed > 0.0:
				CurrentSpeed -= 0.5
			else:
				CurrentSpeed = 0.0

func Jump():
	if Jumps > 0:
		velocity.y = JumpVelocity
		Jumps -= 1
		if CurrentNoise <= WalkNoise:
			CurrentNoise = JumpNoise

func Crouch():
	IsCrouching = true
	Speed = CrouchSpeed
	BaseCollisionShape.disabled = true
	CrouchCollisionShape.disabled = false
	$FPCamera.position.y = lerp($FPCamera.position.y, 0.25, 0.35)
	if CurrentNoise <= WalkNoise:
		CurrentNoise = CrouchNoise
	Fov = SetFov - CrouchFov
func UnCrouch():
	if AboveRay.Above == null:
		Speed = BaseSpeed
		BaseCollisionShape.disabled = false
		CrouchCollisionShape.disabled = true
		$FPCamera.position.y = lerp($FPCamera.position.y, 1.5, 0.25)
		$FPCamera.position.y = 1.25
		IsCrouching = false
		IsSliding = false
		IsDiving = false
		IsWalking = true
		$FPCamera.rotation_degrees.y = 180.0
		Fov = SetFov



func Run():
	Speed = RunSpeed
	Fov = SetFov + RunFov
	if CurrentNoise <= WalkNoise:
		CurrentNoise = RunNoise



func Slide():
	IsSliding = true
	$FPCamera.position.y = lerp($FPCamera.position.y, 0.25, 0.45)
	Fov = SetFov + SlideFov
	if CurrentNoise <= WalkNoise:
		CurrentNoise = SlideNoise
	if is_on_wall():
		DesiredGravity = 1.0
	Speed = SlideStartSpeed
	CurrentSpeed = SlideStartSpeed
	await get_tree().create_timer(0.25).timeout
	Speed = SlideEndSpeed
	if CurrentSpeed <= SlideEndSpeed + 2.5:
		UnCrouch()



func Dive():
	IsDiving = true
	$FPCamera.position.y = lerp($FPCamera.position.y, 0.5, 0.45)
	Fov = SetFov + DiveFov
	if CurrentNoise <= WalkNoise:
		CurrentNoise = DiveNoise
	Speed = DiveStartSpeed
	CurrentSpeed = DiveStartSpeed
	await get_tree().create_timer(0.25).timeout
	Speed = DiveEndSpeed
	if is_on_floor():
		IsDiving = false
		if CurrentSpeed > RunSpeed:
			Slide()
		else:
			UnCrouch()



func WallRun():
	if not Input.is_action_pressed("Jump"):
		DesiredGravity = 5.0
		Speed = WallRunSpeed
		CurrentNoise = RunNoise
		IsWallRunning = true
	elif Input.is_action_just_pressed("Jump") and WallJumps > 0 and CanWallJump:
		DesiredGravity = Gravity
		CurrentSpeed = WallRunSpeed
		CanMove = true
		velocity.y = 3.25
		WallJumps -= 1
		Jumps = 1
		CanWallJump = false
		await get_tree().create_timer(1).timeout
		CanWallJump = true



func LedgeHold():
	if InfrontRay.Infront != null and LookAtRay.LookingAt == null and FPCamera.rotation_degrees.x > 2.5 and FPCamera.rotation_degrees.x < 85 and CanCling:
		if not Input.is_action_pressed("Jump"):
			IsClinging = true
			#DesiredGravity = 0.0
			if CurrentNoise <= WalkNoise:
				CurrentNoise = LedgeGrabNoise
			if velocity.y <= 2.5:
				velocity.y = 0.0
			Speed = CrouchSpeed
		elif Input.is_action_just_released("RMB"):
			#DesiredGravity = Gravity
			Speed = BaseSpeed
			IsClinging = false
		elif Input.is_action_just_pressed("Jump") and IsClinging:
			CanCling = false
			velocity.y = 7.5
			IsClinging = false
			Jumps = 1
			await get_tree().create_timer(1).timeout
			CanCling = true



func Parry(_body: Node3D):
	CanParry = false
	ParryMesh.visible = true
	print(_body)
	if _body != self:
		if _body != null:
			if LookAtRay.LookingAt != null:
				_body = LookAtRay.LookingAt
			if _body.has_method("TakeDamage"):
				_body.TakeDamage(ParryDamage)
				await get_tree().create_timer(0.25).timeout
			else:
				if _body.is_class("RigidBody3D"): #or _body.is_class("CharacterBody3D"):
					var camera_transform = FPCamera.global_transform
					var Force: float = 0
					if Force < 1:
						Force += 1
						_body.global_transform = _body.global_transform.interpolate_with(camera_transform.translated_local(Vector3(0,0,(-2.5 + -Force / _body.mass))),1)
						#PickUpComponent.picked_up = false
						Global.object = null
						await get_tree().create_timer(0.015).timeout
						if _body.get_contact_count() == 0:
							for f in ParryForce:
								#Force = lerp(Force, Force + 0.1, 10)
								Force += 1
								_body.global_transform = _body.global_transform.interpolate_with(camera_transform.translated_local(Vector3(0,0,(-2.5 + -Force / _body.mass))),1)
								#PickUpComponent.picked_up = false
								Global.object = null
								await get_tree().create_timer(0.035).timeout
	await get_tree().create_timer(0.1).timeout
	ParryMesh.visible = false
	CanParry = true







func freeze():
	velocity.x = 0
	velocity.z = 0
	CurrentSpeed = 0
	#_body.animate(Vector3.ZERO)



func TakeDamage(Damage: float):
	Health -= Damage

func Death():
	IsDead = true
	freeze()
	InputBlocked = true
	RespawnAudioStream.stream = DeathSound
	RespawnAudioStream.play()
	IsRagdolled = true
	if not KeepInventory:
		player_inventory.ClearAll()
	
	await get_tree().create_timer(1).timeout
	#ResetCharacter()
	ResetValues()
	print(self, " Died!!")
	#if Input.is_action_pressed("LMB"):
		#ResetCharacter()

func ResetCharacter():
	var PlayerScene = preload("res://Characters/Player.tscn")
	var NewPlayer = PlayerScene.instantiate() as Player
	Parent.add_child(NewPlayer)
	NewPlayer.ResetValues()
	print("Old Instance ", self)
	queue_free()
	print(self, " Reseting...")
	print("New Instance ", NewPlayer)

func ResetValues():
	Health = MaxHealth
	global_transform.origin = RespawnPos
	CurrentSpeed = 0.0
	velocity = Vector3.ZERO
	rotation = Vector3(0,0,0)
	$FPCamera.rotation = Vector3(0,deg_to_rad(180),0)
	IsDead = false
	InputBlocked = false
	global_position = RespawnPos
	#await RespawnAudioStream.finished
	RespawnAudioStream.stream = RespawnSound
	RespawnAudioStream.play()
	DesiredGravity = Gravity
	IsRagdolled = false
	IsWalking = true
	CanMove = true
	set_process(true)
	set_physics_process(true)
	print(self, " Reset!")
	print(self, " Can Process: ", can_process())



func Teleport(Who: Node3D, Where: Vector3):
	if Who and Where:
		Who.global_position = Where
	else:
		print("Need Who and Where variables to not be nil")



func ParryAreaEntered(_body):
	ParryBody = _body
func ParryAreaExited(_body):
	ParryBody = null






@rpc("any_peer", "reliable")
func change_nick(new_nick: String):
	if nickname:
		nickname.text = new_nick

func get_color_overlay(CurrentColorOverride: Color) -> Color:
	CurrentColorOverride = ColorOverride
	return CurrentColorOverride

func get_main_mesh(ChosenSpecies: SpeciesEnum) -> Mesh:
	match ChosenSpecies:
		SpeciesEnum.Felmitt: return FelmittModel
		#SpeciesEnum.Canire: return CanireModel
		#SpeciesEnum.Aviamn: return AviamnModel
		_: return FelmittModel

@rpc("any_peer", "reliable")
func set_player_skin(SkinColor: Color, ModelName: SpeciesEnum) -> void:
	#var OverlayColor = get_color_overlay
	get_color_overlay(SkinColor)
	get_main_mesh(ModelName)
	#if ModelName:
		#MainMesh.mesh = ModelName

	#if OverlayColor:
		#MainMesh.mesh.material_overlay = OverlayColor

	#set_mesh_texture(_bottom_mesh, texture)
	#set_mesh_texture(_chest_mesh, texture)
	#set_mesh_texture(_face_mesh, texture)
	#set_mesh_texture(_limbs_head_mesh, texture)

#func set_mesh_texture(mesh_instance: MeshInstance3D, texture: CompressedTexture2D) -> void:
	#if mesh_instance:
		#var material := mesh_instance.get_surface_override_material(0)
		#if material and material is StandardMaterial3D:
			#var new_material := material
			#new_material.albedo_texture = texture
			#mesh_instance.set_surface_override_material(0, new_material)

# Inventory Network Functions - Server authoritative, client-specific
@rpc("any_peer", "call_local", "reliable")
func request_inventory_sync():
	print("Debug: request_inventory_sync called on player ", name, " (authority: ", get_multiplayer_authority(), ") by client ", multiplayer.get_remote_sender_id())

	if not multiplayer.is_server():
		return

	var requesting_client = multiplayer.get_remote_sender_id()
	if requesting_client != get_multiplayer_authority():
		push_warning("Client " + str(requesting_client) + " tried to request inventory for player " + str(get_multiplayer_authority()))
		return

	if player_inventory:
		sync_inventory_to_owner.rpc_id(requesting_client, player_inventory.to_dict())

@rpc("any_peer", "call_local", "reliable")
func sync_inventory_to_owner(inventory_data: Dictionary):
	print("Debug: sync_inventory_to_owner called on player ", name, " (authority: ", get_multiplayer_authority(), ") - local unique id: ", multiplayer.get_unique_id(), " from: ", multiplayer.get_remote_sender_id())

	if multiplayer.get_remote_sender_id() != 1:
		return

	if not is_multiplayer_authority():
		return

	if not player_inventory:
		player_inventory = PlayerInventory.new()
	player_inventory.from_dict(inventory_data)

	var level_scene = get_tree().get_current_scene()
	if level_scene:
		if is_multiplayer_authority() or get_multiplayer_authority() == multiplayer.get_unique_id():
			print("Debug: This is the local player, updating UI")
			if level_scene.has_method("update_local_inventory_display"):
				level_scene.update_local_inventory_display()
			if level_scene.has_node("InventoryUI"):
				var inventory_ui = level_scene.get_node("InventoryUI")
				if inventory_ui.visible and inventory_ui.has_method("refresh_display"):
					print("Debug: Calling refresh_display directly on InventoryUI")
					inventory_ui.refresh_display()
		else:
			print("Debug: Not the local player, skipping UI update")

@rpc("any_peer", "call_local", "reliable")
func request_move_item(from_slot: int, to_slot: int, quantity: int = -1):
	print("Debug: request_move_item called - from:", from_slot, " to:", to_slot, " on player ", name, " (authority: ", get_multiplayer_authority(), ") by client ", multiplayer.get_remote_sender_id())

	if not multiplayer.is_server():
		return

	var requesting_client = multiplayer.get_remote_sender_id()
	if requesting_client != get_multiplayer_authority():
		push_warning("Client " + str(requesting_client) + " tried to modify inventory for player " + str(get_multiplayer_authority()))
		return

	if not player_inventory:
		return

	if from_slot < 0 or from_slot >= PlayerInventory.INVENTORY_SIZE or to_slot < 0 or to_slot >= PlayerInventory.INVENTORY_SIZE:
		push_warning("Invalid slot indices: from=" + str(from_slot) + " to=" + str(to_slot))
		return

	var success = false
	if quantity == -1:
		success = player_inventory.move_item(from_slot, to_slot)
		if not success:
			success = player_inventory.swap_items(from_slot, to_slot)
			print("Debug: Swapped items between slots ", from_slot, " and ", to_slot)
		else:
			print("Debug: Moved item from slot ", from_slot, " to ", to_slot)
	else:
		success = player_inventory.move_item(from_slot, to_slot, quantity)
		print("Debug: Moved ", quantity, " items from slot ", from_slot, " to ", to_slot)

	if success:
		print("Debug: Move successful, syncing inventory to owner ", get_multiplayer_authority())
		var owner_id = get_multiplayer_authority()
		if owner_id != 1:
			sync_inventory_to_owner.rpc_id(owner_id, player_inventory.to_dict())
		else:
			var level_scene = get_tree().get_current_scene()
			if level_scene and level_scene.has_method("update_local_inventory_display"):
				level_scene.update_local_inventory_display()
	else:
		print("Debug: Move/swap failed")

@rpc("any_peer", "call_local", "reliable")
func request_add_item(item_id: String, quantity: int = 1):
	print("Debug: request_add_item called on player ", name, " (authority: ", get_multiplayer_authority(), ") by client ", multiplayer.get_remote_sender_id())

	if not multiplayer.is_server():
		return

	var requesting_client = multiplayer.get_remote_sender_id()
	if requesting_client != get_multiplayer_authority() and requesting_client != 1:
		push_warning("Client " + str(requesting_client) + " tried to add items to player " + str(get_multiplayer_authority()))
		return

	if not player_inventory:
		return

	if quantity <= 0:
		push_warning("Invalid quantity: " + str(quantity))
		return

	var item = ItemDatabase.get_item(item_id)
	if not item:
		push_warning("Item not found: " + item_id)
		return

	var remaining = player_inventory.add_item(item, quantity)
	var added = quantity - remaining
	print("Debug: Added ", added, " ", item_id, " to inventory (", remaining, " remaining)")

	if added > 0:
		var owner_id = get_multiplayer_authority()
		print("Debug: Syncing inventory to owner ", owner_id)
		if owner_id != 1:
			sync_inventory_to_owner.rpc_id(owner_id, player_inventory.to_dict())
		else:
			var level_scene = get_tree().get_current_scene()
			if level_scene and level_scene.has_method("update_local_inventory_display"):
				level_scene.update_local_inventory_display()

@rpc("any_peer", "call_local", "reliable")
func request_remove_item(item_id: String, quantity: int = 1):
	print("Debug: request_remove_item called on player ", name, " (authority: ", get_multiplayer_authority(), ") by client ", multiplayer.get_remote_sender_id())

	if not multiplayer.is_server():
		return

	var requesting_client = multiplayer.get_remote_sender_id()
	if requesting_client != get_multiplayer_authority():
		push_warning("Client " + str(requesting_client) + " tried to remove items from player " + str(get_multiplayer_authority()))
		return

	if not player_inventory:
		return

	if quantity <= 0:
		push_warning("Invalid quantity: " + str(quantity))
		return

	var removed = player_inventory.remove_item(item_id, quantity)

	if removed > 0:
		var owner_id = get_multiplayer_authority()
		if owner_id != 1:
			sync_inventory_to_owner.rpc_id(owner_id, player_inventory.to_dict())

func get_inventory() -> PlayerInventory:
	return player_inventory

#func _add_starting_items():
	#if not player_inventory:
		#return
#
	#var uspmatch = ItemDatabase.get_item("USPM")
	#var remington = ItemDatabase.get_item("M870")
	#var spear = ItemDatabase.get_item("SPEAR")
	#var flashlight = ItemDatabase.get_item("FLASHLIGHT")
#
	#if uspmatch:
		#player_inventory.add_item(uspmatch, 1)
	#if remington:
		#player_inventory.add_item(remington, 1)
	#if spear:
		#player_inventory.add_item(spear, 1)
	#if flashlight:
		#player_inventory.add_item(flashlight, 1)
