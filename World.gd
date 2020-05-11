extends Spatial

var Character = preload("res://Character.tscn")
var Player = preload("res://Player.tscn")

func _ready():
	var character1 = Character.instance()
	character1.translation = Vector3(-3.0, 0.0, 0.0)
	character1.color = Color(0.25, 0.25, 1.0)
	add_child(character1)
	var player1 = Player.instance()
	player1.controls = "key1"
	add_child(player1)
	character1.controller = player1
	player1.anchor_top = 0.0
	player1.anchor_bottom = 0.5

	var character2 = Character.instance()
	character2.translation = Vector3(3.0, 0.0, 0.0)
	character1.color = Color(1.0, 0.25, 0.25)
	add_child(character2)
	var player2 = Player.instance()
	player2.controls = "key2"
	add_child(player2)
	character2.controller = player2
	player2.anchor_top = 0.5
	player2.anchor_bottom = 1.0
