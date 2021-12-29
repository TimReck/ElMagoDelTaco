extends Node2D


func play_Audio():
	var audio_Player = $AudioStreamPlayer
	audio_Player.play()
	

func _on_AudioStreamPlayer_finished():
	queue_free()
