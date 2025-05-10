"""
This file is part of a project licensed under the MIT License.
See the LICENSE file in the root of this project for full terms.
"""

@tool
extends Stat
class_name AttributeStat

## Initializes the base and modified base values.
func _init(_base_value := 0.0):
	base_value = _base_value
	modified_base = _base_value

## The logic is handled by the Stat base class.
## This class exists to clearly represent non-consumable stats (like Attack, Speed, or Strength).
## It allows the StatsComponent and game systems to distinguish attribute-based stats from resource-based stats.
## You can safely use this for any stat that does not have a changing "current" value during gameplay.
