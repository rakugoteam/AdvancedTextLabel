@tool
extends Button
class_name AdvancedTextButton

@onready var adv_label := $AdvancedTextLabel

@export var markup_text := "": set = _set_markup_text
@export var markup := "default": set = _set_markup

func _ready():
	if !adv_label:
		adv_label = $AdvancedTextLabel

	adv_label.scroll_active = false
	adv_label.mouse_filter = MOUSE_FILTER_PASS
	adv_label.clip_contents = false
	_set_markup(markup)
	_set_markup_text(markup_text)

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_pressed)
	toggled.connect(_on_toggled)

func size_update():
	custom_minimum_size = adv_label.custom_minimum_size

func _set_markup_text(text: String):
	if Engine.is_editor_hint() or !ready:
		return

	if !adv_label:
		return

	markup_text = text
	adv_label.markup_text = text
	await get_tree().idle_frame
	size_update()


func _set_markup(markup: String):
	if Engine.is_editor_hint() or !ready:
		return

	if !adv_label:
		return

	markup = markup
	adv_label.markup = markup
	await get_tree().idle_frame
	size_update()

func _set_label_color(color_name: String):
	adv_label.modulate = theme.get_color(color_name, "Button")

func _set(property: StringName, value) -> bool:
	if !(property in get_property_list()):
		return false
	
	set(property, value)

	match property:
		"disabled":
			if value:
				_set_label_color("font_color_disabled")
			else:
				_set_label_color("font_color")

	return true

func is_toggled():
	return pressed and toggle_mode

func _on_mouse_entered():
	if not (disabled or is_toggled()):
		_set_label_color("font_color_hover")

func _on_mouse_exited():
	if not (disabled or is_toggled()):
		_set_label_color("font_color")

func _on_pressed():
	if not disabled:
		_set_label_color("font_color_pressed")

func _on_toggled(value: bool):
	if not disabled:
		if value:
			_set_label_color("font_color_pressed")
		else:
			_set_label_color("font_color")
