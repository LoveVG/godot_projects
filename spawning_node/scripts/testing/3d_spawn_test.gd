"""
This file is part of a project licensed under the MIT License.
See the LICENSE file in the root of this project for full terms.
"""

extends Node3D

@onready var spawn_point: SpawnPoint3D = $SpawnPoint3D
@onready var camera: Camera3D = $Camera3D

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			spawn_point.position  = raycast_from_mouse(event.position)
			spawn_point.position.y = 1

func raycast_from_mouse(m_pos):
	var cam = get_viewport().get_camera_3d()
	var ray_start = cam.project_ray_origin(m_pos)
	var ray_end = ray_start + cam.project_ray_normal(m_pos) * 10000
	var world3d : World3D = get_world_3d()
	var space_state = world3d.direct_space_state
	
	if space_state == null:
		return
	
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	query.collide_with_areas = true
	
	return space_state.intersect_ray(query)["position"]
