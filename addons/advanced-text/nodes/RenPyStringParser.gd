@tool
@icon("res://addons/advanced-text/icons/ren16.png")
extends ExtendedBBCodeParser
class_name RenPyStringParser

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
	result = re.search(text)
	while result != null:
		replacement = "[%surl%s]" % [
			result.get_string(1), result.get_string(2)]
		text = replace_regex_match(text, result, replacement)
		result = re.search(text, result.get_end())
		
	return text

func parse_imgs(text:String) -> String:
	# match unescaped "{img=<path>}"
	re.compile("(?<!\\{)\\{img=([^\\}\\s]+)\\}")
	result = re.search(text)
	while result != null:
		replacement = "[img]%s[/img]" % result.get_string(1)
		text = replace_regex_match(text, result, replacement)
		result = re.search(text, result.get_end())

	return text

func parse_imgs_size(text:String) -> String:
	# match unescaped "{img=<path> size=<height>x<width>}"
	re.compile("(?<!\\{)\\{img=([^\\}\\s]+) size=([^\\}]+)\\}")
	result = re.search(text)
	while result != null:
		replacement = "[img=%s]%s[/img]" % [
			result.get_string(2), result.get_string(1)]
		text = replace_regex_match(text, result, replacement)
		result = re.search(text, result.get_end())

	return text
