extends Node3D

@export var item_resources: Array[ItemResource]

func _enter_tree():
	item_resources[0].item_action = func():
		$"../Head/Hand/PlaceholderItem/SpotLight3D".visible = not $"../Head/Hand/PlaceholderItem/SpotLight3D".visible
