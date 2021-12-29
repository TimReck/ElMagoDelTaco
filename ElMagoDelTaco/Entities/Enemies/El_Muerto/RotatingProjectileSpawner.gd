extends Node2D

# Timer on when to shoot
onready var shootingDelayTimer = $ShootingDelayTimer
# Holds and rotates the SpawnPoints
onready var rotater = $Rotater

var currentAttackPattern :ProjectileSpawnPattern

func init(attackPattern :ProjectileSpawnPattern) -> void:
	currentAttackPattern = attackPattern
	
	# Delete existing Spawners
	for child in rotater.get_children():
		child.queue_free()
			
	# Calculate and create new spawners
	var step = 2 * PI / currentAttackPattern.projectileSpawnerCount
	
	for i in range(currentAttackPattern.projectileSpawnerCount):
		var spawn_point = Node2D.new()
		var pos = Vector2(currentAttackPattern.radius, 0).rotated(step * i)
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		rotater.add_child(spawn_point)
		
	# Start Shooting Timer
	shootingDelayTimer.wait_time = currentAttackPattern.shootingInterval
	shootingDelayTimer.start()
	
	# Initial Shoot
	call_deferred("shoot")

func _process(delta) -> void:
	if currentAttackPattern == null:
		return
		
	# Update Debug Drawpoints
	# update()
	
	# Rotate the rotater
	var new_rotation = rotater.rotation_degrees + currentAttackPattern.rotaterSpeed * delta
	rotater.rotation_degrees = fmod(new_rotation, 360)
	
func shoot() -> void:
	for s in rotater.get_children():
		var projectileInstance = currentAttackPattern.projectile.instance()
		get_tree().root.add_child(projectileInstance)
		projectileInstance.init(s.global_position, s.global_rotation_degrees , currentAttackPattern.projectileSpeed, currentAttackPattern.projectileDamage)

func stop() -> void:
	shootingDelayTimer.stop()

func _draw():
	pass
	#for p in rotater.get_children():
	#	draw_circle(p.global_position - global_position, 3, Color.greenyellow)

func _on_ShootingDelayTimer_timeout() -> void:
	shoot()
