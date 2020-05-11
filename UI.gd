extends Control

signal req_connect(address)
signal req_host_server()
signal req_disconnect()
signal req_add_player(player_name)
signal req_remove_player(player_name)
signal req_kick_client(client_id)
signal req_start()

onready var host_button = $VBoxContainer/Grid/ServerButton
onready var connect_button = $VBoxContainer/Grid/HBoxContainer/ConnectButton
onready var address_textbox = $VBoxContainer/Grid/HBoxContainer/AddressInput
onready var clients_list = $VBoxContainer/Clients
onready var not_connected_label = $VBoxContainer/NotConnected
onready var start_control = $VBoxContainer/StartControl

var UiClient = preload("res://UiClient.tscn")

var clients = {}
var mode = 0  # 1: server, 2: client

func hosted_server():
	_reset()
	mode = 1
	host_button.text = "Shutdown server"
	connect_button.disabled = true
	address_textbox.readonly = true
	not_connected_label.visible = false
	start_control.visible = true

func connected(address):
	_reset()
	mode = 2
	host_button.disabled = true
	connect_button.text = "Disconnect"
	address_textbox.readonly = true
	address_textbox.text = address
	not_connected_label.visible = false

func disconnected():
	_reset()
	mode = 0

func _reset():
	mode = 0
	host_button.text = "Host server"
	host_button.disabled = false
	address_textbox.readonly = false
	connect_button.text = "Connect"
	connect_button.disabled = false
	not_connected_label.visible = true
	start_control.visible = false
	clients = {}
	for child in clients_list.get_children():
		child.queue_free()

func add_client(client_id, address, is_self):
	var client = UiClient.instance()
	client.setup(client_id, address, mode, is_self)
	clients[client_id] = client
	clients_list.add_child(client)
	client.connect("req_add_player", self, "_on_req_add_player")
	client.connect("req_remove_player", self, "_on_req_remove_player")
	client.connect("req_kick_client", self, "_on_req_kick_client")

func remove_client(client_id):
	var client = clients[client_id]
	clients.erase(client_id)
	client.queue_free()

func add_player(client_id, player_name):
	var client = clients[client_id]
	client.add_player(player_name)

func remove_player(client_id, player_name):
	var client = clients[client_id]
	client.remove_player(player_name)

func _on_req_add_player(player_name):
	emit_signal("req_add_player", player_name)

func _on_req_remove_player(player_name):
	emit_signal("req_remove_player", player_name)

func _on_req_kick_client(client_id):
	emit_signal("req_kick_client", client_id)

func _on_host_pressed():
	if mode == 1:
		emit_signal("req_disconnect")
	else:
		emit_signal("req_host_server")

func _on_connect_pressed():
	if mode == 2:
		emit_signal("req_disconnect")
	else:
		emit_signal("req_connect", address_textbox.text)

func _on_start_pressed():
	emit_signal("req_start")
