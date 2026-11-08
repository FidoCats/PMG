extends RigidBody3D
class_name IsProjectileGun



@export_category("Enabled?")
@export var Enabled: bool = false
@export_category("Properties: ")
@export_enum("Semi", "Auto", "Safety") var FirerateEnum
@export var Firerate: String = "Semi"
@export var RPM: float = 420 #This is not realistic, because it is inverted.... ':[
@export var BulletAmount: int = 8
@export var Spread: Vector2 = Vector2(0.25, 0.25)
@export var Ammo: int = 15
@export var FullMag: int = 15
@export var ReloadTime: float = 0.75
@export var CanSwitchFR: bool = true
@export var CanPump: bool = false
@export var PumpAmount: int = 1
@export var MaxPump: int = 4
@export var PumpTime: float = 0.1
@export var AltReloadText: String = "-"
@export var UseAltReloadText: bool = false
@export var BottomlessMag: bool = false
@export var UseResivoir: bool = false
@export var ResivoirAmmo: int = 0
@export var EjectionForce: float = 5.0
@export var UseShells: bool = false
@export_category("Assets: ")
@export var ProjPreload: PackedScene = preload("res://Scenes/Items/Weapons/Firearms/Ammunition/Pellets/45ACPPellet.tscn")
@export var MagPreload: PackedScene = preload("res://Scenes/Items/Weapons/Firearms/Ammunition/Clipazines/45ACPMag.tscn")
@export var CasingPreload: PackedScene = preload("res://Scenes/Items/Weapons/Firearms/Ammunition/Casings/45ACPCartrige.tscn")
@export var ItemID: String = "USPM"
@export_category("Nodes: ")
@export var ShootSound: AudioStreamPlayer3D #= $"../Shoot"
@export var ReloadSound: AudioStreamPlayer3D #= $"../Reload"
@export var EmptySound: AudioStreamPlayer3D #= $"../Empty"
@export var PumpSound: AudioStreamPlayer3D

@export var MuzzleFlashSprite: AnimatedSprite3D #= %sprite1
@export var MuzzleFlashLight: SpotLight3D #= $"../MeshInstance3D/Marker3D/sprite1/SpotLight3D"

@export var AmmoLabel: Label3D #= %Ammo
@export var FRLabel: Label3D #= %FireRate
@export var ExtraLabel: Label3D
@export var ResivoirLabel: Label3D

@export var ProjectilePosMarker: Marker3D #= %Marker3D
@export var MagPosMarker: Marker3D #= %AmmoMarker
@export var EjectionPortMarker: Marker3D

@export var Collider: CollisionShape3D

@export var Collect: CollectComponent

var Spawner: Node3D = Global.ProjectileSpawner #@export 
var IsReloading: bool = false
var CanFire: bool = true
#var IsHeld: bool = false
var Parent
var WeaponItem



func _ready() -> void:
	Parent = get_parent()
	if ItemID != "":
		WeaponItem = ItemDatabase.get_item(ItemID)
		if Collect:
			Collect.CollectableItemID = ItemID
	Ammo = WeaponItem.special_value_1
	#print("Gun ready!!")



func _process(_delta: float) -> void:
	if Enabled:
		PumpAmount = clamp(PumpAmount, 1, MaxPump)
		
		
		
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
			FRLabel.text = str(Firerate)

		## Input Recognition
		
		if Enabled:
			## Shoot
			if CanFire:
				if Input.is_action_just_pressed("LMB") and not IsReloading:
					if Ammo > 0:
						ShootBullet(Firerate)
					else:
						EmptySound.play()
				elif Input.is_action_pressed("LMB") and Firerate == "Auto" and not IsReloading:
					if Ammo > 0:
						ShootBullet(Firerate)
					else:
						EmptySound.play()
				
					#if CanPump:
						#CanFire = false
			
			## Pump
			if CanPump and PumpAmount < 4:
				if Input.is_action_just_pressed("RMB") and Firerate != "Safety":
					Pump()
					#CanFire = true
			
			## Reload
				if Input.is_action_just_pressed("Reload") and Firerate != "Safety" and Ammo < FullMag:
					Reload()
			
			else:
				if Input.is_action_just_pressed("Reload") and Firerate != "Safety" and Ammo < FullMag:
					Reload()
				
			## Firerate Switching
			if Input.is_action_just_pressed("SwitchFiremode") and Firerate == "Semi" and CanSwitchFR == true:
				Firerate = "Auto"
			elif Input.is_action_just_pressed("SwitchFiremode") and Firerate == "Auto" and CanSwitchFR == true:
				Firerate = "Safety"
			elif Input.is_action_just_pressed("SwitchFiremode") and Firerate == "Safety" and CanSwitchFR == true: #FirerateEnum.size()
				Firerate = "Semi"
	
	if Collect:
		Collect.Enabled = Enabled



func Reload():
	IsReloading = true
	ReloadSound.play()
	var EmptyMag = MagPreload.instantiate()
	Global.ProjectileSpawner.add_child(EmptyMag)
	EmptyMag.global_transform = MagPosMarker.global_transform
	await get_tree().create_timer(ReloadTime).timeout
	if not UseResivoir:
		Ammo = FullMag
	else:
		if ResivoirAmmo >= FullMag:
			ResivoirAmmo -= FullMag
			Ammo = FullMag
		else:
			Ammo = ResivoirAmmo
			ResivoirAmmo -= ResivoirAmmo
	WeaponItem.special_value_1 = Ammo
	IsReloading = false

func Pump():
	IsReloading = true
	PumpSound.play()
	await get_tree().create_timer(PumpTime).timeout
	if PumpAmount < 4:
		PumpAmount += 1
		EjectCasing()
	CanFire = true
	IsReloading = false
	#print("Can Fire: ", CanFire, "\n Pump Amount: ", PumpAmount)



func EjectCasing():
	var Casing: Node3D = CasingPreload.instantiate()
	Global.ObjectSpawner.add_child(Casing, true)
	Casing.global_position = EjectionPortMarker.global_position
	var Force: Force3D = Force3D.new()
	Casing.add_child(Force,true)
	Force.Velocity = Vector3(0.0,0.0,-1.0)
	Force.F = EjectionForce / Casing.mass
	Casing.global_basis = EjectionPortMarker.global_basis
	Force.SetupFinished.emit()
	#Force.Move()



func ShootBullet(CurrentFirerate: String):
	if CanFire:
		if CurrentFirerate != "Safety":
			CanFire = false
			for i in (BulletAmount * PumpAmount):
				var Proj = ProjPreload.instantiate()
				
				Global.ProjectileSpawner.add_child(Proj,true)
				
				Proj.global_transform = ProjectilePosMarker.global_transform
				Proj.global_rotation += Vector3(randf_range(-Spread.x,Spread.x) * 0.15, randf_range(-Spread.y,Spread.y) * 0.15, 0)
				
			if CanPump == true:
				CanFire = false
				PumpAmount = 1
				
			if not CanPump:
				for i in BulletAmount * PumpAmount:
					EjectCasing()
			else:
				EjectCasing()
			
			if !BottomlessMag:
				Ammo -= 1
				WeaponItem.special_value_1 = Ammo
			


			ShootSound.play()
			MuzzleFlashSprite.play("default")
			MuzzleFlashLight.visible = true
			if CurrentFirerate == "Auto":
				await get_tree().create_timer(60/RPM).timeout
			elif CurrentFirerate == "Semi":
				await get_tree().create_timer(0.1).timeout
			MuzzleFlashLight.visible = false
			if not CanPump:
				CanFire = true
		
	else:
		EmptySound.play()



func Enable(On: bool = false) -> bool:
	Enabled = On
	if Collect:
		Collect.Enabled = !On
	if is_class("RigidBody3D"):
		freeze = Enabled
		Collider.disabled = On
	return Enabled
