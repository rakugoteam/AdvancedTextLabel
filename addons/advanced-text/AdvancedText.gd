@tool
## This is singleton is used to keep references and common variables
## for AdvancedText in one place and not duplicate them.
## Mainly used to simplify the handling of supported addons/plugins.

extends Node

## Reference to root
## It is setted automaicly
var root : Node:
	get:
		if !root:
			root = get_node("/root/")
		return root

## Reference to Rakugo singleton
## It is setted automaicly
var rakugo: Node:
	get:
		if Engine.is_editor_hint():
			return null
		if !rakugo:
			rakugo = get_singleton("Rakugo")
		return rakugo

## Reference to EmojisDB singleton
## It is setted automaicly
var emojis: Node:
	get:
		if !emojis:
			emojis = get_singleton("EmojisDB")
		return emojis

## Reference to IconsDB singleton
## It is setted automaicly
var icons: Node:
	get:
		if !icons:
			icons = get_singleton("MaterialIconsDB")
		return icons

## Func used get singletons from other addons.
## Build-in Engine.get_singleton() works only for C++ custom modules,
## So we need to make this walkaround.
func get_singleton(singleton: String) -> Node:
	if root.has_node(singleton):
		return root.get_node(singleton)
	return null