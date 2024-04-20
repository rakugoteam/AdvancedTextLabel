@tool
extends AdvancedTextButton

## This is AdvancedTextLabel that baves like toggle switch
## This node needs Godot Material Icons addon to work
## @tutorial: https://rakugoteam.github.io/advanced-text-docs/2.0/AdvancedTextButton/
class_name AdvancedTextCheckButton

## Size of Matrial Icon that will be used as toggle icon
@export var toggle_icon_size := 24:
	set(value):
		toggle_icon_size = value
		_update_switch(_toggled)

	get: return toggle_icon_size

## Name of Matrial Icon that will be used when button is toggle on
## This will replace `[switch]` in text
@export var toggle_on_icon := "toggle-switch-outline":
	set(value):
		toggle_on_icon = value
		_update_switch(_toggled)

	get: return toggle_on_icon

## Name of Matrial Icon that will be used when button is toggle off
## This will replace `[switch]` in text
@export var toggle_off_icon := "toggle-switch-off-outline":
	set(value):
		toggle_off_icon = value
		_update_switch(_toggled)

	get: return toggle_off_icon

## Use this instead of _text
## `[switch]` will be replaced with toggle icon
@export_multiline var main_text := "label [switch]":
	set(value):
		main_text = value
		_update_switch(_toggled)
	
	get: return main_text

func _ready() -> void:
	toggled.connect(_update_switch)
	_update_switch(_toggled)

func _update_switch(value: bool):
	var icon = toggle_off_icon
	if value: icon = toggle_on_icon
	_text = main_text.replace(
		"[switch]",
		"[icon:%s, %d]" % [
			icon, toggle_icon_size
		]
	)
