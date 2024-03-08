extends StaticBody3D

@export var key: Item = null
var opening_speed: float = 5.0

func open(delta):
	while rotation_degrees.y != 90.0:
		rotation_degrees.y = lerp(rotation_degrees.y, 90.0, opening_speed * delta)
		rotation_degrees.y = clamp(rotation_degrees.y, 0.0, 90.0)
		await get_tree().create_timer(delta).timeout
