@tool
extends TextParserTest

func setup_parser():
	if !parser:
		parser = ExtendedBBCodeParser.new()
		add_child(parser)
	
	parser.reset_parser()

func test_headers():
	setup_parser()
	assert_header("[h1]text[/h1]", "[font_size=22]text[/font_size]")
	assert_header("[h2]text[/h2]", "[font_size=20]text[/font_size]")
	assert_header("[h3]text[/h3]", "[font_size=18]text[/font_size]")
	assert_header("[h4]text[/h4]", "[font_size=16]text[/font_size]")

func test_headers_custom_font():
	setup_parser()
	parser.custom_header_font = load(
		"res://addons/advanced-text/font/DejaVuSans-Oblique.ttf")
	assert_header("[h1]text[/h1]", "[font=res://addons/advanced-text/font/DejaVuSans-Oblique.ttf][font_size=22]text[/font_size][/font]")
	assert_header("[h2]text[/h2]", "[font=res://addons/advanced-text/font/DejaVuSans-Oblique.ttf][font_size=20]text[/font_size][/font]")
	assert_header("[h3]text[/h3]", "[font=res://addons/advanced-text/font/DejaVuSans-Oblique.ttf][font_size=18]text[/font_size][/font]")
	assert_header("[h4]text[/h4]", "[font=res://addons/advanced-text/font/DejaVuSans-Oblique.ttf][font_size=16]text[/font_size][/font]")

func test_headers_custom_sizes():
	setup_parser()
	parser.headers = [32, 30, 28, 26] as Array[int]
	assert_header("[h1]text[/h1]", "[font_size=32]text[/font_size]")
	assert_header("[h2]text[/h2]", "[font_size=30]text[/font_size]")
	assert_header("[h3]text[/h3]", "[font_size=28]text[/font_size]")
	assert_header("[h4]text[/h4]", "[font_size=26]text[/font_size]")
