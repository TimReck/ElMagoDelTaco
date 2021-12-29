extends Area2D

export var damage = 1
signal interactableObjectHit

func _on_Hitbox_area_entered(_area):
	emit_signal("interactableObjectHit")
