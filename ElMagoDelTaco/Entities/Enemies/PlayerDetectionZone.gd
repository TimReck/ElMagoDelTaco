extends Area2D

var player = null 

signal player_detected(player)
signal player_lost()

func _on_PlayerDetectionZone_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("player_detected", body)

func _on_PlayerDetectionZone_body_exited(body):
	if body.is_in_group("Player"):
		emit_signal("player_lost")
