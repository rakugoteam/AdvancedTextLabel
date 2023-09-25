@icon("res://addons/advanced-text/icons/CodeEdit.svg")
@tool
extends TextEdit
class_name CodeEditAlt

var EmojisImport
var emojis_gd

var IconsImport
var icons_gd
var code_highlighter := CodeHighlighter.new()

signal update

@export_file var text_file := "": set = _set_text_file
@export var highlight_colors := true
@export var configs : Array[FileHelper]

func _ready() -> void:
	# EmojisImport = preload("../emojis_import.gd")
	# EmojisImport = EmojisImport.new()

	# IconsImport = preload("../material_icons_import.gd")
	# IconsImport = IconsImport.new()

	syntax_highlighter = code_highlighter

	code_highlighter.clear_colors()
	_add_keywords_highlighting()
	connect("update", Callable(self, "_on_update"))
	emit_signal("update")

func _set_text_file(value:String) -> void:
	text_file = value
	emit_signal("update")

func _on_update() -> void:
	if text_file:
		_load_file(text_file)

func _load_file(file_path:String) -> void:
	var f = FileAccess.open(file_path, FileAccess.READ)
	text = f.get_as_text()
	f.close()

func _add_keywords_highlighting() -> void:
	if configs.size() > 0:
		for json in configs:
			load_json_config(json.file)
	
	if highlight_colors:
		_highlight_colors()

func _highlight_colors():
	var colors := { 
		"aqua": Color.AQUA, 
		"black": Color.BLACK,
		"blue": Color.BLUE,
		"fuchsia": Color.FUCHSIA,
		"gray": Color.GRAY,
		"green": Color.GREEN,
		"lime": Color.LIME,
		"maroon": Color.MAROON,
		"navy": Color("#7faeff"),
		"purple": Color.PURPLE,
		"red": Color.RED,
		"silver": Color.SILVER,
		"teal": Color.TEAL,
		"white": Color.WHITE,
		"yellow":	Color.YELLOW
	}

	for c in colors.keys():
		code_highlighter.add_keyword_color(c, colors[c])

func load_json_config(json: String) -> void:
	var content := get_file_content(json)
	var test_json_conv = JSON.new()
	test_json_conv.parse(content)
	var config : Dictionary = test_json_conv.get_data()

	for conf in config:
		read_conf_element(config, conf)

func read_conf_element(config:Dictionary, conf):
	var c = config[conf]
	
	match conf:
		"emojis":
			if EmojisImport.is_plugin_enabled():
				load_emojis_if_exists(read_color(c, "color"))
			else:
				EmojisImport.free()

		"icons":
			if IconsImport.is_plugin_enabled():
				load_icons_if_exists(read_color(c, "color"))
			else:
				IconsImport.free()
				
		"class":
			read_class_conf_if_exist(c)
			
		_:
			if c.has("region"):
				read_region_if_exist(c, read_color(c, "color"))

			if c.has("keywords"):
				read_keywords_if_exist(c, read_color(c, "color"))

func read_color(c:Dictionary, color:String) -> Color:
	return Color(c[color].to_lower())

func load_emojis_if_exists(color: Color) -> void:
	if emojis_gd == null:
		emojis_gd = EmojisImport.get_emojis()

	if emojis_gd:
		for e in emojis_gd.emojis.keys():
			code_highlighter.add_keyword_color(e, color)

func load_icons_if_exists(color: Color) -> void:
	if icons_gd == null:
		icons_gd = IconsImport.get_icons()

	if icons_gd:
		for e in icons_gd.icons.keys():
			code_highlighter.add_keyword_color(e, color)

func read_region_if_exist(c, color:Color): 
	if c.has("region"):
		var r = c["region"]
		code_highlighter.add_color_region(r[0], r[1], color)
	
func read_keywords_if_exist(c, color:Color):
	if c.has("keywords"):
		var keywords = c["keywords"]
		for k in keywords:
			code_highlighter.add_keyword_color(k, color)

func read_class_conf_if_exist(c):
	var class_color := read_color(c, "class_color")
	var variables_color := read_color(c, "variables_color")
	if c.has("load") and c["load"]:
		for _class in ClassDB.get_class_list():
			code_highlighter.add_keyword_color(_class, class_color)
			for m in ClassDB.class_get_property_list(_class):
				for key in m:
					code_highlighter.add_keyword_color(key, variables_color)

	if c.has("custom_classes"):
		for _class in c["custom_classes"]:
			code_highlighter.add_keyword_color(_class, class_color)

func get_file_content(path:String) -> String:
	var file = FileAccess.open(path, FileAccess.READ)
	var content : = ""
	
	if file.get_error() == OK:
		content = file.get_as_text()
		file.close()

	return content
