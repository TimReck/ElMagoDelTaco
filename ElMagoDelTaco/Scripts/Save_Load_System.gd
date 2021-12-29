extends Node

var secretKey = "py%@+jgQE!qa!LhvPC3zJX+$X+G+P-z8"

func saveGame(world):
	print(StoryController.getStroyState())
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	var save_nodes = world.get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:

		if node.filename.empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		var node_data = node.call("save")

		save_game.store_line(to_json(node_data))
	
	var save_nodes_npcs = world.get_tree().get_nodes_in_group("NPC")
	for node in save_nodes_npcs:

		if node.filename.empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		var node_data = node.call("save")

		save_game.store_line(to_json(node_data))
	
	save_game.store_line(to_json(StoryController.getStroyState()))
	save_game.close()

func loadGame(world, cameraPath):
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	var save_nodes = world.get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()

	save_game.open("user://savegame.save", File.READ)
	loadPlayer(world, cameraPath, parse_json(save_game.get_line()))
	loadNPC(world, parse_json(save_game.get_line()))
	loadNPC(world, parse_json(save_game.get_line()))
	loadDialog(parse_json(save_game.get_line()))

	save_game.close()

func loadDialog(node_data):
	StoryController.setStroyState(node_data)

func loadNPC(world, node_data):
	var new_object = load(node_data["filename"]).instance()
	world.get_node(node_data["parent"]).add_child(new_object)
	new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
	new_object.npcID = node_data["npcID"]
	new_object.currentTimeline = node_data["currentTimeline"]
	new_object.hasTimeline = node_data["hasTimeline"]
	new_object.talkCooldownTimer = str2var(node_data["talkCooldownTimer"])
	new_object.talkCooldownTime = node_data["talkCooldownTime"]
	new_object.talkCooldownEnded = node_data["talkCooldownEnded"]
	new_object.storyTrigger = str2var(node_data["storyTrigger"])
	new_object.canTalk = node_data["canTalk"]
	new_object.isTalking = node_data["isTalking"]
	new_object.isRepeatableDialog = node_data["isRepeatableDialog"]

func loadPlayer(world, cameraPath, node_data):
	# Firstly, we need to create the object and add it to the tree and set its position.
	var new_object = load(node_data["filename"]).instance()
	world.get_node(node_data["parent"]).add_child(new_object)
	new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
	var remoteTransform2d = RemoteTransform2D.new()
	remoteTransform2d.remote_path = cameraPath
	new_object.add_child(remoteTransform2d)

	PlayerStats.setCoins(node_data["coins"])
	PlayerStats.setHealth(node_data["health"])
	PlayerStats.setCastTimeUpgrade(node_data["castTimeUpgrade"])
	PlayerStats.setDamageUpgrade(node_data["damageUpgrade"])
	PlayerStats.setHealthUpgrade(node_data["healthUpgrade"])
