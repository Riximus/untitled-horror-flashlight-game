extends RigidBody3D

class_name Item

func serialize(file: FileAccess) -> void:
	print('Item Serialize')
	file.store_float(global_position.x)
	file.store_float(global_position.y)
	file.store_float(global_position.z)

func deserialize(file: FileAccess) -> void:
	print('Item Deserialize')
	global_position.x = file.get_float()
	global_position.y = file.get_float()
	global_position.z = file.get_float()
