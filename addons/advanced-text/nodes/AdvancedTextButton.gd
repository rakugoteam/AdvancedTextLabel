@tool
extends AdvancedTextLabel

## This is a AdvancedTextLabel that behaves like a button
## @tutorial: https://rakugoteam.github.io/advanced-text-docs/2.0/AdvancedTextCheckButton/
class_name AdvancedTextButton

## Emitted when button is pressed
signal pressed

## Emitted when button is toggled
## Works only if `toggle_mode` is on.
signal toggled(value)

## If true, button will be disabled
@export var disabled := false:
	set (value):
		disabled = value
		if disabled:
			_change_stylebox("disabled")
		
		else:
			_change_stylebox("normal")
	
	get: return disabled

## If true, button will be in toggle mode
@export var toggle_mode := false
var _toggled := false:
	get: return _toggled

## If true, button will be in pressed state
@export var button_pressed := false:
	set (value):
		if toggle_mode:
			_togglef(null, value)
			button_pressed = value
		
		else: emit_signal("pressed")
	
	get: return button_pressed

## Name of node group to be used as button group
## It changes all toggleable buttons in group in to radio buttons
@export var button_group : StringName = ""

func _ready() -> void:
	scroll_active = false
	shortcut_keys_enabled = false
	fit_content = true
	_change_stylebox("normal")
	_change_stylebox("focus", "focus")
	mouse_entered.connect(_change_stylebox.bind("hover"))
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_exited():
	if toggle_mode and _toggled:
		_change_stylebox("pressed")
		return

	_change_stylebox("normal")

func _change_stylebox(button_style:StringName, label_style:StringName = "normal"):
	var stylebox := get_theme_stylebox(button_style, "Button")
	add_theme_stylebox_override(label_style, stylebox)

func _gui_input(event: InputEvent) -> void:
	if disabled: return
	
	if event is InputEventMouseButton:
		var e := event as InputEventMouseButton
		if e.button_index == MOUSE_BUTTON_LEFT and e.pressed:
			if toggle_mode:
				_togglef(null, !_toggled)
				
				if button_group:
					get_tree().call_group(button_group, "_togglef", self, !_toggled)
				
			else:
				pressed.emit()
				# print("pressed")

func _togglef(main_button: AdvancedTextButton, value: bool):
	if disabled : return
	if main_button == self: return

	if value:
		_change_stylebox("pressed")
		_toggled = true
		
	else:
		_change_stylebox("normal")
		_toggled = false
	
	toggled.emit(_toggled)

	# prints("toggled:", _toggled)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := super._get_configuration_warnings()
	
	if !fit_content:
		warnings.append("fit_content should be enabled")

	if scroll_active:
		warnings.append("Scroll shouldn't be active")
	
	if shortcut_keys_enabled:
		warnings.append("Shortcuts keys shouldn't be enabled")
	
	if context_menu_enabled:
		warnings.append("Context Menu keys shouldn't be enabled")
	
	return warnings
