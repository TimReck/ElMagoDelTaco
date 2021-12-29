tool
extends TextureProgress

export(int, 1, 25) var max_hp_value = 1 setget update_max
export(int, 0, 25) var current_hp_value = 1 setget update_current

func update_max(val):
	max_hp_value = val
	
	var width = texture_under.atlas.get_size().x * val
	
	texture_under.region.size.x = width
	texture_progress.region.size.x = width
	
	max_value = max_hp_value
	
	rect_min_size.x = width
	rect_size.x = width
	
	if max_hp_value < current_hp_value:
		update_current(max_hp_value)
		property_list_changed_notify()

func update_current(val):
	current_hp_value = min(val, max_hp_value)
	value = current_hp_value
