"""
This file is part of a project licensed under the MIT License.
See the LICENSE file in the root of this project for full terms.
"""

@tool
extends Stat
class_name ResourceStat

## Tracks the current state of the resource (e.g., current health or stamina).
## Always clamped between 0 and base_value.
@export var current_value: float = 0.0

## Initializes both the base and current values.
func _init(_base_value := 0.0):
	base_value = _base_value
	modified_base = _base_value
	current_value = _base_value

## Adjusts the current value of the resource.
func adjust_current(amount: float) -> void:
	current_value = clamp(current_value + amount, 0.0, modified_base)

## Sets the current value to its maximum (base value).
## Useful when restoring or resetting the stat.
func set_current_to_max() -> void:
	current_value = base_value

## Returns true if the resource is depleted.
func is_depleted() -> bool:
	return current_value <= 0.0
