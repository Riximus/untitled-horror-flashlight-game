extends Node

# Constants for enabling the system, encryption key, and the save file template.
const ENABLED: bool          =  true
const ENCRYPTION_KEY: String  = EnvSecrets.SAVE_ENCRYPTION_KEY
const SAVE_GAME_PATH: String  = "user://savegame.sav"
const SAVE_GROUP_NAME: String = "Persist"

# Deletes the current save file.
static func delete_save() -> void:
	if not ENABLED:
		return

	if FileAccess.file_exists(SAVE_GAME_PATH):
		DirAccess.remove_absolute(SAVE_GAME_PATH)
	else:
		printerr("Failed to delete save file.")

# Checks if a save file exists.
static func has_save() -> bool:
	print("FileAccess.file_exists(SAVE_GAME_PATH) ", FileAccess.file_exists(SAVE_GAME_PATH))
	return FileAccess.file_exists(SAVE_GAME_PATH)

	# Saves the game state to a binary file.
func save_game(tree: SceneTree) -> void:
	print("----- SAVING GAME -----")
	print("Encryption Key ", ENCRYPTION_KEY)
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

	var save_nodes: Array[Variant] = tree.get_nodes_in_group(SAVE_GROUP_NAME)

	for node in save_nodes:
		if node.has_method("serialize"):
			node.call("serialize", file)
		else:
			printerr("Node does not have a serialize method: ", node)

	file.close()
	print("Game saved successfully.")

# Loads the game state from a binary file.
func load_game(tree: SceneTree) -> void:
	print("------- LOADING GAME -------")
	print("has_save() ", has_save())
	if not ENABLED or not has_save():
		return

	var file = null
	if OS.is_debug_build():
		file = FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
	else:
		file = FileAccess.open_encrypted_with_pass(SAVE_GAME_PATH, FileAccess.READ, ENCRYPTION_KEY)

	if file == null:
		printerr("Failed to open save file for reading.")
		return

	var save_nodes: Array[Variant] = tree.get_nodes_in_group(SAVE_GROUP_NAME)
	var nodes_by_path: Dictionary  = {}

	for node in save_nodes:
		if not node.get_path().is_empty():
			nodes_by_path[node.get_path()] = node

		while file.get_position() < file.get_length():
			if node.has_method("deserialize"):
				node.call("deserialize", file)
			else:
				printerr("Node does not have a deserialize method: ", node)
	file.close()
	print("Game loaded successfully.")

	# Cleanup any nodes that were saved but are no longer present.
	for path in nodes_by_path:
		if not nodes_by_path[path].is_inside_tree():
			nodes_by_path[path].queue_free()

