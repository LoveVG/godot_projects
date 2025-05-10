"""
This file is part of a project licensed under the MIT License.
See the LICENSE file in the root of this project for full terms.
"""

@tool
extends Resource
class_name Modifier

## A unique identifier for this modifier instance.
## Used to track and remove specific modifiers.
@export var mod_id: int

## A string-based name for this modifier (e.g., "Rage", "Poison").
## Used for stack comparisons.
@export var mod_name: StringName

## The numeric value this modifier adds or subtracts from the stat.
@export var value: float

## The duration in seconds this modifier remains active.
## Use INF for permanent modifiers. Any value < INF is considered temporary.
@export var duration: float = INF

## Determines whether this modifier can stack with others of the same name.
## If false, any existing modifier with the same name will be replaced.
@export var can_stack: bool = true

## The maximum number of allowed stacks for this modifier.
## Only applies if can_stack is true.
@export var max_stacks: int = 1

## Constructor for programmatic creation.
func _init(_id := -1, _mod_name: = "", _value := 0.0, _duration := INF):
	mod_id = _id
	mod_name = _mod_name
	value = _value
	duration = _duration

## Returns true if this modifier has a limited duration (i.e., temporary).
func is_temporary() -> bool:
	return duration < INF
