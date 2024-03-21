@tool
extends Node

## This is a helper func to get user singletons outside of the main scene tree.
## Used to get: Rakugo, EmojisDB and MaterialIconsDB
func get_singleton(sname: String) -> Object:
	var root := get_tree().root
	
	if Engine.is_editor_hint():
		root = get_tree().edited_scene_root
	
	if root.has_node(sname):
		return root.get_node(sname)
	
	return null