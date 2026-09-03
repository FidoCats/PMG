#@tool

extends RigidBody3D
class_name Projectile

@export_category("Prefrences: ")
@export var SPEED = 35.0
@export var RANGE = 150.0
@export var FallOffDistance = 90.0
@export var PenetrationChance: float = 5.0
@export var RollAmount: float = 150.0
#@export_category("Nodes: ")
#@export var DeleteTimer: Timer

var travelled_distance = 0.0

var CanKill:bool = false

var PosiOrNot: bool

#@export var DentPreload = preload("res://Scenes/dent.tscn")



func _ready() -> void:
	#Global.BulletTimer = %Timer #0.045
	gravity_scale = 0.35
	await get_tree().create_timer(0.045).timeout
	CanKill = true
	PosiOrNot = randi_range(0,1)
	if PosiOrNot == false:
		RollAmount = -RollAmount

func _physics_process(delta):
	position += transform.basis.z * SPEED * delta
	travelled_distance += SPEED * delta
	
	rotation_degrees.z = lerp(rotation_degrees.z, RollAmount, 0.5)
	
	if travelled_distance > FallOffDistance:
		position.x += 0.15
	if travelled_distance > RANGE:
		queue_free()

func _on_timer_timeout():
	queue_free()

func _on_body_entered(body):
	if CanKill == true:
		if not body.is_class("Area3D"):
			#print(self, " Hit a thing.")
			#var Dent = DentPreload.instantiate()
			#body.add_child(Dent)
			#Dent.global_position = global_position
			#Dent.global_rotation = global_rotation
			if body.has_method("TakeDamage"):
				body.TakeDamage(15)
				#print("Damaged ", body)
				#print("Health: ", body.Health)
			if -PenetrationChance < 0.0:
				var PenetrationCalculation: float = randf_range(-PenetrationChance, 0.0)
				if PenetrationCalculation < 0.0 - PenetrationChance / 3.0:
					pass
				else:
					queue_free()
