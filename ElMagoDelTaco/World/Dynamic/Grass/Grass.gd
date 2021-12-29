extends Node2D

const GrassEffect = preload("res://Effects/GrassEffect.tscn")

func create_grass_effect():
	var grassEffect = GrassEffect.instance()
	
	get_parent().add_child(grassEffect)
	grassEffect.global_position = global_position
	
func _on_Hurtbox_hurtbox_got_hit(_damage):
	create_grass_effect()
	# Hippe di Hoppidi thats no longer my property
	queue_free()
