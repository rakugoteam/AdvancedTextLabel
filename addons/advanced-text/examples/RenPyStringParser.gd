@tool
@icon("res://addons/advanced-text/icons/ren16.png")
extends ExtendedBBCodeParser
class_name RenPyStringParser

func parse(text: String) -> String:
	## in Ren'Py string there is used '{}' instead of '[]'
	## so we need to replace them
	text = text.replace("{", "[")
	text = text.replace("}", "]")
	return super.parse(text)