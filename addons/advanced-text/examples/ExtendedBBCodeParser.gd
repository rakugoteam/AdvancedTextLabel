@icon("res://addons/advanced-text/icons/bbcode.svg")
@tool
extends TextParser
class_name ExtendedBBCodeParser

var headers : Array[int] = [22, 20, 18, 16]

# ! Remember To release Icons and Emojis with need fixes for Advanced Text,
# ! before release this addon !

var emojis_db : Node :
	get:
		if !is_node_ready():
			return null
		
		return get_node("/root/EmojisDB")

var icons_db : Node :
	get:
		if !is_node_ready():
			return null
		
		return get_node("/root/MaterialIconsDB")


func parse(text:String) -> String:
	text = parse_headers(text)
	
	if emojis_db != null:
		text = emojis_db.parse_emojis(text)
	
	if icons_db != null:
		text = icons_db.parse_icons(text)
	
	return text

func parse_headers(text:String) -> String:
	# replace [h1]text[/h1] with [font_size=22]text[/font_size]
	# replace [h2]text[/h2] with [font_size=20]text[/font_size]
	# replace [h3]text[/h3] with [font_size=18]text[/font_size]
	# replace [h4]text[/h4] with [font_size=16]text[/font_size]

	var re = RegEx.new()
	re.compile("\\[h(?P<size>[1-4])\\](?P<text>.+?)\\[/h(?P=size)\\]")

	var x := re.search(text)
	while x != null:
		var h_size := x.get_string("size").to_int()
		var font_size := headers[h_size - 1]
		text = text.replace("[h" + str(h_size) + "]", "[font_size=" + str(font_size) + "]")
		text = text.replace("[/h" + str(h_size) + "]", "[/font_size]")
		x = re.search(text, x.get_end())
	
	return text
