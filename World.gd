extends Spatial

var Character = preload("res://Character.tscn")
var Player = preload("res://Player.tscn")

var local_players = []
var controls_to_player = {}
var player_controls = {}

func random_color():
	return Color(rand_range(0.25, 1.0), rand_range(0.25, 1.0), rand_range(0.25, 1.0))

func random_position():
	return Vector3(rand_range(-10, 10.0), 0.0, rand_range(-10, 10.0))

master func add_player(player_name):
	var client_id = get_tree().get_rpc_sender_id()
	var position = random_position()
	var color = random_color()
	rpc("player_added", client_id, player_name, position, color)

remotesync func player_added(client_id, player_name, position, color):
	print("Player added: %s %s" % [client_id, player_name])
	$UI.add_player(client_id, player_name)

	var character = Character.instance()
	character.translation = position
	character.color = color
	character.controlling_peer_id = client_id
	character.name = "%d,%s" % [client_id, player_name]
	add_child(character)

	if client_id == get_tree().get_network_unique_id():
		var controls = player_controls[player_name]
		var player = Player.instance()
		player.controls = controls
		player.name = "%d,%s" % [client_id, player_name]
		$Players.add_child(player)
		player.character = character

		local_players.append(player)
		controls_to_player[controls] = player

		for i in len(local_players):
			local_players[i].anchor_top = 1.0 / len(local_players) * i
			local_players[i].anchor_bottom = 1.0 / len(local_players) * (i + 1)

master func remove_player(player_name):
	var client_id = get_tree().get_rpc_sender_id()
	rpc("player_removed", client_id, player_name)

remotesync func player_removed(client_id, player_name):
	print("Player removed: %s %s" % [client_id, player_name])
	$UI.remove_player(client_id, player_name)

	get_node("%d,%s" % [client_id, player_name]).queue_free()
	var player = $Players.get_node("%d,%s" % [client_id, player_name])
	if player:
		controls_to_player.erase(player.controls)
		player_controls.erase(player_name)
		local_players.erase(player)
		player.queue_free()

		for i in len(local_players):
			local_players[i].anchor_top = 1.0 / len(local_players) * i
			local_players[i].anchor_bottom = 1.0 / len(local_players) * (i + 1)

func _ready():
	randomize()

	get_tree().connect("connected_to_server", self, "_on_connect")
	get_tree().connect("connection_failed", self, "_on_disconnect")
	get_tree().connect("server_disconnected", self, "_on_disconnect")
	get_tree().connect("network_peer_connected", self, "_on_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")

	if true:
		pass
	elif true:
		$UI.hosted_server()
		$UI.add_client(1, null, true)
		$UI.add_client(42, "88.200.50.13", false)
		$UI.add_player(1, "Remi")
		$UI.add_player(1, "Vicky")
		$UI.add_player(42, "Joschi")
		$UI.add_player(42, "Narges")
		$UI.add_client(50, "5.17.85.124", false)
		$UI.add_player(50, "Clement")
	else:
		$UI.connected("88.200.50.13")
		$UI.add_client(1, null, false)
		$UI.add_client(42, "88.200.50.13", true)
		$UI.add_player(1, "Remi")
		$UI.add_player(1, "Vicky")
		$UI.add_player(42, "Joschi")
		$UI.add_player(42, "Narges")
		$UI.add_client(50, "5.17.85.124", false)
		$UI.add_player(50, "Clement")

func _physics_process(_delta):
	if Input.is_action_just_pressed("show_menu"):
		$UI.visible = true

func _on_req_host_server():
	print("req: host server")
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(4148, 16)
	get_tree().network_peer = peer
	$UI.hosted_server()
	$UI.add_client(1, null, true)

func _on_req_connect(address):
	print("req: connect %s" % address)
	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_client(address, 4148)
	if err:
		return
	get_tree().network_peer = peer
	$UI.connected(address)

func _on_req_disconnect():
	print("req: disconnect")
	get_tree().network_peer = null
	$UI.disconnected()

func _on_req_kick_client(client_id):
	print("req: kick client %s" % client_id)
	get_tree().network_peer.disconnect_peer(client_id)

func _on_req_add_player(player_name, controls):
	print("req: add player %s %s" % [player_name, controls])
	if controls_to_player.has(player_name):
		rpc_id(1, "remove_player", player_name)
	player_controls[player_name] = controls
	rpc_id(1, "add_player", player_name)

func _on_req_remove_player(player_name):
	print("req: remove player %s" % player_name)
	rpc_id(1, "remove_player", player_name)

func _on_connect():
	print("Connected to server, we're peer %d" % get_tree().get_network_unique_id())
	var client_id = get_tree().get_network_unique_id()
	$UI.add_client(client_id, null, true)

func _on_disconnect():
	print("Disconnected")
	get_tree().network_peer = null
	$UI.disconnected()
	for player in $Players.get_children():
		player.queue_free()
	local_players = []
	controls_to_player = {}
	player_controls = {}

func _on_peer_connected(client_id):
	print("Peer connected: %s" % client_id)
	var address = "(unknown)"
	if is_network_master():
		address = get_tree().network_peer.get_peer_address(client_id)
	elif client_id == 1:
		address = "(server)"
	$UI.add_client(client_id, address, false)

	if is_network_master():
		for character in get_children():
			var node_name = character.name
			var idx = node_name.find(",")
			if idx == -1:
				continue
			var player_client_id = int(node_name.left(idx))
			var player_name = node_name.right(idx + 1)
			print("Sending player to new peer: %d %s" % [player_client_id, player_name])
			rpc_id(client_id, "player_added", player_client_id, player_name, character.translation, character.color)

func _on_peer_disconnected(client_id):
	print("Peer disconnected: %s" % client_id)
	$UI.remove_client(client_id)

	var prefix = "%d," % client_id
	for player in $Players.get_children():
		if player.name.left(len(prefix)) == prefix:
			print("Removing player from disconnected peer: %s" % player.name)
			player.queue_free()
	for character in get_children():
		if character.name.left(len(prefix)) == prefix:
			print("Removing character from disconnected peer: %s" % character.name)
			character.queue_free()
