@icon("res://addons/advanced-text/icons/bbcode.svg")
@tool
extends TextParser
class_name ExtendedBBCodeParser

var headers : Array[int] = [22, 20, 18, 16]


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


func parse(text:String) -> String:
	text = parse_headers(text)
	
	if emojis_db != null:
		text = parse_emojis(text)
	
	if icons_db != null:
		text = parse_icons(text)
	
	return text

func parse_emojis(text:String) -> String:
	# before we parse emojis we need to replace [::] to just ::
	text = text.replace("[:", ":")
	text = text.replace(":]", ":")
	text = emojis_db.parse_emojis(text)
	return text

func parse_icons(text:String) -> String:
	text = icons_db.parse_icons(text)
	return text

func parse_headers(text:String) -> String:
	# replace [h1]text[/h1] with [font_size=22]text[/font_size]
	re.compile("\\[h(?P<size>[1-4])\\](?P<text>.+?)\\[/h(?P=size)\\]")

	result = re.search(text)
	while result != null:
		var h_size := result.get_string("size").to_int()
		var h_text := result.get_string("text")
		var font_size := headers[h_size - 1]
		replacement = "[font_size=%s]%s[/font_size]" % [str(font_size), h_text]
		text = replace_regex_match(text, result, replacement)
		result = re.search(text, result.get_end())
	
	return text
