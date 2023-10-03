@tool
@icon("res://addons/advanced-text/icons/ren16.png")
extends ExtendedBBCodeParser
class_name RenPyStringParser

var re := RegEx.new()
var replacement := ""

func parse(text: String) -> String:
	text = parse_links(text)
	text = parse_imgs(text)
	text = parse_imgs_size(text)
	## BBCode and Ren'Py are the same,
	## but RenPy uses '{}' instead of '[]'
	## so we need to replace them
	text = text.replace("{", "[")
	text = text.replace("}", "]")

	return super.parse(text)

func parse_links(text: String) -> String:
	# match unescaped "{a=" and "{/a}"
	re.compile("(?<!\\{)\\{(\\/{0,1})a(?:(=[^\\}]+)\\}|\\})")
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[%surl%s]" % [
				result.get_string(1), result.get_string(2)]
			text = text.replace(result.get_string(), replacement)
	return text

func parse_imgs(text:String) -> String:
	# match unescaped "{img=<path>}"
	re.compile("(?<!\\{)\\{img=([^\\}\\s]+)\\}")
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[img]%s[/img]" % result.get_string(1)
			text = text.replace(result.get_string(), replacement)
	return text

func parse_imgs_size(text:String) -> String:
	# match unescaped "{img=<path> size=<height>x<width>}"
	re.compile("(?<!\\{)\\{img=([^\\}\\s]+) size=([^\\}]+)\\}")
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[img=%s]%s[/img]" % [result.get_string(2), result.get_string(1)]
			text = text.replace(result.get_string(), replacement)
	return text
