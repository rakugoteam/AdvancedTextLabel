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

## Must be run at start of parsing
## Needed for plugins with other addons to work
func run_plugins_on_start(text:String) -> String:
	if !Engine.is_editor_hint():
		text = Rakugo.replace_variables(text)
	
	return text

## Must be run at end of parsing
## Needed for plugins with other addons to work
func run_plugins_on_end(text:String) -> String:
	text = EmojisDB.parse_emojis(text)
	text = MaterialIconsDB.parse_icons(text)
	
	return text

## Returns given ExtendedBBCode parsed into BBCode
func parse(text:String) -> String:
	in_code = find_all_in_code(text)
	text = run_plugins_on_start(text)
	text = parse_headers(text)
	text = run_plugins_on_end(text)
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
	var font_size := headers[header_size]
	replacement = "[font_size=%s]%s[/font_size]" % [str(font_size), text]

	if custom_header_font:
		var font_path := custom_header_font.resource_path
		replacement = "[font=%s]%s[/font]" % [font_path, replacement]

	return replacement


