@tool
extends Node

func get_singleton(name: String) -> Object:
	if has_node("/root/%s" % name):
		return get_node("/root/%s" % name)
	return null