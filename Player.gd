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
		character.movement = Vector3()
		character.movement.x += Input.get_action_strength("%s_right" % controls)
		character.movement.x -= Input.get_action_strength("%s_left" % controls)
		character.movement.z += Input.get_action_strength("%s_down" % controls)
		character.movement.z -= Input.get_action_strength("%s_up" % controls)
		character.jump = Input.is_action_just_pressed("%s_jump" % controls)
