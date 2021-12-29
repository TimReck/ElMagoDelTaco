extends Control

var load_save_game_script = load("res://Scripts/Save_Load_System.gd").new()

func _ready():
	pass # Replace with function body.

func _on_resume_pressed():
	get_tree().paused = false;
	$Popup.hide()

func _on_saveGame_pressed():
	load_save_game_script.saveGame($".")

func _on_toMainMenu_pressed():
	var te = get_tree().change_scene("res://Scenes/MainMenu.tscn")
	get_tree().paused = false
	get_tree().get_root().remove_child(get_node("/root/World"))
