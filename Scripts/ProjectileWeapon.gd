#@tool

extends Node3D
class_name IsGun



## Preloads
#var ProjPreload = preload("res://Scenes/bullet.tscn")
#var MagPreload = preload("res://Scenes/pistol_mag.tscn")
#
## Effects
#@onready var ShootSound: AudioStreamPlayer3D = $"../Shoot"
#@onready var ReloadSound: AudioStreamPlayer3D = $"../Reload"
#@onready var EmptySound: AudioStreamPlayer3D = $"../Empty"
#
#@onready var MuzzleFlashSprite: AnimatedSprite3D = %sprite1
#@onready var MuzzleFlashLight: SpotLight3D = $"../MeshInstance3D/Marker3D/sprite1/SpotLight3D"
#
#@onready var AmmoLabel: Label3D = %Ammo
#@onready var FRLabel: Label3D = %FireRate
#@onready var AmmoPosMarker: Marker3D = %Marker3D
#@onready var MagPosMarker: Marker3D = %AmmoMarker
#@onready var Spawner: Node3D = %Spawner

@export_category("Properties: ")
@export var Firerate: String = "Semi"
@export var BulletAmount: int = 8
@export var Spread: Vector2 = Vector2(0.25, 0.25)
@export var Ammo: int = 15
@export var FullMag: int = 15
@export var ReloadTime: float = 0.75
@export var CanSwitchFR: bool = true
@export var CanPump: bool = false
@export var PumpAmount: int = 1
@export var PumpTime: float = 0.1
@export var AltReloadText: String = "-"
@export var UseAltReloadText: bool = false
@export var BottomlessMag: bool = false
@export var EjectionForce: float = 1.0
@export_category("Assets: ")
@export var ProjPreload: PackedScene = preload("res://Scenes/Items/Weapons/Firearms/Ammunition/Pellets/45ACPPellet.tscn")
@export var MagPreload: PackedScene = preload("res://Scenes/Items/Weapons/Firearms/Ammunition/Clipazines/45ACPMag.tscn")
@export var CasingPreload: PackedScene = preload("res://Scenes/Items/Weapons/Firearms/Ammunition/Casings/45ACPCartrige.tscn")
@export_category("Nodes: ")
@export var ShootSound: AudioStreamPlayer3D #= $"../Shoot"
@export var ReloadSound: AudioStreamPlayer3D #= $"../Reload"
@export var EmptySound: AudioStreamPlayer3D #= $"../Empty"

@export var MuzzleFlashSprite: AnimatedSprite3D #= %sprite1
@export var MuzzleFlashLight: SpotLight3D #= $"../MeshInstance3D/Marker3D/sprite1/SpotLight3D"

@export var AmmoLabel: Label3D #= %Ammo
@export var FRLabel: Label3D #= %FireRate
@export var ExtraLabel: Label3D

@export var ProjectilePosMarker: Marker3D #= %Marker3D
@export var MagPosMarker: Marker3D #= %AmmoMarker
@export var EjectionPortMarker: Marker3D

var Spawner: MultiplayerSpawner = Global.ProjectileSpawner #@export 
var IsReloading: bool = false
var CanFire: bool = true
#var IsHeld: bool = false
var Parent



func _ready() -> void:
	Parent = get_parent()
	#print("Gun ready!!")



func _process(_delta: float) -> void:
	PumpAmount = clamp(PumpAmount, 1, 4)
	
	if not is_multiplayer_authority(): return
	
	#if get_parent().get_parent().is_class("Marker3D"):#!= Global.ObjectSpawner:
	
	if Ammo < 0:
		Ammo = 0
	elif Ammo > FullMag:
		Ammo = FullMag 



	# Ammo Counter
	if IsReloading == false:
		AmmoLabel.text = str(Ammo,"/",FullMag)
	elif IsReloading == true:
		if !UseAltReloadText:
			AmmoLabel.text = "Reloading"
		else:
			AmmoLabel.text = AltReloadText
	
	## Firerate label
	if CanSwitchFR:
		FRLabel.text = Firerate

	## Input Recognition
	
	## Shoot
	if CanFire:
		if Input.is_action_just_pressed("LMB") and Firerate == "Semi" and Ammo > 0 and IsReloading == false and CanFire == true:
			ShootBullet()
			if CanPump:
				CanFire = false
			
		if Input.is_action_pressed("LMB") and Firerate == "Auto" and Ammo > 0  and IsReloading == false and CanFire == true:
			var NoFullAuto = randi_range(0,50)
			if NoFullAuto > 25:
				ShootBullet()
			
		# No Ammo
		elif Input.is_action_just_pressed("LMB") and Ammo <= 0 and Firerate != "Safety" and CanFire == true:
			EmptySound.play()
	
	# Reload
	if CanPump and PumpAmount < 4:
		if Input.is_action_just_pressed("RMB") and Firerate != "Safety":
			Pump()
			CanFire = true
	
		if Input.is_action_just_pressed("Reload") and Firerate != "Safety" and Ammo < FullMag:
			Reload()
	
	else:
		if Input.is_action_just_pressed("Reload") and Firerate != "Safety" and Ammo < FullMag:
			Reload()
		
	# Firerate Switching
	if Input.is_action_just_pressed("SwitchFiremode") and Firerate == "Semi" and CanSwitchFR == true:
		Firerate = "Auto"
	elif Input.is_action_just_pressed("SwitchFiremode") and Firerate == "Auto" and CanSwitchFR == true:
		Firerate = "Safety"
	elif Input.is_action_just_pressed("SwitchFiremode") and Firerate == "Safety" and CanSwitchFR == true:
		Firerate = "Semi"



func Reload():
	IsReloading = true
	var EmptyMag = MagPreload.instantiate()
	Global.ProjectileSpawner.add_child(EmptyMag)
	EmptyMag.global_transform = MagPosMarker.global_transform
	await get_tree().create_timer(ReloadTime).timeout
	Ammo = FullMag
	IsReloading = false

func Pump():
	IsReloading = true
	await get_tree().create_timer(PumpTime).timeout
	if PumpAmount < 4:
		PumpAmount += 1
		EjectCasing()
	CanFire = true
	IsReloading = false
	#print("Can Fire: ", CanFire, "\n Pump Amount: ", PumpAmount)



func EjectCasing():
	var Casing: Node3D = CasingPreload.instantiate()
	Global.ObjectSpawner.add_child(Casing)
	#Casing.global_position = EjectionPortMarker.global_position
	#Casing.global_rotation = EjectionPortMarker.global_rotation
	var camera_transform = EjectionPortMarker.global_transform
	var Force: float = 0
	Casing.global_transform = Casing.global_transform.interpolate_with(camera_transform.translated_local(Vector3(0,0,(-0.25 + -Force / Casing.mass))),1)
	for i in EjectionForce:
		Force += 0.25
		Casing.global_transform = Casing.global_transform.interpolate_with(camera_transform.translated_local(Vector3(0,0,(-0.25 + -Force))),1)
		await get_tree().create_timer(0.35).timeout



func ShootBullet():
	if CanFire:
		for i in (BulletAmount * PumpAmount):
			var Proj = ProjPreload.instantiate()
			
			Global.ProjectileSpawner.add_child(Proj)
			
			Proj.global_transform = ProjectilePosMarker.global_transform
			Proj.global_rotation += Vector3(randf_range(-Spread.x,Spread.x) * 0.15, randf_range(-Spread.y,Spread.y) * 0.15, 0)
			
			if CanPump == true:
				CanFire = false
				PumpAmount = 1
			
			EjectCasing()
		
		if !BottomlessMag:
			Ammo -= 1
		


		ShootSound.play()
		MuzzleFlashSprite.play("default")
		MuzzleFlashLight.visible = true
		await get_tree().create_timer(0.25).timeout
		MuzzleFlashLight.visible = false
	
	else:
		EmptySound.play()
