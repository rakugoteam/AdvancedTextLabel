@tool
@icon("res://addons/advanced-text/icons/md.svg")
extends ExtendedBBCodeParser
class_name MarkdownParser

@export_enum("*", "_") var italics = "*"
@export_enum("**", "__") var bold = "**"
@export_enum("-", "*") var points = "-"

var re := RegEx.new()
var replacement := ""

func parse(text: String) -> String:
	text = parse_imgs(text)
	text = parse_imgs_size(text)
	text = parse_urls(text)
	text = parse_links(text)
	text = parse_bold(text)
	text = parse_italics(text)
	text = parse_strike_through(text)
	text = parse_code(text)
	text = parse_table(text)
	text = parse_color_key(text)
	text = parse_color_hex(text)
	
	# @center { text }
	text = parse_keyword(text, "center", "center")

	# @u { text }
	text = parse_keyword(text, "u", "u")

	# @right { text }
	text = parse_keyword(text, "right", "right")

	# @fill { text }
	text = parse_keyword(text, "fill", "fill")

	# @justified { text }
	text = parse_keyword(text, "justified", "fill")

	# @indent { text }
	text = parse_keyword(text, "indent", "indent")

	# @tab { text }
	text = parse_keyword(text, "tab", "indent")

	# @wave amp=50 freq=2{ text }
	text = parse_effect(text, "wave", ["amp", "freq"])

	# @tornado radius=5 freq=2{ text }
	text = parse_effect(text, "tornado", ["radius", "freq"])

	# @shake rate=5 level=10{ text }
	text = parse_effect(text, "shake", ["rate", "level"])

	# @fade start=4 length=14{ text }
	text = parse_effect(text, "fade", ["start", "length"])

	# @rainbow freq=0.2 sat=10 val=20{ text }
	text = parse_effect(text, "rainbow", ["freq", "sat", "val"])

	# text = parse_points(text)

	return super.parse(text)

func base_parse(text:String, open_md:String, close_md:String, open_bbc:String, close_bbc:String):
	re.compile(open_md + "(?P<text>.+?)" + open_bbc)
	for result in re.search_all(text):
		if result.get_string():
			replacement = open_bbc + result.get_string("text") + close_bbc
			text = text.replace(result.get_string(), replacement)
	
	return text

func parse_imgs(text:String) -> String:
	# ![](path/to/img)
	re.compile("!\\[\\]\\((.*?)\\)")
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[img]%s[/img]" % result.get_string(1)
			text = text.replace(result.get_string(), replacement)
	
	return text

func  parse_imgs_size(text:String) -> String:
	# ![height x width](path/to/img)
	re.compile("!\\[(\\d+)x(\\d+)\\]\\((.*?)\\)")
	for result in re.search_all(text):
		if result.get_string():
			var height = result.get_string(1)
			var width = result.get_string(2)
			var path = result.get_string(3)
			replacement = "[img=%sx%s]%s[/img]" % [height, width, path]
			text = text.replace(result.get_string(), replacement)
	
	return text

func parse_urls(text:String) -> String:
	# https://www.example.com
	re.compile("([=\\[\\]\\(]?)(\\w+:\\/\\/[A-Za-z0-9\\.\\-\\_\\@\\/]+)([\\]\\[\\)]?)")
	for result in re.search_all(text):
		if result.get_string():
			if !result.get_string(1).is_empty():
				continue

			if !result.get_string(3).is_empty():
				continue

			replacement = "[url]%s[/url]" % result.get_string(2)
			text = text.replace(result.get_string(), replacement)
	
	return text

func parse_links(text:String) -> String:
	# [link](path/to/file.md)
	re.compile("(\\]?)\\[(.+)\\]\\(([A-Za-z0-9\\.-_@\\/]+)\\)")
	for result in re.search_all(text):
		if result.get_string():
			if !result.get_string(1).is_empty():
				continue

			var link = result.get_string(2)
			var url = result.get_string(3)
			replacement = "[url=%s]%s[/url]" % [url, link]
			text = text.replace(result.get_string(), replacement)
	
	return text

func parse_italics(text: String) -> String:
	# turn _text_ into [i]text[/i], but only if there are no spaces between the _ and the text
	
	var _italics := ""
	match italics:
		"*":
			_italics = "\\*"
		"_":
			_italics = "\\_"
	
	return base_parse(text, _italics, _italics, "[i]", "[/i]")

func parse_bold(text: String) -> String:
	# turn **text** into [b]text[/b],
	# but only if there are no spaces between the ** and the text

	var _bold := ""
	match bold:
		"**":
			_bold = "\\*\\*"
		"__":
			_bold = "\\_\\_"

	return base_parse(text, _bold, _bold, "[b]", "[/b]")

func parse_strike_through(text:String) -> String:
	# ~~strike through~~
	re.compile("~~(.*?)~~")
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[s]%s[/s]" % result.get_string(1)
			text = text.replace(result.get_string(), replacement)
	
	return text

func parse_code(text:String) -> String:
	# `code`
	re.compile("`{1,3}(.*?)`{1,3}")
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[code]%s[/code]" % result.get_string(1)
			text = text.replace(result.get_string(), replacement)
	
	return text

func parse_table(text:String) -> String:
	# @tabel=2 {
	# | cell1 | cell2 |
	# }
	re.compile("@table=([0-9]+)\\s*\\{\\s*((\\|.+)\n)+\\}")
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[table=%s]" % result.get_string(1)
			# cell 1 | cell 2
			var r = result.get_string()
			var lines = r.split("\n")
			for line in lines:
				if line.begins_with("|"):
					var cells : Array = line.split("|", false)
					for cell in cells:
						replacement += "[cell]%s[/cell]" % cell
					replacement += "\n"
			replacement += "[/table]"
			text = text.replace(result.get_string(), replacement)
	
	return text

func parse_color_key(text:String) -> String:
	# @color=red { text }
	re.compile("@color=([a-z]+)\\s*\\{\\s*([^\\}]+)\\s*\\}")
	for result in re.search_all(text):
		if result.get_string():
			var color = result.get_string(1)
			var _text = result.get_string(2)
			replacement = "[color=%s]%s[/color]" % [color, _text]
			text = text.replace(result.get_string(), replacement)
	
	return text

func parse_color_hex(text:String) -> String:
	# @color=#ffe820 { text }
	re.compile("@color=(#[0-9a-f]{6})\\s*\\{\\s*([^\\}]+)\\s*\\}")
	for result in re.search_all(text):
		if result.get_string():
			var color = result.get_string(1)
			var _text = result.get_string(2)
			replacement = "[color=%s]%s[/color]" % [color, _text]
			text = text.replace(result.get_string(), replacement)
		
	return text

func parse_effect(text:String, effect:String, args:Array) -> String:
	# @effect args { text }
	# where args: arg_name=arg_value, arg_name=arg_value
	re.compile("@%s([\\s\\w=0-9\\.]+)\\s*{(.+)}" % effect)
	for result in re.search_all(text):
		if result.get_string():
			var _args = result.get_string(1)
			var _text = result.get_string(2)
			replacement = "[%s %s]%s[/%s]" % [effect, _args, _text, effect]
			text = text.replace(result.get_string(), replacement)

	# @effect val1,val2 { text }
	re.compile("@%s\\s([0-9\\.\\,\\s]+)\\s*{(.+)}" % effect)
	for result in re.search_all(text):
		if result.get_string():
			var _values = result.get_string(1)
			_values = _values.replace(" ", "")
			_values = _values.split(",", false)
			var _text = result.get_string(2)
			var _args = ""
			for i in range(0, _values.size()):
				_args += "%s=%s " % [args[i], _values[i]]
			replacement = "[%s %s]%s[/%s]" % [effect, _args, _text, effect]
			text = text.replace(result.get_string(), replacement)
	
	return text

func parse_keyword(text:String, keyword:String, tag:String) -> String:
	# @keyword {text}
	re.compile("@%s\\s*{(.+)}" % keyword)
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[%s]%s[/%s]" % [tag, result.get_string(1), tag]
			text = text.replace(result.get_string(), replacement)

	return text

func parse_points(text: String) -> String:
	# this will turn:
	# - point 1
	# - point 2

	# into:
	# [ul] point 1
	# point 2 [/ul]

	# this need to be done line by line, so we can check if next line has a point or not, if not then we close the list

	var lines := text.split("\n")
	var new_lines := []
	var in_list := false
	return text
	
