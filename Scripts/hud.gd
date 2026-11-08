extends Panel



@export var PlayerNode: Player

var DesiredPosition: Vector2



func _ready() -> void:
	DesiredPosition = position



func _process(_delta: float) -> void:
	var CalcVelocity: Vector3 = PlayerNode.velocity * PlayerNode.transform.basis
	var Velocity: Vector2 = Vector2(CalcVelocity.x,CalcVelocity.y)
	
	if Velocity != Vector2(0.0,0.0):
		position += Velocity
		position.x = clampf(position.x, DesiredPosition.x + -25, DesiredPosition.x + 25)
		position.y = clampf(position.y, DesiredPosition.y + -25, DesiredPosition.y + 25)
	else:
		position = lerp(position, DesiredPosition, 0.1)
