extends Node2D

export(PackedScene) var music_Scene:PackedScene
onready var audioStream = $AudioStreamPlayer

func _ready():
	var music_Instance: Node2D = music_Scene.instance()
	add_child(music_Instance)
	music_Instance.play_Audio()
