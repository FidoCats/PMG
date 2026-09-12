extends RigidBody3D



@export var DeleteTimer: Timer



func _ready() -> void:
	DeleteTimer.timeout.connect(_on_timer_timeout)
	DeleteTimer.start()



func _on_timer_timeout() -> void:
	queue_free()
