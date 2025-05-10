"""
This file is part of a project licensed under the MIT License.
See the LICENSE file in the root of this project for full terms.
"""

extends Node2D

@onready var spawn_point: SpawnPoint2D = $SpawnPoint2D

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		var pos = get_viewport().get_mouse_position()
		spawn_point.global_position = pos
