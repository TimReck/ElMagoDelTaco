extends StaticBody2D

export(PackedScene) var effect_Scene:PackedScene
export(PackedScene) var sound_Scene:PackedScene
onready var grandpa = get_parent().get_parent()

func _on_Hurtbox_hurtbox_got_hit(_damage):
	# Add Sound
	if sound_Scene != null:
		var sound_instance: Node2D = sound_Scene.instance()
		grandpa.add_child(sound_instance)
		sound_instance.play_Audio()
	
	# Start Animation
	var animated_Sprite = get_node("AnimatedSprite")
	# Jede Todes-Animation muss "die" heissen
	animated_Sprite.play("die", false)
	

func _on_AnimatedSprite_animation_finished():
	if effect_Scene != null:
		var effect_instance: Node2D = effect_Scene.instance()
		grandpa.add_child(effect_instance)
	
	
		var particle_Node = effect_instance.get_node("Particles2D")
		if particle_Node != null:
			particle_Node.global_position = global_position
			particle_Node.emitting  = true
	
		var collectableDropper = get_node("CollectableDropper")
		if collectableDropper != null:
			collectableDropper.dropLoot()
	
	queue_free()

