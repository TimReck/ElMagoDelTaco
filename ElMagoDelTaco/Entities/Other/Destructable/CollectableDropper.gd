extends Node2D

export(Array, PackedScene) var drops :Array
export(float, 1, 20) var dropRadius :float

func dropLoot():
	var grandpa = get_parent().get_parent()
	var rng = RandomNumberGenerator.new()
	
	for item in drops:
		# Instance Object and set initial position and parent
		var instancedItem = item.instance()
		grandpa.call_deferred("add_child", instancedItem)
		instancedItem.global_position = global_position
		
		# Tween my smooth Ass with random offset
		var offsetVec = global_position + Vector2(rng.randf_range(-dropRadius, dropRadius), rng.randf_range(-dropRadius, dropRadius))
		
		var tween = Tween.new()
		instancedItem.call_deferred("add_child", tween)
		tween.call_deferred("interpolate_property", instancedItem, "position", global_position, offsetVec, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.call_deferred("start")

