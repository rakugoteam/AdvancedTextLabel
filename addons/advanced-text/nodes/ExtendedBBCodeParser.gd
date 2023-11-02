@icon("res://addons/advanced-text/icons/bbcode.svg")
@tool
extends TextParser

# ! Remember To release Icons and Emojis
# ! with need fixes for Advanced Text,
# ! before release this addon !

## This parser adds Headers {h1}, :emojis: and icons [icon:name] add Rakugo variables with <var_name> to BBCode
class_name ExtendedBBCodeParser

## Sizes of headers
## there must be 4 sizes of headers
## by default sizes are: 22, 20, 18 and 16
@export var headers : Array[int] = [22, 20, 18, 16]

## If not null it will be used by headers
@export var custom_header_font : Font

## Returns given ExtendedBBCode parsed into BBCode
func parse(text:String) -> String:
	text = parse_headers(text)
	text = EmojisDB.parse_emojis(text)
	text = MaterialIconsDB.parse_icons(text)
	
	if !Engine.is_editor_hint():
		text = Rakugo.replace_variables(text)
	
	return text

## Restores default parser settings
func reset_parser():
	headers = [22, 20, 18, 16]
	custom_header_font = null

## Parse headers in given text into BBCode
func parse_headers(text:String) -> String:
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
