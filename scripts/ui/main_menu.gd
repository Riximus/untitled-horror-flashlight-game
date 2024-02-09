extends Control

@onready var CONTINUE_BTN: Button = $PanelContainer/CenterContainer/VBoxContainer/Continue

const NEW_GAME_START: PackedScene = preload("res://scenes/main.tscn")
const SAVE_FILE_PATH: String      = SaveLoadGame.SAVE_GAME_PATH

func _ready() -> void:
	var HAS_SAVE: bool = FileAccess.file_exists(SAVE_FILE_PATH)
	if HAS_SAVE:
		CONTINUE_BTN.show()
	else:
		CONTINUE_BTN.hide()

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_packed(NEW_GAME_START)

func _on_load_game_pressed() -> void:
	pass # Replace with function body.

func _on_settings_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	get_tree().quit()
