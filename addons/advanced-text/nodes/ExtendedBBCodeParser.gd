@icon("res://addons/advanced-text/icons/bbcode.svg")
@tool
extends TextParser

## This parser adds Headers {h1}, :emojis: and icons [icon:name]
## add Rakugo variables with <var_name> to BBCode
class_name ExtendedBBCodeParser

## Setting for headers
## By default those settings are just sizes: 22, 20, 18 and 16
## Due to BBCode limitations shadow_color is used as background color
## Ignored properties: line_spacing, shadow_offset and shadow_size
@export var headers := _gen_headers([22, 20, 18, 16])

func _gen_headers(sizes : Array[int]) -> Array[LabelSettings]:
	var _headers : Array[LabelSettings] = []
	for size in sizes:
		var ls := LabelSettings.new()
		ls.font_size = size
		_headers.append(ls)
	
	return _headers

## Must be run at start of parsing
## Needed for plugins with other addons to work
func _start(text:String) -> String:
	if !Engine.is_editor_hint():
		text = Rakugo.replace_variables(text)
	
	return text

## Must be run at end of parsing
## Needed for plugins with other addons to work
func _end(text:String) -> String:
	text = EmojisDB.parse_emojis(text)
	text = MaterialIconsDB.parse_icons(text)
	
	return text

## Returns given ExtendedBBCode parsed into BBCode
func parse(text:String) -> String:
	in_code = find_all_in_code(text)
	text = _start(text)
	text = parse_headers(text)
	text = _end(text)
	return text

## Parse headers in given text into BBCode
func parse_headers(text:String) -> String:
	re.compile("\\[h(?P<size>[1-4])\\](?P<text>.+?)\\[/h(?P=size)\\]")

	result = re.search(text)
	while result != null:
		if is_in_code(result):
			result = re.search(text, result.get_end())
			continue

		var h_size := result.get_string("size").to_int() - 1
		var h_text := result.get_string("text")
		replacement = add_header(h_size, h_text)
		text = replace_regex_match(text, result, replacement)
		result = re.search(text, result.get_end())
	
	return text

## Returns given text with added BBCode for header with given size (1-4) to it
func add_header(header_size:int, text:String) -> String:
	if !headers: return text
	if headers.is_empty(): return text
	
	var label_settings := headers[header_size]
	var size = label_settings.font_size
	replacement = "[font_size=%s]%s[/font_size]" % [str(size), text]

	if label_settings.font:
		var path := label_settings.font.resource_path
		replacement = "[font=%s]%s[/font]" % [path, replacement]
	
	if label_settings.font_color:
		var color := "#" + label_settings.font_color.to_html()
		replacement = "[color=%s]%s[/color]" % [color, replacement]
	
	if label_settings.outline_size > 0:
		if label_settings.outline_color:
			var ocolor := "#" + label_settings.outline_color.to_html()
			replacement = "[outline_color=%s]%s[/outline_color]" % [ocolor, replacement]
		
		var osize := label_settings.outline_size
		replacement = "[outline_size=%s]%s[/outline_size]" % [osize, replacement]
	
	if label_settings.shadow_color:
		var bgcolor := "#" + label_settings.shadow_color.to_html()
		replacement = "[bgcolor=%s]%s[/bgcolor]" % [bgcolor, replacement]
		

	return replacement


