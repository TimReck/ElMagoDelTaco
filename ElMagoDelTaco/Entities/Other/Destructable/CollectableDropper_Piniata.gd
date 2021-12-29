extends Node2D

export(Array, PackedScene) var drops :Array

func dropLoot():
	var grandpa = get_parent().get_parent()
	for item in drops:
		var instancedItem = item.instance()
		grandpa.call_deferred("add_child", instancedItem)
		instancedItem.global_position = global_position
		
	
