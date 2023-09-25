@icon("res://addons/advanced-text/icons/AdvancedTextLabel.svg")
@tool
extends RichTextLabel
class_name AdvancedTextLabel

signal update

@export var markup_text_file := "": set = _set_markup_text_file
@export var markup_text := "": set = _set_markup_text
@export var markup := "default": set = _set_markup
@export var headers_fonts := []  # (Array, FontFile)

# should be overrider by the user
var variables := {
	"test_string" : "test string",
	"test_int" : 1,
	"test_bool" : true,
	"test_list" : [1],
	"test_dict" : {"key1" : "value1"},
	"test_color" : Color("#1acfa0"),
}

var _parser
var hf_paths : Array

func _ready() -> void:
	bbcode_enabled = true
	connect("update", Callable(self, "_on_update"))
	emit_signal("update")

func _set_headers_fonts(value : Array) -> void:
	headers_fonts = value
	emit_signal("update")

func get_hf_paths() -> Array:
	if not Engine.is_editor_hint():
		if not hf_paths.is_empty():
			return hf_paths

	for font in headers_fonts:
		hf_paths.append(font.resource_path)

	return hf_paths

func get_text_parser(_markup:String):
	if _parser == null:
		return _get_text_parser(_markup)

	if markup != _markup:
		return _get_text_parser(_markup)

func _get_text_parser(_markup_str:String):
	match _markup_str:
		"default":
			var default = ProjectSettings.get_setting("addons/advanced_text/markup")
			return _get_text_parser(default)
		
		"bbcode":
			_parser = EBBCodeParser
		"renpy":
			_parser = RenpyParser
		"markdown":
			_parser = MarkdownParser

	return _parser

func _set_markup_text_file(value:String) -> void:
	markup_text_file = value
	emit_signal("update")

func _load_file(file_path:String) -> void:
	var f = FileAccess.open(file_path, FileAccess.READ)
	var file_ext = file_path.get_extension()

	bbcode_enabled = true
	match file_ext:
		"md":
			markup = "markdown"
		"rpy":
			markup = "renpy"
		"txt":
			markup = "bbcode"

	markup_text = f.get_as_text()
	f.close()

func _set_markup_text(value:String) -> void:
	markup_text = tr(value)
	emit_signal("update")

func _on_update() -> void:
	bbcode_enabled = true
	if markup_text_file:
		_load_file(markup_text_file)

	var p = _get_text_parser(markup)
	if p == null:
		push_error("can't load parser for markup: "+ markup)
		return
	
	var vars_json = ProjectSettings.get_setting("addons/advanced_text/default_vars")
	var test_json_conv = JSON.new()
	test_json_conv.parse(vars_json)
	var default_vars = test_json_conv.get_data()
	
	if default_vars:
		variables = join_dicts([default_vars, variables])

	text = p.parse(markup_text, get_hf_paths(), variables)

func join_dicts(dicts:Array) -> Dictionary:
	var result := {}
	for dict in dicts:
		for key in dict:
			result[key] = dict[key]

	return result

func _set_markup(value:String) -> void:
	markup = value
	emit_signal("update")

func resize_to_text(char_size:Vector2, axis:="xy"):
	if "x" in axis:
		size.x += markup_text.length() * char_size.x
	if "y" in axis:
		var new_lines:int = markup_text.split("\n", false).size()
		size.y += new_lines * char_size.y;
