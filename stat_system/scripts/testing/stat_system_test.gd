"""
This file is part of a project licensed under the MIT License.
See the LICENSE file in the root of this project for full terms.
"""

"""
This is not reliably commented as this is strictly for testing purposes.
This script links the UI to the StatsComponent and enables editing the values
and modifiers of different stats in real-time for debugging.
"""

extends Node3D

@onready var character = $DummyCharacter
@onready var stats_component: StatsComponent = character.get_node("StatsComponent")

#region UI Elements
@onready var stat_selector: OptionButton = $"CanvasLayer/Control/Testing Buttons/Stat Selector"
@onready var value_spinbox: SpinBox = $"CanvasLayer/Control/Testing Buttons/Value Spinbox"
@onready var temp_modifier_check: CheckButton = $"CanvasLayer/Control/Testing Buttons/Temporary"
@onready var time_spinbox: SpinBox = $"CanvasLayer/Control/Testing Buttons/Time Spinbox"

@onready var modifier_timer_list: HBoxContainer = $"CanvasLayer/Control/Modifiers/TimerList"
@onready var modifier_info_list: HBoxContainer = $"CanvasLayer/Control/Modifiers/ModifierList"

@onready var direct_adjust_button = $"CanvasLayer/Control/Testing Buttons/Direct Adjustment"
@onready var add_modifier_button = $"CanvasLayer/Control/Testing Buttons/Add Modifier"
@onready var clear_modifiers_button = $"CanvasLayer/Control/Testing Buttons/Clear Modifiers"
@onready var reset_stats_button = $"CanvasLayer/Control/Testing Buttons/Reset Stats"

# Current Stat Value Labels
@onready var current_health_value_label = $"CanvasLayer/Control/Stats/Current Values/Current Health Value"
@onready var current_attack_value_label = $"CanvasLayer/Control/Stats/Current Values/Current Attack Value"
@onready var current_speed_value_label = $"CanvasLayer/Control/Stats/Current Values/Current Speed Value"

# Modified Stat Value Labels
@onready var modified_health_value_label = $"CanvasLayer/Control/Stats/Modified Base Values/Modified Health Value"
@onready var modified_attack_value_label = $"CanvasLayer/Control/Stats/Modified Base Values/Modified Attack Value"
@onready var modified_speed_value_label = $"CanvasLayer/Control/Stats/Modified Base Values/Modified Speed Value"

# Base Stat Value Labels
@onready var base_health_value_label = $"CanvasLayer/Control/Stats/Base Values/Base Health Value"
@onready var base_attack_value_label = $"CanvasLayer/Control/Stats/Base Values/Base Attack Value"
@onready var base_speed_value_label = $"CanvasLayer/Control/Stats/Base Values/Base Speed Value"
#endregion

var temp_mod: bool = false
var timer_labels: Dictionary = {}

func _ready():
	
	# Set Temporary Value Enabled
	time_spinbox.editable = temp_mod
	
	# Populate dropdown
	stat_selector.clear()
	for stat in stats_component.stats.keys():
		stat_selector.add_item(stat.capitalize())
	
	# Connect Dropdown
	stat_selector.item_selected.connect(_on_item_selected)
	
	# Connect signal
	stats_component.stat_current_changed.connect(_on_current_changed)
	stats_component.stat_mod_base_changed.connect(_on_mod_base_changed)
	stats_component.stat_base_changed.connect(_on_base_changed)
	stats_component.modifier_expired.connect(_on_modifier_expired)
	
	# Connect buttons
	direct_adjust_button.pressed.connect(_on_direct_adjust)
	add_modifier_button.pressed.connect(_on_add_modifier)
	temp_modifier_check.pressed.connect(_on_temp_modifier_check)
	clear_modifiers_button.pressed.connect(_on_clear_modifiers)
	reset_stats_button.pressed.connect(_on_reset_stats)

	var countdown_timer := Timer.new()
	countdown_timer.name = "ModifierUpdateTimer"
	countdown_timer.wait_time = 1.0
	countdown_timer.one_shot = false
	countdown_timer.autostart = true
	countdown_timer.timeout.connect(_on_update_modifier_timers)
	add_child(countdown_timer)


	#region SetLabels
	update_current_label("Health", stats_component.get_current_value("Health"))
	update_current_label("Attack", stats_component.get_current_value("Attack"))
	update_current_label("Speed", stats_component.get_current_value("Speed"))

	update_modified_label("Health", stats_component.get_modified_base("Health"))
	update_modified_label("Attack", stats_component.get_modified_base("Attack"))
	update_modified_label("Speed", stats_component.get_modified_base("Speed"))
	
	update_base_label("Health", stats_component.get_base("Health"))
	update_base_label("Attack", stats_component.get_base("Attack"))
	update_base_label("Speed", stats_component.get_base("Speed"))
	#endregion

func get_selected_stat() -> String:
	return stat_selector.get_item_text(stat_selector.selected)

#region Signals and Buttons
func _on_current_changed(stat_name: String, new_value: float):
	update_current_label(stat_name, new_value)

func _on_mod_base_changed(stat_name: String, new_value: float):
	update_modified_label(stat_name, new_value)

func _on_base_changed(stat_name: String, new_value: float):
	update_base_label(stat_name, new_value)

func _on_item_selected(id: int):
	var stat_name = stat_selector.get_item_text(id)
	update_modifier_list(stat_name)
	update_current_label(stat_name, stats_component.get_current_value(stat_name))
	update_base_label(stat_name, stats_component.get_base(stat_name))
	update_modified_label(stat_name, stats_component.get_modified_base(stat_name))

func _on_direct_adjust():
	var stat_name := get_selected_stat()
	stats_component.adjust_current(stat_name, value_spinbox.value)

func _on_temp_modifier_check():
	temp_mod = temp_modifier_check.button_pressed
	time_spinbox.editable = temp_mod

func _on_add_modifier():
	var stat_name := get_selected_stat()
	var randid = str(randi() % 1000)

	var mod := Modifier.new()
	mod.mod_id = randi()
	mod.mod_name = randid
	mod.value = value_spinbox.value
	mod.duration = time_spinbox.value if temp_mod else INF

	stats_component.add_modifier(stat_name, mod)
	update_modifier_list(stat_name)

func _on_modifier_expired(stat_name: String, mod_id: int):
	var currently_selected = get_selected_stat()
	
	# Only refresh UI if expired modifier belongs to the currently selected stat
	if stat_name == currently_selected:
		update_modifier_list(stat_name)

		# Safely free and clean up the expired timer label
		if timer_labels.has(mod_id):
			var label = timer_labels[mod_id]
			timer_labels.erase(mod_id)
			if label and is_instance_valid(label):
				label.queue_free()
	else:
		# Remove stale reference even if not currently displayed
		timer_labels.erase(mod_id)

func _on_update_modifier_timers():
	for stat_name in stats_component.modifiers.keys():
		for mod in stats_component.modifiers[stat_name]:
			if mod.is_temporary() and timer_labels.has(mod.mod_id):
				var label = timer_labels[mod.mod_id]
				
				# Ensure label still exists before trying to update
				if label and is_instance_valid(label):
					mod.duration = max(0.0, mod.duration - 1.0)
					label.text = "%s: %.1fs" % [mod.mod_name, mod.duration]

func _on_clear_modifiers():
	var stat_name := get_selected_stat()
	stats_component.clear_stat_modifiers(stat_name)
	update_modifier_list(stat_name)

func _on_reset_stats():
	for stat_name in stats_component.stats.keys():
		var stat = stats_component.get_stat(stat_name)
		if stat is ResourceStat:
			stat.set_current_to_max()
			stats_component.emit_signal("stat_current_changed", stat_name, stat.current_value)

#endregion

#region Update UI
func update_current_label(stat_name: String, value: float):
	var change_value: Variant = "-"
	
	if stats_component.get_stat(stat_name) is AttributeStat:
		change_value = "-"
	else:
		change_value = value
	
	match stat_name:
		"Health": current_health_value_label.text = str(change_value)
		"Attack": current_attack_value_label.text = str(change_value)
		"Speed": current_speed_value_label.text = str(change_value)

func update_modified_label(stat_name: String, value: float):
	match stat_name:
		"Health": modified_health_value_label.text = str(value)
		"Attack": modified_attack_value_label.text = str(value)
		"Speed": modified_speed_value_label.text = str(value)

func update_base_label(stat_name: String, value: float):
	match stat_name:
		"Health": base_health_value_label.text = str(value)
		"Attack": base_attack_value_label.text = str(value)
		"Speed": base_speed_value_label.text = str(value)

func update_modifier_list(stat_name: String) -> void:
	# Clear existing entries
	for child in modifier_timer_list.get_children():
		child.queue_free()
	for child in modifier_info_list.get_children():
		child.queue_free()

	if stats_component.modifiers.has(stat_name):
		for mod in stats_component.modifiers[stat_name]:
			# --- Timer Label (if temporary) ---
			if mod.is_temporary():
				var timer_label := Label.new()
				timer_label.text = "%s: %.1fs" % [mod.mod_name, mod.duration]
				timer_label.add_theme_color_override("font_color", Color.ORANGE)
				timer_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				modifier_timer_list.add_child(timer_label)

				# Track it
				timer_labels[mod.mod_id] = timer_label

			# --- Modifier Info Label ---
			var mod_label := Label.new()
			mod_label.text = "%s (%.1f)" % [mod.mod_name, mod.value]
			mod_label.tooltip_text = "ID: %s\nValue: %.2f\nDuration: %s" % [
				str(mod.mod_id),
				mod.value,
				str(mod.duration) + "s" if mod.is_temporary() else "∞"
			]
			mod_label.add_theme_color_override("font_color", Color.GREEN if mod.value >= 0 else Color.RED)
			mod_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			modifier_info_list.add_child(mod_label)
	else:
		# Add fallback label if there are no modifiers to show
		var none_label := Label.new()
		none_label.text = "No active modifiers"
		modifier_info_list.add_child(none_label)

#endregion
