@tool
@icon("res://addons/advanced-text/icons/AdvancedTextLabel.svg")
extends RichTextLabel
class_name AdvancedTextLabel

@export_file var text_file := "" :
	set(value):
		text_file = value
		_parse_text()
	
	get: return text_file

@export_multiline var _text := "":
	set(value):
		_text = value
		if _text.is_empty():
			text = ""
			return
		
		_parse_text()
	
	get : return _text

@export var parser : TextParser:
	set (value):
		parser = value
		_parse_text()
		
	get: return parser

func _ready():
	_parse_text()

func _parse_text() -> void:
	bbcode_enabled = true

	if !parser:
		text = _text
		return
	
	if text_file:
		var f := FileAccess.open(text_file, FileAccess.READ)
		if f.get_open_error() == OK:
			_text = ""
			text = parser.parse(f.get_as_text())
		f.close()
		return
	
	text = parser.parse(_text)
