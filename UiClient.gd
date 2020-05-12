extends Control

signal req_add_player(player_name, controls)
signal req_remove_player(player_name)
signal req_kick_client(client_id)

const COLOR_SELF = Color(2.0, 2.0, 2.0)
const COLOR_OTHER = Color(1.4, 1.4, 1.4)

onready var kick_button = $VBoxContainer/HBoxContainer/Kick
onready var address_label = $VBoxContainer/HBoxContainer/Address
onready var players_list = $VBoxContainer/PanelContainer/VBoxContainer/VBoxContainer
onready var add_button = $VBoxContainer/PanelContainer/VBoxContainer/Add

var UiPlayer = preload("res://UiPlayer.tscn")
var UiAddPlayerPopup = preload("res://UiAddPlayerPopup.tscn")

var client_id
var address
var mode
var is_self
var players = {}

func setup(client_id, address, mode, is_self):
	self.client_id = client_id
	self.address = address
	self.mode = mode
	self.is_self = is_self

func _ready():
	if is_self:
		self.self_modulate = COLOR_SELF
		add_button.visible = true
	else:
		self.self_modulate = COLOR_OTHER
		add_button.visible = false
	kick_button.visible = not is_self and mode == 1
	if address != null:
		address_label.text = address
	else:
		address_label.text = "(local)"

func add_player(player_name):
	var player = UiPlayer.instance()
	players[player_name] = player
	player.player_name = player_name
	player.is_self = is_self
	player.connect("req_remove_player", self, "_on_req_remove_player")
	players_list.add_child(player)
	players[player_name] = player

func remove_player(player_name):
	var player = players[player_name]
	players.erase(player_name)
	player.queue_free()

func _on_add_pressed():
	var popup = UiAddPlayerPopup.instance()
	popup.connect("add_player", self, "_on_add_player")
	get_tree().root.add_child(popup)
	popup.popup_centered_minsize()

func _on_add_player(player_name, controls):
	emit_signal("req_add_player", player_name, controls)

func _on_kick_pressed():
	emit_signal("req_kick_client", client_id)

func _on_req_remove_player(player_name):
	emit_signal("req_remove_player", player_name)
