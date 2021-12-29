extends StaticBody2D

export(PackedScene) var effect_Scene:PackedScene


func _on_Hurtbox_hurtbox_got_hit(damage):
	var animated_Sprite = get_node("AnimatedSprite")
	animated_Sprite.play("die", false)
	
	



func _on_AnimatedSprite_animation_finished():
	var grandpa = get_parent().get_parent()
	var effect_instance: Node2D = effect_Scene.instance()
	#grandpa.call_deferred("add_child", effect_instance)
	grandpa.add_child(effect_instance)
	var particle_Node = effect_instance.get_node("Particles2D")
	particle_Node.global_position = global_position
	particle_Node.emitting  = true
	
	var collectableDropper = get_node("CollectableDropper")
	collectableDropper.dropLoot()
	queue_free()
