@tool
extends EditorPlugin

const SingletonName := "AdvancedText"
const SingletonScript := "res://addons/advanced-text/AdvancedText.gd"

func _enter_tree():
	add_autoload_singleton(SingletonName, SingletonScript)

func _exit_tree():
	remove_autoload_singleton(SingletonName)
