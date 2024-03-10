extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var player: CharacterBody3D = $"../../Player"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		pass
		#var random_position: Vector3 = Vector3.ZERO
		#random_position.x = randf_range(-5.0, 5.0)
		#random_position.z = randf_range(-5.0, 5.0)
		#navigation_agent_3d.set_target_position(player.position)

func _physics_process(_delta: float) -> void:
	
	navigation_agent_3d.target_position = player.position
	
	var destination = navigation_agent_3d.get_next_path_position()
	var local_destination = destination - global_position
	var direction = local_destination.normalized()
	
	velocity = direction * 5.0
	move_and_slide()

func serialize(file: FileAccess) -> void:
	print('Monster Serialize')
	file.store_float(global_position.x)
	file.store_float(global_position.y)
	file.store_float(global_position.z)

func deserialize(file: FileAccess) -> void:
	print('Monster Deserialize')
	global_position.x = file.get_float()
	global_position.y = file.get_float()
	global_position.z = file.get_float()
