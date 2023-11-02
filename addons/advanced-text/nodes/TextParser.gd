@tool
extends Resource

## Base class used by AdvancedTexts addon Parsers
class_name TextParser

var re := RegEx.new()
var result : RegExMatch
var replacement := ""

## This only exits to be override by Parsers classes that inherits from it
## This func just returns given with out any changes
func parse(text:String) -> String:
	return text

## Restores default parser settings
## This only exits to be override by Parsers classes that inherits from it
## In this calls is do nothing
func reset_parser():
	pass

## Func that my parsers uses to replace result in given text with replacement.
func replace_regex_match(text:String, result:RegExMatch, replacement:String) -> String:
	var start_string := text.substr(0, result.get_start())
	var end_string := text.substr(result.get_end(), text.length())
	return start_string + replacement + end_string