"""
This file is part of a project licensed under the MIT License.
See the LICENSE file in the root of this project for full terms.
"""

extends Node3D
class_name SpawnPoint3D

@export var scene_to_spawn: PackedScene
@export var is_enabled: bool = true
@export var spawn_interval: float = 2.0 # seconds

var timer: Timer

func _ready():
	timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

## Instantiate scene_to_spawn at the global_position of the SpawnPoint
func spawn_entity() -> Node3D:
	if not is_enabled or scene_to_spawn == null:
		return null

	var instance := scene_to_spawn.instantiate()
	instance.position = global_position
	get_tree().current_scene.add_child(instance)
	print("Spawned: " + str(instance))
	return instance

func _on_timer_timeout():
	spawn_entity()
