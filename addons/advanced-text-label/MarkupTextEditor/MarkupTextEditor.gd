tool
extends Control

var EmojisImport
var emojis_gd

export var markups_options_nodepath : NodePath
onready var markups_options : OptionButton = get_node(markups_options_nodepath)

export var edit_tabs_nodepath : NodePath
onready var edit_tabs : TabContainer = get_node(edit_tabs_nodepath)

export var preview_tabs_nodepath : NodePath
onready var preview_tabs : TabContainer = get_node(preview_tabs_nodepath)

export var preview_toggle_nodepath : NodePath
onready var preview_toggle : CheckButton = get_node(preview_toggle_nodepath)

export var help_button_nodepath : NodePath
onready var help_button : Button = get_node(help_button_nodepath)

export var help_tabs_nodepath : NodePath

onready var help_tabs : TabContainer = get_node(help_tabs_nodepath)
export var help_popup_nodepath : NodePath
onready var help_popup : WindowDialog = get_node(help_popup_nodepath)

export var emoji_button_nodepath : NodePath
onready var emoji_button : Button = get_node(emoji_button_nodepath)

export var selected_node_toggle_nodepath : NodePath
onready var selected_node_toggle : CheckButton = get_node(selected_node_toggle_nodepath)

var markup_id := 0
var text: = ""
var editor : EditorInterface
var selected_node : Node
var markups_str := ["markdown", "renpy", "bbcode"]

func _ready():
	EmojisImport = preload("../emojis_import.gd")
	EmojisImport = EmojisImport.new()

	if EmojisImport.is_emojis_plugin_enabled():
		var emoji_panel : Popup = EmojisImport.get_emoji_panel()
		emoji_panel.visible = false
		add_child(emoji_panel)
		emoji_button.connect("pressed", emoji_panel, "popup_centered", [Vector2(450, 400)])
		emoji_button.icon = EmojisImport.get_icon()

	else:
		emoji_button.hide()

	update_text_preview(get_current_edit_tab())
	markups_options.connect("item_selected", self, "_on_option_selected")
	preview_toggle.connect("toggled", self, "_on_toggle")
	help_button.connect("pressed", self, "_on_help_button_pressed")
	
	for ch in edit_tabs.get_children():
		ch.connect("text_changed", self, "update_text_preview", [ch, true])
		ch.connect("text_changed", self, "_on_text_changed", [ch])

func _on_toggle(toggled: bool):
	preview_tabs.visible = toggled

func get_current_edit_tab() -> TextEdit:
	var e_tabs := edit_tabs.get_children()
	var e_id := edit_tabs.current_tab
	return e_tabs[e_id]

func update_text_preview(caller:MarkupEdit, change_text := true):
	if not caller.visible:
		return
		
	var current_edit_tab := get_current_edit_tab()
	if change_text:
		text = current_edit_tab.text
	else:
		current_edit_tab.text = text

	var l_tabs := preview_tabs.get_children()
	var l_id := preview_tabs.current_tab
	var current_preview_tab = l_tabs[l_id]

	current_preview_tab.markup_text = text

func _on_text_changed(caller:MarkupEdit):
	if !caller.visible:
		return

	if not selected_node_toggle.pressed:
		return

	if !selected_node:
		return

	if selected_node:
		if selected_node is AdvancedTextLabel:
			selected_node.markup_text = caller.text
		
		if selected_node is RichTextLabel:
			if selected_node.bbcode_enabled:
				selected_node.markup_text = caller.text
			else:
				selected_node.text = caller.text
		
		if selected_node is MarkupEdit:
			selected_node.text = caller.text

func _on_option_selected(id: int):
	if id != markup_id:
		_set_markup_id(id)
		var current := get_current_edit_tab()
		update_text_preview(current, text.empty())


func _set_markup_id(id: int):
	if id != markup_id:
		markups_options.selected = id
		edit_tabs.current_tab = id
		preview_tabs.current_tab = id
		help_tabs.current_tab = id
		markup_id = id

		if selected_node:
			if selected_node is AdvancedTextLabel:
				selected_node.markup = markups_str[id]

func _on_help_button_pressed():
	var m = markups_options.get_item_text(markup_id) 
	help_popup.window_title = m + " Help"
	help_popup.popup_centered(Vector2(700, 500))

func _process(delta: float) -> void:
	if not editor:
		return

	if not selected_node_toggle.pressed:
		return

	if visible:
		var _selected_node = editor.get_selection().get_selected_nodes()[0]
		if selected_node != _selected_node:
			selected_node = _selected_node
		else:
			return

		if !selected_node:
			return

		preview_toggle.pressed = true
		preview_tabs.visible = true

		if selected_node is AdvancedTextLabel:
			var _markup_str_id = selected_node.markup
			var _markup_id = markups_str.find(_markup_str_id)
			_set_markup_id(_markup_id)
			markups_options.disabled = false
			
			text = selected_node.markup_text
			update_text_preview(get_current_edit_tab(), false)
			return
		
		if selected_node is RichTextLabel:
			_set_markup_id(2)
			markups_options.disabled = true
			text = selected_node.bbcode_text
			update_text_preview(get_current_edit_tab(), false)
		
		if selected_node is MarkupEdit:
			markups_options.disabled = true
			preview_toggle.pressed = false
			preview_tabs.visible = false
			text = selected_node.text
			update_text_preview(get_current_edit_tab(), false)

