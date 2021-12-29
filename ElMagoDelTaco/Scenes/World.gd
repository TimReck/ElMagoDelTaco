extends Node2D

var load_saved_game = false
var load_save_game_script = load("res://Scripts/Save_Load_System.gd").new()

func _ready():
	if load_saved_game:
		var save_game = File.new()
		if save_game.file_exists("user://savegame.save"):
			StoryController.init()
			load_save_game_script.loadGame($".", $Camera2D.get_path())		
	else:
		StoryController.init()
		PlayerStats.updateUI()

func _process(delta):
	if Input.is_action_pressed("ingame_menu"):
		get_tree().paused = true;
		$GameUICanvasLayer/GameUI/InGameMenu/Popup.show()
