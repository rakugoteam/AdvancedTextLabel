@tool
extends EditorPlugin

var helper_path := "res://addons/advanced-text/ATHelper.gd"

func _enter_tree():
	add_autoload_singleton("ATHelper", helper_path)

func _exit_tree():
	remove_autoload_singleton("ATHelper")
