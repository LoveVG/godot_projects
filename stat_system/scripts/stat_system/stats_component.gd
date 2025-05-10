"""
This file is part of a project licensed under the MIT License.
See the LICENSE file in the root of this project for full terms.
"""

extends Node
class_name StatsComponent

#region === Signals ===
## Emitted when a resource stat's current value is updated.
signal stat_current_changed(stat_name: String, new_value: float)

## Emitted when the stat’s modified base (base + modifiers) changes.
signal stat_mod_base_changed(stat_name: String, new_value: float)

## Emitted when the base value of a stat is directly adjusted.
signal stat_base_changed(stat_name: String, new_value: float)

## Emitted when a temporary modifier expires (before it is removed from display).
signal modifier_expired(stat_name: String, mod_id: int)
#endregion

#region === Export Fields ===
## Holds all stat objects (ResourceStat or AttributeStat), keyed by name.
@export var stats: Dictionary = {}

## Tracks all modifiers currently applied per stat, keyed by stat name.
@export var modifiers: Dictionary = {}
#endregion

## Stores active timers for temporary modifiers per stat.
var mod_timers: Dictionary = {}

func _ready():
	# This is a programatic implementation.
	# You can also add this information directly in the inspector.
	stats["Health"] = ResourceStat.new(100)
	stats["Attack"] = AttributeStat.new(20)
	stats["Speed"] = AttributeStat.new(20)

#region === Accessors ===
func set_stat(stat_name: String, stat: Stat) -> void:
	"""
	Sets or replaces a stat in the system.
	"""
	stats[stat_name] = stat

func get_stat(stat_name: String) -> Stat:
	"""
	Returns the stat object for a given name.
	"""
	return stats.get(stat_name)

func get_current_value(stat_name: String) -> float:
	"""
	Returns the current value for ResourceStats (else 0).
	"""
	var stat = get_stat(stat_name)
	if stat is ResourceStat:
		return stat.current_value
	return 0.0

func get_modified_base(stat_name: String) -> float:
	"""
	Returns the base value after modifiers.
	"""
	var stat = get_stat(stat_name)
	return stat.modified_base if stat else 0.0

func get_base(stat_name: String) -> float:
	"""
	Returns the original base value before modifiers.
	"""
	var stat = get_stat(stat_name)
	return stat.base_value if stat else 0.0
#endregion

#region === Direct Value Changes ===
func adjust_current(stat_name: String, amount: float) -> void:
	"""
	Adjusts the current value of a ResourceStat.
	"""
	var stat := get_stat(stat_name)
	
	if stat is ResourceStat:
		stat.adjust_current(amount)
		emit_signal("stat_current_changed", stat_name, stat.current_value)

func adjust_base(stat_name: String, amount: float) -> void:
	"""
	Increases or decreases a stat’s base value.
	"""
	var stat := get_stat(stat_name)
	
	if stat:
		stat.adjust_base(amount)
		emit_signal("stat_base_changed", stat_name, stat.base_value)

func set_current_to_max(stat_name: String) -> void:
	"""
	Restores a ResourceStat’s current value to its maximum.
	"""
	var stat := get_stat(stat_name)
	
	if stat is ResourceStat:
		stat.set_current_to_max()
		emit_signal("stat_current_changed", stat_name, stat.current_value)
#endregion

#region === Modifiers ===
func add_modifier(stat_name: String, modifier: Modifier) -> void:
	"""
	Adds a new modifier to a stat, enforcing stacking rules and duration.
	"""
	if not stats.has(stat_name):
		return

	if not modifiers.has(stat_name):
		modifiers[stat_name] = []
	
	var mod_list = modifiers[stat_name]

	# Handle non-stackable modifiers
	if not modifier.can_stack:
		# Remove existing modifiers with the same name
		for m in mod_list.duplicate(): # duplicate to avoid mutation during iteration
			if m.mod_name == modifier.mod_name:
				remove_modifier(stat_name, m.mod_id)

	# Handle stacking limit
	elif modifier.can_stack and modifier.max_stacks > 0:
		var stack_count := 0
		for m in mod_list:
			if m.mod_name == modifier.mod_name:
				stack_count += 1
		if stack_count >= modifier.max_stacks:
			return # Max stacks reached, do not apply new one

	# Store the new modifier
	mod_list.append(modifier)
	modifiers[stat_name] = mod_list

	# Recalculate and apply the values with mods
	recalculate_modified_base(stat_name)

	# Setup timer if modifier is temporary
	if modifier.is_temporary():
		if not mod_timers.has(stat_name):
			mod_timers[stat_name] = {}

		var timer := Timer.new()
		timer.wait_time = modifier.duration
		timer.one_shot = true
		# Connect time timeout to remove the mod
		timer.timeout.connect(func():
			remove_modifier(stat_name, modifier.mod_id)
			emit_signal("modifier_expired", stat_name, modifier.mod_id)
			timer.queue_free()
		)
		mod_timers[stat_name][modifier.mod_id] = timer
		add_child(timer)
		timer.start()

func recalculate_modified_base(stat_name: String) -> void:
	"""
	Rebuilds the modified base from the original base + all active modifiers.
	"""
	var stat := get_stat(stat_name)
	if not stat:
		return

	# Start from base
	stat.modified_base = stat.base_value

	# Add up all modifier values
	if modifiers.has(stat_name):
		for mod in modifiers[stat_name]:
			stat.modified_base += mod.value

	# Clamp current_value for ResourceStat if max (modified_base) drops
	if stat is ResourceStat:
		var resource := stat as ResourceStat
		if resource.current_value > stat.modified_base:
			resource.current_value = stat.modified_base
			emit_signal("stat_current_changed", stat_name, resource.current_value)

	emit_signal("stat_mod_base_changed", stat_name, stat.modified_base)

func remove_modifier(stat_name: String, mod_id: int) -> void:
	"""
	Removes a specific modifier by ID and updates the stat.
	"""
	if not modifiers.has(stat_name):
		return

	var stat := get_stat(stat_name)
	if not stat:
		return

	# Remove the modifier by ID
	modifiers[stat_name] = modifiers[stat_name].filter(func(m): return m.mod_id != mod_id)

	# Clean up if no modifiers remain
	if modifiers[stat_name].is_empty():
		modifiers.erase(stat_name)

	# Recalculate total value after removal
	recalculate_modified_base(stat_name)

	# Remove associated expiration timer
	if mod_timers.has(stat_name) and mod_timers[stat_name].has(mod_id):
		mod_timers[stat_name][mod_id].queue_free()
		mod_timers[stat_name].erase(mod_id)
		if mod_timers[stat_name].is_empty():
			mod_timers.erase(stat_name)

func clear_stat_modifiers(stat_name: String) -> void:
	"""
	Removes all modifiers from a single stat.
	"""
	if modifiers.has(stat_name):
		modifiers.erase(stat_name)

	if mod_timers.has(stat_name):
		for timer in mod_timers[stat_name].values():
			timer.queue_free()
		mod_timers.erase(stat_name)

	get_stat(stat_name).reset_modified_base()
	
	emit_signal("stat_mod_base_changed", stat_name, get_modified_base(stat_name))

func clear_all_modifiers():
	"""
	Removes all modifiers and timers from all stats.
	"""
	modifiers.clear()
	mod_timers.clear()

func has_modifier(stat_name: StringName) -> bool:
	"""
	Returns true if the stat has at least one active modifier.
	"""
	return modifiers.has(stat_name)
#endregion
