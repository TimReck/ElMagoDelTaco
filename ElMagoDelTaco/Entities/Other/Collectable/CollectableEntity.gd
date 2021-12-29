extends Node2D

signal entity_collected

onready var storyTrigger = $StoryTrigger

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("entity_collected")
		storyTrigger.trigger()
		
		queue_free()
