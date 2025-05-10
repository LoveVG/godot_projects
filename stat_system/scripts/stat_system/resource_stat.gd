"""
MIT License

Copyright (c) 2025 Games with Love

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights  
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell     
copies of the Software, and to permit persons to whom the Software is         
furnished to do so, subject to the following conditions:                      

The above copyright notice and this permission notice shall be included in    
all copies or substantial portions of the Software.                           

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,      
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE   
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER        
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN     
THE SOFTWARE.

NOTE: This file is provided for testing and development purposes only.
It is not production-ready and may contain unfinished or placeholder logic.
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
