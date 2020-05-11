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
	character.controller = player

	local_players.append(player)
	controls_to_player[controls] = player

	for i in len(local_players):
		local_players[i].anchor_top = 1.0 / len(local_players) * i
		local_players[i].anchor_bottom = 1.0 / len(local_players) * (i + 1)

func _ready():
	randomize()

func _process(_delta):
	for controls in ["key1", "key2"]:
		if Input.is_action_just_pressed("%s_jump" % controls):
			if not controls_to_player.has(controls):
				add_local_player(controls)
