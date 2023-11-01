@icon("res://addons/advanced-text/icons/bbcode.svg")
@tool
extends TextParser
class_name ExtendedBBCodeParser

## there must be 4 sizes of headers
@export var headers : Array[int] = [22, 20, 18, 16]
@export var custom_header_font : Font

# TODO make possible for icons and emojis to change
# TODO their tags so they can be more in sync with the text parser

# ! Remember To release Icons and Emojis
# ! with need fixes for Advanced Text,
# ! before release this addon !

var emojis_db : Node :
	get:
		if has_node("/root/EmojisDB"):
			return get_node("/root/EmojisDB")

		return null

var icons_db : Node :
	get:
		if has_node("/root/MaterialIconsDB"):
			return get_node("/root/MaterialIconsDB")
		
		return null

var rakugo : Node :
	get:
		if has_node("/root/Rakugo"):
			return get_node("/root/Rakugo")
	
		return null

func parse(text:String) -> String:
	text = parse_headers(text)
	
	if emojis_db:
		text = parse_emojis(text)
	
	if icons_db:
		text = parse_icons(text)
	
	if rakugo:
		text = rakugo.replace_variables(text)
	
	return text

func reset_parser():
	headers = [22, 20, 18, 16]
	custom_header_font = null

func parse_emojis(text:String) -> String:
	return emojis_db.parse_emojis(text)

func parse_icons(text:String) -> String:
	return icons_db.parse_icons(text)

func parse_headers(text:String) -> String:
	# replace [h1]text[/h1] with [font_size=22]text[/font_size]
	re.compile("\\[h(?P<size>[1-4])\\](?P<text>.+?)\\[/h(?P=size)\\]")

	result = re.search(text)
	while result != null:
		var h_size := result.get_string("size").to_int()
		var h_text := result.get_string("text")
		var font_size := headers[h_size - 1]
		replacement = "[font_size=%s]%s[/font_size]" % [str(font_size), h_text]
		
		if custom_header_font:
			var font_path := custom_header_font.resource_path
			replacement = "[font=%s]%s[/font]" % [font_path, replacement]

		text = replace_regex_match(text, result, replacement)
		result = re.search(text, result.get_end())
	
	return text
