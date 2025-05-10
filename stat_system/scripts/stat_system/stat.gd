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
