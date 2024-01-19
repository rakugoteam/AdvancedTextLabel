@tool
extends AdvancedTextLabel
class_name AdvancedTextButton

signal pressed

func _ready() -> void:
	scroll_active = false
	shortcut_keys_enabled = false
	fit_content = true
	_change_stylebox("normal")
	_change_stylebox("focus", "focus")
	mouse_entered.connect(_change_stylebox.bind("hover"))
	mouse_exited.connect(_change_stylebox.bind("normal"))

func _change_stylebox(button_style:StringName, label_style:StringName = "normal"):
	var stylebox := get_theme_stylebox(button_style, "Button")
	add_theme_stylebox_override(label_style, stylebox)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var e := event as InputEventMouseButton
		if e.button_index == MOUSE_BUTTON_LEFT:
			_change_stylebox("pressed")
			emit_signal("pressed")
			_text = "@center{@rainbow freq=0.2 sat=10 val=20 {**Clicked**}}"

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