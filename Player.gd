extends Node

export(String) var controls = null

var movement = Vector3()
var jump = false

func _ready():
	$ViewportContainer/Viewport.world = get_tree().root.world

func _physics_process(_delta):
	movement = Vector3()
	if controls != null:
		movement = Vector3()
		movement.x += Input.get_action_strength("%s_right" % controls)
		movement.x -= Input.get_action_strength("%s_left" % controls)
		movement.z += Input.get_action_strength("%s_down" % controls)
		movement.z -= Input.get_action_strength("%s_up" % controls)
		jump = Input.is_action_just_pressed("%s_jump" % controls)
