extends Node3D

@export var item_resources: Array[ItemResource]

func get_item_res(search_name: String):
	for i in item_resources:
		if i.item_name == search_name:
			return i

func _enter_tree():
	get_item_res("flashlight").item_action = func():
		$"../Head/Hand/PlaceholderItem/SpotLight3D".visible = not $"../Head/Hand/PlaceholderItem/SpotLight3D".visible
