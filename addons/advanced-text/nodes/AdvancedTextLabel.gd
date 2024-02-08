@tool
@icon("res://addons/advanced-text/icons/AdvancedTextLabel.svg")
extends RichTextLabel

## This class parses given text to bbcode using given TextParser
class_name AdvancedTextLabel

## If any file is set, then text form this file will be used instead of `_text` string.
@export_file var text_file := "" :
	set(value):
		text_file = value
		_text = load_text_file()
	
	get: return text_file

## Text to be parsed in too BBCode
## Use it instead of `text` from RichTextLabel
## I had to make this way as I can't override `text` var behavior
@export_multiline var _text := "":
	set(value):
		_text = value
		_parse_text()
		
	get :
		if text and _text.is_empty():
			_text = text
		
		return _text

@export var save_to_text_file := false:
	set (value):
		if text_file:
			save_text_file(_text)
			prints("Saved", get_path(), "_text to", text_file)
		
		else:
			prints("Try saved", get_path(), "_text to with out selecting text_file")
	
	get: return false

## TextParser that will be used to parse `_text`
@export var parser : TextParser:
	set (value):
		parser = value
		update_configuration_warnings()
		if parser:
			parser.changed.connect(_parse_text)

			if parser is ExtendedBBCodeParser:
				for h in parser.headers:
					h.changed.connect(_parse_text)

			_parse_text()
	
	get: return parser

func _ready():
	bbcode_enabled = true
	_parse_text()

func _parse_text() -> void:
	if !is_node_ready(): return
	if !parser.root:
		parser.root = get_tree().root

	if !parser:
		if !Engine.is_editor_hint():
			push_warning("parser is null at " + str(get_path()))

		else:
			var root := Engine.get_main_loop().edited_scene_root as Node
			push_warning("parser is null at " + str(root.get_path_to(self)))
		
		return
	
	text = parser.parse(_text)

func load_text_file() -> String:
	var f := FileAccess.open(text_file, FileAccess.READ)
	var content := "" 
	if f.get_open_error() == OK:
		content = f.get_as_text()
	
	else:
		push_error("can't load file: " + text_file)

	f.close()
	return content

func save_text_file(value:String):
	var f := FileAccess.open(text_file, FileAccess.WRITE)
	if f.get_open_error() == OK:
		f.store_string(value)
	
	else:
		push_error("can't save to file: " + text_file)

	f.close()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	if !bbcode_enabled:
		warnings.append("BBCode must be enabled.")
	
	if !parser:
		warnings.append("Need parser.")

	return warnings
