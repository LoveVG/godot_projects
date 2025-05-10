extends Node

@export var lifetime: float = 3.0

func _ready():
	var timer := Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()

func _on_timer_timeout():
	print("Deleting: ", self.name)
	queue_free()
