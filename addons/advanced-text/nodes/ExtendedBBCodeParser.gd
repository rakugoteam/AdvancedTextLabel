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

## Safe way of getting EmojisDB singleton
var emojis_db : Node :
	get:
		if Engine.has_singleton("/root/EmojisDB"):
			return Engine.get_singleton("/root/EmojisDB")

		return null

## Safe way of getting MaterialIconsDB singleton
var icons_db : Node :
	get:
		if Engine.has_singleton("/root/MaterialIconsDB"):
			return Engine.get_singleton("/root/MaterialIconsDB")
		
		return null

## Safe way of getting Rakugo singleton
var rakugo : Node :
	get:
		if Engine.has_singleton("/root/Rakugo"):
			return Engine.get_singleton("/root/Rakugo")
	
		return null

## Returns given text parsed to BBCode
func parse(text:String) -> String:
	text = parse_headers(text)
	
	if emojis_db:
		text = parse_emojis(text)
	
	if icons_db:
		text = parse_icons(text)
	
	if rakugo:
		text = rakugo.replace_variables(text)
	
	return text

## Restores default headers settings
func reset_parser():
	headers = [22, 20, 18, 16]
	custom_header_font = null

## Parse emojis in given text into BBCode
## You need Emojis-For-Godot addon for this
func parse_emojis(text:String) -> String:
	return emojis_db.parse_emojis(text)

## Parse icons in given text into BBCode
## You need Godot-Material-Icons addon for this
func parse_icons(text:String) -> String:
	return icons_db.parse_icons(text)

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
