extends Spatial

var Character = preload("res://Character.tscn")
var Player = preload("res://Player.tscn")

var local_players = []
var controls_to_player = {}

func random_color():
	return Color(rand_range(0.25, 1.0), rand_range(0.25, 1.0), rand_range(0.25, 1.0))

func random_position():
	return Vector3(rand_range(-10, 10.0), 0.0, rand_range(-10, 10.0))

func add_local_player(controls):
	var character = Character.instance()
	character.translation = random_position()
	character.color = random_color()
	add_child(character)
	var player = Player.instance()
	player.controls = controls
	add_child(player)
	player.character = character

	local_players.append(player)
	controls_to_player[controls] = player

	for i in len(local_players):
		local_players[i].anchor_top = 1.0 / len(local_players) * i
		local_players[i].anchor_bottom = 1.0 / len(local_players) * (i + 1)

func _ready():
	randomize()

	if true:
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

func _process(_delta):
	for controls in ["key1", "key2"]:
		if Input.is_action_just_pressed("%s_jump" % controls):
			if not controls_to_player.has(controls):
				add_local_player(controls)

func _on_req_host_server():
	print("req: host server")

func _on_req_connect(address):
	print("req: connect %s" % address)

func _on_req_disconnect():
	print("req: disconnect")

func _on_req_kick_client(client_id):
	print("req: kick client %s" % client_id)

func _on_req_add_player(player_name):
	print("req: add player %s" % player_name)

func _on_req_remove_player(player_name):
	print("req: remove player %s" % player_name)
