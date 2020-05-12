extends Node

export(String) var controls = null

var character = null setget _set_character

func _set_character(new_character):
	character = new_character

	character.get_node("Camera").remote_path = character.get_node("Camera").get_path_to($ViewportContainer/Viewport/Camera)

func _ready():
	$ViewportContainer/Viewport.world = get_tree().root.world

func _physics_process(_delta):
	if character != null and controls != null:
		var movement = Vector3()
		movement.x += Input.get_action_strength("%s_right" % controls)
		movement.x -= Input.get_action_strength("%s_left" % controls)
		movement.z += Input.get_action_strength("%s_down" % controls)
		movement.z -= Input.get_action_strength("%s_up" % controls)
		var jump = Input.is_action_just_pressed("%s_jump" % controls)

		if get_tree().has_network_peer():
			# FIXME: Does this work if it's our ID? Does it need '~sync'?
			character.rpc_id(1, "set_input", movement, jump)
		else:
			character.set_input(movement, jump)
