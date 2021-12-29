extends StaticBody2D

enum {
	IDLE,
	FIGHTING
}

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")
const CactusProjectile = preload("res://Entities/Enemies/Cactus/CactusProjectile.tscn")

onready var stats = $Stats
onready var chaseTimer = $ChaseTimer
onready var attackCooldown = $AttackCooldown
onready var animatedSprite = $AnimatedSprite

export(float) var chaseTime = 1
export(float) var attackCooldownTime = 1
export(float) var attackDamage = 1
export(float) var attackSpeed = 200

var player :KinematicBody2D = null
var canAttack :bool = true
var state = IDLE

func _process(_delta):
	match state:
		IDLE:
			animatedSprite.animation = "Idle"
		FIGHTING:
			attack()

func attack():
	animatedSprite.animation = "Attack"
	if player == null:
		return
		
	var targetDirection = global_position.direction_to(player.global_position)
	if targetDirection.x > 0:
		animatedSprite.flip_h = true
	else:
		animatedSprite.flip_h = false
	
	if canAttack:
		canAttack = false
		attackCooldown.start(attackCooldownTime)
		var targetAngle = rad2deg(self.get_angle_to(player.global_position))
		var cactusProjectile = CactusProjectile.instance()
		get_parent().add_child(cactusProjectile)
		cactusProjectile.init(global_position, targetAngle, attackSpeed, attackDamage)

func _on_PlayerDetectionZone_player_detected(playerObj):
	state = FIGHTING
	player = playerObj
	chaseTimer.stop()

func _on_PlayerDetectionZone_player_lost():
	player = null
	chaseTimer.start(chaseTime)

# Cactus just died
func _on_Stats_no_health():
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	
	queue_free()

# Player left radius of Cactus
func _on_ChaseTimer_timeout():
	state = IDLE

# Cactus can Attack again
func _on_AttackCooldown_timeout():
	canAttack = true

# Cactus got hit
func _on_Hurtbox_hurtbox_got_hit(damage):
	stats.take_damage(damage)
