"""
This file is part of a project licensed under the MIT License.
See the LICENSE file in the root of this project for full terms.
"""

@tool
extends Resource
class_name Stat

## Default value or max cap depening on the implmentation.
@export var base_value: float = 0.0

## Sum of base + modifiers (updated externally).   
@export var modified_base: float = 0.0

## Adjust the base of the stat directly.
func adjust_base(amount: float) -> void:
	base_value += amount

## Reset the modified base to the base.
func reset_modified_base() -> void:
	modified_base = base_value
