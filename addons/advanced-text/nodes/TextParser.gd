@tool
extends Node
class_name TextParser

var re := RegEx.new()
var result : RegExMatch
var replacement := ""

func parse(text:String) -> String:
	return text

func replace_regex_match(text:String, result:RegExMatch, replacement:String) -> String:
	
	var start_string := text.substr(0, result.get_start())
	var end_string := text.substr(result.get_end(), text.length())
	return start_string + replacement + end_string