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
