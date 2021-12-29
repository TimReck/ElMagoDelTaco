extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

var knockback = Vector2.ZERO

onready var stats = $Stats
onready var hurtbox = $Hurtbox
onready var pathfinding = $Pathfinding

var velocity: Vector2 = Vector2.ZERO

func _ready():
	pass

func _physics_process(delta):
	pathfinding.generate_path(global_position)
	pathfinding.navigate(global_position)
	move(pathfinding.vel())

func move(vel):
	velocity = move_and_slide(vel)

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 130
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)

func _on_Stats_no_health():
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	queue_free()
