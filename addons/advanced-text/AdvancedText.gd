@tool
## This is singleton is used to keep references and common variables
## for AdvancedText in one place and not duplicate them.
## Mainly used to simplify the handling of supported addons/plugins.
## @tutorial: https://rakugoteam.github.io/advanced-text-docs/2.0/AdvancedText/
extends Node

## Reference to root
## Its a getter that returns [code]get_node("/root/")[/code]
var root : Node:
	get:
		if !root:
			root = get_node("/root")
		return root

## Reference to Rakugo singleton
## Its a getter that returns Rakugo singelton if it exist
var rakugo: Node:
	get:
		if Engine.is_editor_hint():
			return null
		if !rakugo:
			rakugo = get_singleton("Rakugo")
		return rakugo

## Reference to EmojisDB singleton
## Its a getter that returns EmojisDB singelton if it exist
var emojis: Node:
	get:
		if !emojis:
			emojis = get_singleton("EmojisDB")
		return emojis

## Reference to IconsDB singleton
## Its a getter that returns MaterialIconsDB singelton if it exist
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