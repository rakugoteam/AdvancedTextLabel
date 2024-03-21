@tool
@icon("res://addons/advanced-text/icons/AdvancedTextLabel.svg")
extends RichTextLabel

## This class parses given text to bbcode using given TextParser
class_name AdvancedTextLabel

## By default links (staring from `http`) will be opened in web browser
## For custom links you can connect to `custom_link` signal
signal custom_link(args)

## Text to be parsed in too BBCode
## Use it instead of `text` from RichTextLabel
## I had to make this way as I can't override `text` var behavior
@export_multiline var _text := "":
	set(value):
		_text = value
		_parse_text()
		
	get:
		if text and _text.is_empty():
			_text = text
		
		return _text

## TextParser that will be used to parse `_text`
@export var parser: TextParser:
	set(value):
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
	meta_clicked.connect(_on_meta)
	_parse_text()

func _parse_text() -> void:
	if !is_node_ready(): return
	
	if !parser:
		push_warning("parser is null at " + str(name))
		return
	
	text = parser.parse(_text)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !bbcode_enabled:
		warnings.append("BBCode must be enabled.")
	
	if !parser:
		warnings.append("Need parser.")

	return warnings

func _on_meta(url: String) -> void:
	if url.begins_with("http"):
		OS.shell_open(url)
		return
	
	emit_signal("custom_link", url)
