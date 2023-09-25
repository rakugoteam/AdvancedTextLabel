@tool
extends Control

@export_multiline var text := "[center][shake rate=5 level=10]**Clik to edit me**[/shake][/center]"
@export var m_edit : TextEdit
@export var button : Button

func _ready():
	button.markup_text = text
	m_edit.text = text
	button.toggled.connect(_on_button_toggled)
	m_edit.text_changed.connect(_on_text_changed)

func _on_button_toggled(toggled: bool):
	if toggled:
		var pos = button.global_position
		pos.y += button.size.y
		var r = $Popup.size
		var rect = Rect2(pos, r)
		$Popup.popup(rect)

	else:
		$Popup.hide()

func _on_text_changed():
	button.markup_text = m_edit.text

func _process(delta):
	if $Popup.visible:
		if Input.is_key_pressed(KEY_ESCAPE):
			$Popup.hide()
			button.disabled = false
