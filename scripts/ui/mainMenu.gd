extends Control

@onready var CONTINUE_BTN: Button = $PanelContainer/CenterContainer/VBoxContainer/Continue
@onready var LOAD_BTN: Button = $PanelContainer/CenterContainer/VBoxContainer/LoadGame

const NEW_GAME_START: PackedScene = preload("res://scenes/main.tscn")

func _ready() -> void:
	var HAS_SAVE: bool = SaveLoadGame.has_save()
	if HAS_SAVE:
		CONTINUE_BTN.show()
	else:
		CONTINUE_BTN.hide()
		LOAD_BTN.disabled = true
		
func _on_continue_pressed() -> void:
	SceneManager.SwitchScene("Main")

func _on_new_game_pressed() -> void:
	SceneManager.SwitchScene("Main")

func _on_load_game_pressed() -> void:
	var scene_alias: String = SaveLoadGame.load_game_scene_in_file()
	SceneManager.SwitchScene(scene_alias, true)
	
func _on_settings_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	get_tree().quit()
