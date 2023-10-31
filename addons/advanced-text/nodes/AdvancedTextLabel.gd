@tool
@icon("res://addons/advanced-text/icons/AdvancedTextLabel.svg")
extends RichTextLabel
class_name AdvancedTextLabel

@export_file var text_file := "" :
	set(value):
		text_file = value
		var f := FileAccess.open(text_file, FileAccess.READ)
			
		if f.get_open_error() == OK:
			_text = f.get_as_text()	
		f.close()
	
	get: return text_file

@export_multiline var _text := "":
	set(value):
		_text = value
		_parse_text()
	
	get : return _text

@export var parser : TextParser:
	set (value):
		if !is_ready():
			return
		
		parser = value
		_parse_text()
	
	get: return parser

func _parse_text() -> void:
	bbcode_enabled = true

	if !parser:
		text = _text
		return
	
	text = parser.parse(_text)
