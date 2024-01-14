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
		
		if parser:
			parser.changed.connect(_parse_text)

			if parser is ExtendedBBCodeParser:
				for h in parser.headers:
					h.changed.connect(_parse_text)

		_parse_text()
	
	get: return parser

func _ready():
	_parse_text()

func _parse_text() -> void:
	if !is_node_ready(): return
	bbcode_enabled = true

	if !parser:
		text = _text
		if !Engine.is_editor_hint():
			push_warning("parser is null at " + str(get_path()))
		else:
			var root := Engine.get_main_loop().edited_scene_root as Node
			push_warning("parser is null at " + str(root.get_path_to(self)))
		return
	
	if text_file:
		var f := FileAccess.open(text_file, FileAccess.READ)
		if f.get_open_error() == OK:
			_text = ""
			text = parser.parse(f.get_as_text())
		
		else:
			push_error("can't load file: " + text_file)

		f.close()
		return
	
	text = parser.parse(_text)
