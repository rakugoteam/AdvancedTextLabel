@icon("res://addons/advanced-text/icons/bbcode.svg")
@tool
extends TextParser
class_name ExtendedBBCodeParser

var headers : Array[int] = [22, 20, 18, 16]

func parse(text:String) -> String:
	text = parse_headers(text)
	
	# if emojis_gd:
	# 	output = emojis_gd.parse_emojis(output)
			
	# if icons_gd:
	# 	output = parse_icons(output)
	
	return text

func parse_headers(text:String) -> String:
	# replace [h1]text[/h1] with [font_size=22]text[/font_size]
	# replace [h2]text[/h2] with [font_size=20]text[/font_size]
	# replace [h3]text[/h3] with [font_size=18]text[/font_size]
	# replace [h4]text[/h4] with [font_size=16]text[/font_size]

	var re = RegEx.new()
	re.compile("\\[h(?P<size>[1-4])\\](?P<text>.+?)\\[/h(?P=size)\\]")

	var founds := re.search_all(text)
	if founds.is_empty():
		return text
	
	for found in founds:
		var h_size := found.get_string("size").to_int()
		var font_size := headers[h_size - 1]
		text = text.replace("[h" + str(h_size) + "]", "[font_size=" + str(font_size) + "]")
		text = text.replace("[/h" + str(h_size) + "]", "[/font_size]")
	
	return text
