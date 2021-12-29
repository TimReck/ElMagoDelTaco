extends Control

func _ready():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		$VBoxContainer/resumeGame.disabled = true

func _on_quitGame_pressed():
	get_tree().quit()

func _on_resumeGame_pressed():
	var next_level_resource = load("res://Scenes/World.tscn");
	var next_level = next_level_resource.instance()
	next_level.load_saved_game = true
	get_tree().root.call_deferred("add_child", next_level)
	queue_free()

func _on_newGame_pressed():
	get_tree().change_scene("res://Scenes/World.tscn")
