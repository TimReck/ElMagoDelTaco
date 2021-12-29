extends Area2D

const HitEffect = preload("res://Effects/HitEffect.tscn")

signal hurtbox_got_hit(damage)

var invincible = false setget set_invincible

export(bool) var createHitEffectOnHit = true

onready var invincibilityTimer = $InvincibilityTimer
onready var collisionShape = $CollisionShape2D

signal invincibility_started
signal invincibility_ended

func set_invincible(value):
	invincible = value
	
	if invincible == true:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")

func start_invincibility(duration):
	self.invincible = true
	invincibilityTimer.start(duration)

func create_hit_effect():
	var effect = HitEffect.instance()
	var parent = get_parent().get_parent()
	parent.add_child(effect)
	effect.global_position = global_position

func _on_Timer_timeout():
	self.invincible = false

func _on_Hurtbox_invincibility_started():
	collisionShape.set_deferred("disabled", true)

func _on_Hurtbox_invincibility_ended():
	collisionShape.disabled = false

func _on_Hurtbox_area_entered(area):
	if "damage" in area:
		if createHitEffectOnHit:
			create_hit_effect()
		emit_signal("hurtbox_got_hit", area.damage)
