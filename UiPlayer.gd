extends Control

signal req_remove_player(player_name)

export(String) var player_name
export(bool) var is_self = false

onready var name_label = $Name
onready var remove_button = $RemoveButton

func _ready():
	name_label.text = player_name
	remove_button.visible = is_self

func _on_remove_pressed():
	emit_signal("req_remove_player", player_name)
