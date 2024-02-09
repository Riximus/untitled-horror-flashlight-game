extends Control

const new_game_start: PackedScene = preload("res://scenes/main.tscn")

func _ready() -> void:
	pass
	# TODO: add a check to see if a save exists. If not dont show the "Continue" Button

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_packed(new_game_start)

func _on_load_game_pressed() -> void:
	pass # Replace with function body.

func _on_settings_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	get_tree().quit()
