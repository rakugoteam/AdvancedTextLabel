@tool
@icon("res://addons/advanced-text/icons/AdvancedTextLabel.svg")
extends RichTextLabel
class_name AdvancedTextLabel

@export_file var text_file := "" :
	get:
		return text_file
	
	set(value):
		text_file = value
		if text_file:
			var f := FileAccess.open(text_file, FileAccess.READ)
			_text = f.get_as_text()

@export_multiline var _text := "" :
	get:
		return _text
	
	set(value):
		_text = value
		update_text()

@export var parser : TextParser:
	get:
		return parser
	
	set(value):
		parser = value
		if value != null:
			update_text()

func _ready():
	update_text()

func update_text():
	bbcode_enabled = false
	if parser == null:
		return

	if _text.is_empty():
		return

	bbcode_enabled = true
	text = parser.parse(_text)


