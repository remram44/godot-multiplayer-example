extends Spatial

export(Color) var color = Color(0.25, 0.25, 1.0) setget _set_color

const GRAVITY = 20.0
const JUMP_SPEED = 6.0
const WALK_RATIO = 0.05
const WALK_SPEED = 5.0

var movement = Vector3()
var jump = false

var speed = Vector3()

func _set_color(new_color):
	color = new_color
	if $Mesh != null:
		var mat = $Mesh.get("material/0").duplicate()
		mat.albedo_color = color
		$Mesh.set("material/0", mat)

func _ready():
	var mat = $Mesh.get("material/0").duplicate()
	mat.albedo_color = color
	$Mesh.set("material/0", mat)

func _physics_process(delta):
	if not get_tree().has_network_peer() or is_network_master():
		movement.x = clamp(movement.x, -1.0, 1.0)
		movement.z = clamp(movement.z, -1.0, 1.0)

		if translation.y <= 0.5 and speed.y < 0.5 * JUMP_SPEED:
			if jump:
				speed.y = JUMP_SPEED
		jump = false

	if translation.y <= 0.5:
		speed.x = lerp(speed.x, movement.x * WALK_SPEED, WALK_RATIO)
		speed.z = lerp(speed.z, movement.z * WALK_SPEED, WALK_RATIO)
	else:
		speed.y -= GRAVITY * delta

	translation += speed * delta
	translation.y = max(0.0, translation.y)

	if get_tree().has_network_peer() and is_network_master():
		rpc("network_update", translation, speed, movement)

puppet func network_update(r_position, r_speed, r_movement):
	translation = r_position
	speed = r_speed
	movement = r_movement
