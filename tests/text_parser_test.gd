@tool
extends GutTest
class_name TextParserTest

var parser : TextParser

func setup_parser():
	if !parser:
		parser = TextParser.new()
		add_child(parser)

func assert_header(test_string:String, expected:String, text:=""):
	var result : String = parser.parse_headers(test_string)
	assert_eq(result, expected, text)

func assert_emojis(test_string:String, expected:String, text:=""):
	var result : String = parser.parse_emojis(test_string)
	assert_eq(result, expected, text)

func assetr_icons(test_string:String, expected:String, text:=""):
	var result : String = parser.parse_headers(test_string)
	assert_eq(result, expected, text)

