extends Node

# Constants for enabling the system, encryption key, and the save file template.
const ENABLED: bool          =  true
const ENCRYPTION_KEY: String  = EnvSecrets.SAVE_ENCRYPTION_KEY
const SAVE_GAME_PATH: String  = "user://savegame.sav"
const SAVE_GROUP_NAME: String = "Persist"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("saving"):
		print("Action Pressed Saving")
		SaveLoadGame.save_game(get_tree())
		
	if event.is_action_pressed("loading") and SaveLoadGame.has_save():
		print("Action Pressed Loading")
		SaveLoadGame.load_game(get_tree())

# Deletes the current save file.
func delete_save() -> void:
	if not ENABLED:
		return

	if FileAccess.file_exists(SAVE_GAME_PATH):
		DirAccess.remove_absolute(SAVE_GAME_PATH)
	else:
		printerr("Failed to delete save file.")

# Checks if a save file exists.
func has_save() -> bool:
	print("Does Save File exist? ", FileAccess.file_exists(SAVE_GAME_PATH))
	return FileAccess.file_exists(SAVE_GAME_PATH)

	# Saves the game state to a binary file.
func save_game(tree: SceneTree) -> void:
	print("------- SAVING GAME -------")
	if not ENABLED:
		return

	var file
	print("OS.is_debug_build() ", OS.is_debug_build())
	if OS.is_debug_build():
		file = FileAccess.open(SAVE_GAME_PATH, FileAccess.WRITE)
	else:
		file = FileAccess.open_encrypted_with_pass(SAVE_GAME_PATH, FileAccess.WRITE, ENCRYPTION_KEY)

	if file == null:
		printerr("Failed to open save file for writing.")
		return

	printerr("Save", SceneManager.m_CurrentSceneAlias)
	file.store_pascal_string(SceneManager.m_CurrentSceneAlias)

	var save_nodes: Array[Variant] = tree.get_nodes_in_group(SAVE_GROUP_NAME)

	for node in save_nodes:
		if node.has_method("serialize"):
			node.call("serialize", file)
		else:
			printerr("Node does not have a serialize method: ", node)

	file.close()
	print("------- Game saved successfully -------")

# Loads the game state from a binary file.
func load_game(tree: SceneTree) -> void:
	print("------- LOADING GAME -------")
	if not ENABLED:
		return

	var file = null
	if OS.is_debug_build():
		file = FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
	else:
		file = FileAccess.open_encrypted_with_pass(SAVE_GAME_PATH, FileAccess.READ, ENCRYPTION_KEY)

	if file == null:
		printerr("Failed to open save file for reading.")
		return	
	
	var sceneAlias = file.get_pascal_string()
	printerr("Load", sceneAlias)
	SceneManager.SwitchScene(sceneAlias)

	var save_nodes: Array[Variant] = tree.get_nodes_in_group(SAVE_GROUP_NAME)
	var nodes_by_path: Dictionary = {}

	for node in save_nodes:
		nodes_by_path[node.get_path()] = node
		if node.has_method("deserialize"):
			node.call("deserialize", file)
		else:
			printerr("Node does not have a deserialize method: ", node)

	file.close()
	print("------- Game loaded successfully -------")

	# Cleanup any nodes that were saved but are no longer present.
	for path in nodes_by_path:
		if not nodes_by_path[path].is_inside_tree():
			nodes_by_path[path].queue_free()

