@tool
extends AdvancedTextLabel

func _ready():
	if Engine.is_editor_hint():
		return

	meta_clicked.connect(_on_meta_clicked)
	meta_hover_started.connect(_on_meta_hover_started)
	meta_hover_ended.connect(_on_meta_hover_ended)

func _on_meta_hover_started(meta:String):
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_meta_hover_ended(meta:String):
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_meta_clicked(meta:String):
	if meta.begins_with("http"):
		OS.shell_open(meta)
	
