extends KinematicBody2D

onready var projectileHitbox = $ProjectileHitbox

var movementSpeed = 10

func _process(delta):
	# Checks for Collision with the Enviorment + transform.x is forward Vector
	var collision = move_and_collide(transform.x * movementSpeed * delta)
	if collision:
		queue_free()

# Initializes the Projectile
func init(origin :Vector2, rotation :float, speed :int, damage :int) -> void:
	global_position = origin
	global_rotation_degrees = rotation
	movementSpeed = speed
	
	projectileHitbox.damage = damage

# Deletes Projectile after certain amount of time for perfomance Reason
func _on_DestroyTimer_timeout():
	queue_free()

# Delete Projectile after hit with hurtbox
func _on_ProjectileHitbox_interactableObjectHit():
	queue_free()
