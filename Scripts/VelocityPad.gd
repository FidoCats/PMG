extends RigidBody3D



@export_category("Properties")
@export var Velocity: Vector3 = Vector3(0,1,0)
@export var F: float = 5
@export_category("Nodes")
@export var Area: Area3D



func _ready() -> void:
	Area.body_entered.connect(Use)



func Use(_body: Node3D):
	var Force: Force3D = Force3D.new()
	_body.add_child(Force,true)
	Force.Velocity = Velocity
	Force.F = F
	#_body.global_basis = FPCamera.global_basis
	Force.SetupFinished.emit()
	Force.Move()
