extends Control

signal add_player(player_name)

onready var name_textedit = $PanelContainer/VBoxContainer/GridContainer/Name

func _on_click(controls):
	if name_textedit.text:
		emit_signal("add_player", name_textedit.text)
		queue_free()
