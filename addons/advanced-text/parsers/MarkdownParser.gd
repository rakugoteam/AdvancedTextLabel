@tool
@icon("res://addons/advanced-text/icons/md.svg")
extends ExtendedBBCodeParser

## This parser is every limited as its just translates Markdown to BBCode
## This parser also adds :emojis: and icons {icon:name} add Rakugo variables with <var_name>
class_name MarkdownParser

## choose to use * or _ to open/close italics tag
@export_enum("*", "_") var italics = "*"

## choose to use * or _ to open/close bold tag
@export_enum("**", "__") var bold = "**"

## choose to use - or * to make points in bulleted list
@export_enum("-", "*") var points = "-"

## returns given Markdown parsed into BBCode
func parse(text: String) -> String:
	in_code = find_all_in_code(text, "`{1,3}" , "`{1,3}")
	text = _start(text)
	text = parse_headers(text)
	text = parse_imgs(text)
	text = parse_imgs_size(text)
	text = parse_hints(text)
	text = parse_links(text)
	text = parse_bold(text)
	text = parse_italics(text)
	text = parse_strike_through(text)
	text = parse_code(text)
	text = parse_table(text)
	text = parse_color_key(text)
	text = parse_color_hex(text)
	text = parse_spaces(text)
	
	# @center { text }
	text = parse_keyword(text, "center", "center")

	# alt
	# @> text <@
	text = parse_sing(text, "@>", "<@", "center")

	# @u { text }
	text = parse_keyword(text, "u", "u")

	# @right { text }
	text = parse_keyword(text, "right", "right")

	# alt
	# @> text >@
	text = parse_sing(text, "@>", ">@", "right")

	# @fill { text }
	text = parse_keyword(text, "fill", "fill")

	# @justified { text }
	text = parse_keyword(text, "justified", "fill")

	# alt
	# @< text >@
	text = parse_sing(text, "@<", ">@", "fill")

	# @indent { text }
	text = parse_keyword(text, "indent", "indent")

	# @tab { text }
	text = parse_keyword(text, "tab", "indent")

	# alt
	# @| text |@
	text = parse_sing(text, "@\\|", "\\|@", "indent")

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

	text = parse_points(text)
	text = parse_number_points(text)

	text = _end(text)

	return text

## Parse @space=x, that it add space in text in size of x
func parse_spaces(text:String) -> String:
	re.compile("@space=(?P<size>\\d+)\n")
	result = re.search(text)
	while result != null:
		if is_in_code(result):
			result = re.search(text, result.get_end())
			continue

		var size := result.get_string("size").to_int()
		replacement = "[font_size=%d] [/font_size]\n" % size
		text = replace_regex_match(text, result, replacement)
		result = re.search(text, result.get_end())

	return text

## Parse md # Headers in given text into BBCode
func parse_headers(text:String) -> String:
	re.compile("(#+)\\s+(.+\n)")
	result = re.search(text)
	while result != null:
		if is_in_code(result):
			result = re.search(text, result.get_end())
			continue
		
		var header_level = result.get_string(1).length() - 1
		var header_text = result.get_string(2)
		replacement = add_header(header_level, header_text)
		text = replace_regex_match(text, result, replacement)
		result = re.search(text, result.get_end())
	
	return text

## Parse md images to in given text to BBCode
## Example of md image: ![](path/to/img)
func parse_imgs(text:String) -> String:
	re.compile("!\\[\\]\\((.*?)\\)")
	result = re.search(text)
	while result != null:
		replacement = "[img]%s[/img]" % result.get_string(1)
		text = replace_regex_match(text, result, replacement)
		result = re.search(text, result.get_end())
	
	return text

## Parse md images with size to in given text to BBCode
## Example of md image with size: ![height x width](path/to/img)
func parse_imgs_size(text:String) -> String:
	re.compile("!\\[(\\d+)x(\\d+)\\]\\((.*?)\\)")
	result = re.search(text)
	while result != null:
		var height = result.get_string(1)
		var width = result.get_string(2)
		var path = result.get_string(3)
		replacement = "[img=%sx%s]%s[/img]" % [height, width, path]
		text = replace_regex_match(text, result, replacement)
		result = re.search(text, result.get_end())
	
	return text

## Parse md links to in given text to BBCode
## Examples of md link:
## [link](path/to/file.md)
## <https://www.example.com>
func parse_links(text:String) -> String:
	# [link](path/to/file.md)
	re.compile("\\[(.+)\\]\\((.+)\\)")
	result = re.search(text)
	while result != null:
		var link = result.get_string(1)
		var url = result.get_string(2)
		replacement = "[url=%s]%s[/url]" % [url, link]
		text = replace_regex_match(text, result, replacement)
		result = re.search(text, result.get_end())

	# <https://www.example.com>
	re.compile("<(\\w+:\\/\\/[A-Za-z0-9\\.\\-\\_\\@\\/]+)>")
	result = re.search(text)
	while result != null:
		replacement = "[url]%s[/url]" % result.get_string(1)
		text = replace_regex_match(text, result, replacement)
		result = re.search(text, result.get_end())

	return text

## Parse md hint to in given text to BBCode
## @[text](hint)
func parse_hints(text:String) -> String:
	# @[text](hint)
	re.compile("@\\[(.+)\\]\\((.+)\\)")
	result = re.search(text)
	while result != null:
		var t = result.get_string(1)
		var hint = result.get_string(2)
		replacement = "[hint=%s]%s[/hint]" % [hint, t]
		text = replace_regex_match(text, result, replacement)
		result = re.search(text, result.get_end())
	
	return text

func parse_sing(text: String, open: String, close: String, tag: String):
	var search := "%s(.*?)%s" % [open, close]
	re.compile(search)
	result = re.search(text)

	while result != null:
		var r := result.get_string(1)
		replacement = "[%s]%s[/%s]" % [tag, r, tag]
		text = replace_regex_match(text, result, replacement)
		result = re.search(text, result.get_end())

	return text

## Parse md italics to in given text to BBCode
## Example of md italics:
## If italics = "*" : *italics*
## If italics = "_" : _italics_
func parse_italics(text: String) -> String:
	var sing := ""
	# *italic*
	match italics:
		"*":
			sing = "\\*"
		"_":
			sing = "\\_"

	return parse_sing(text, sing, sing, "i")

## Parse md bold to in given text to BBCode
## Example of md bold:
## If bold = "**" : **bold**
## If bold = "__" : __bold__
func parse_bold(text: String) -> String:
	var sing := ""
	# **bold**
	match bold:
		"**":
			sing = "\\*\\*"
		"__":
			sing = "\\_\\_"
	
	return parse_sing(text, sing, sing, "b")

## Parse md strike through to in given text to BBCode
## Example of md strike through: ~~strike through~~
func parse_strike_through(text:String) -> String:
	# ~~strike through~~
	return parse_sing(text, "~~", "~~", "s")

## Parse md code to in given text to BBCode
## Example of md code:
## one line code: `code`
## multiline code: ```code```
func parse_code(text:String) -> String:
	# `code` or ```code```
	return parse_sing(text, "`{1,3}", "`{1,3}", "code")

## Parse md table to in given text to BBCode
## Example of md table:
## @tabel=2 {
## | cell1 | cell2 |
## }
func parse_table(text:String) -> String:
	# @tabel=2 {
	# | cell1 | cell2 |
	# }
	re.compile("@table=([0-9]+)\\s*\\{\\s*((\\|.+)\n)+\\}")
	result = re.search(text)
	while result != null:
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
		text = replace_regex_match(text, result, replacement)
		result = re.search(text, result.get_end())
	
	return text

func parse_color_key(text:String) -> String:
	# @color=red { text }
	re.compile("@color=([a-z]+)\\s*\\{\\s*([^\\}]+)\\s*\\}")
	result = re.search(text)
	while result != null:
		var color = result.get_string(1)
		var _text = result.get_string(2)
		replacement = "[color=%s]%s[/color]" % [color, _text]
		text = replace_regex_match(text, result, replacement)
		result = re.search(text, result.get_end())
	
	return text

func parse_color_hex(text:String) -> String:
	# @color=#ffe820 { text }
	re.compile("@color=(#[0-9a-f]{6})\\s*\\{\\s*([^\\}]+)\\s*\\}")
	result = re.search(text)
	while result != null:
		var color = result.get_string(1)
		var _text = result.get_string(2)
		replacement = "[color=%s]%s[/color]" % [color, _text]
		text = replace_regex_match(text, result, replacement)
		result = re.search(text, result.get_end())
	
	return text

func parse_effect(text:String, effect:String, args:Array) -> String:
	# @effect args { text }
	# where args: arg_name=arg_value, arg_name=arg_value
	re.compile("@%s([\\s\\w=0-9\\.]+)\\s*{(.+)}" % effect)
	result = re.search(text)
	while result != null:
		var _args = result.get_string(1)
		var _text = result.get_string(2)
		replacement = "[%s %s]%s[/%s]" % [effect, _args, _text, effect]
		text = replace_regex_match(text, result, replacement)
		result = re.search(text, result.get_end())

	# @effect val1,val2 { text }
	re.compile("@%s\\s([0-9\\.\\,\\s]+)\\s*{(.+)}" % effect)
	result = re.search(text)
	while result != null:
		var _values = result.get_string(1)
		_values = _values.replace(" ", "")
		_values = _values.split(",", false)
		var _text = result.get_string(2)
		var _args = ""
		for i in range(0, _values.size()):
			_args += "%s=%s " % [args[i], _values[i]]

		replacement = "[%s %s]%s[/%s]" % [effect, _args, _text, effect]
		text = replace_regex_match(text, result, replacement)
		result = re.search(text, result.get_end())
	
	return text

func parse_keyword(text:String, keyword:String, tag:String) -> String:
	# @keyword {text}
	re.compile("@%s\\s*{(.+)}" % keyword)
	result = re.search(text)
	while result != null:
		replacement = "[%s]%s[/%s]" % [tag, result.get_string(1), tag]
		text = replace_regex_match(text, result, replacement)
		result = re.search(text, result.get_end())

	return text

func parse_points(text: String) -> String:
	return parse_list(text, "[ul]", "[/ul]", "^(\\t*)-\\s+(.+)$")

func parse_number_points(text: String) -> String:
	return parse_list(text, "[ol type=1]", "[/ol]", "^(\\t*)\\d+\\.\\s+(.+)$")

func parse_list(text: String, open: String, close: String, regex: String):
	re.compile(regex)

	var lines := text.split("\n")
	var new_lines : Array[String] = []
	var in_list := false
	var indent := 0

	for line in lines:
		var result := re.search(line)
		if result == null:
			
			if in_list:
				in_list = false
				new_lines.append(close)

			new_lines.append(line)
			continue

		if not in_list:
			in_list = true
			new_lines.append(open)

		var current_indent := result.get_string(1).count("\t")
		if indent < current_indent:
			indent = current_indent
			new_lines.append(open)
		
		if indent > current_indent:
			indent = current_indent
			new_lines.append(close)
		
		new_lines.append(result.get_string(2))

	text = "\n".join(new_lines)

	return text

