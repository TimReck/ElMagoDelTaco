extends KinematicBody2D

# States
enum {
	IDLE,
	ATTACK_PATTERN_NORMAL,
	ATTACK_PATTERN_FAST,
	ATTACK_PLAYER_CLOSE,
	ATTACK_EL_MUERTO_EL_FINAL
}

# Constants
const ATTACK_PATTERNS = {
	1 : preload("res://Entities/Enemies/El_Muerto/Attack_Pattern_Normal.tres"),
	2 : preload("res://Entities/Enemies/El_Muerto/Attack_Pattern_Fast.tres"),
	3 : preload("res://Entities/Enemies/El_Muerto/Attack_Pattern_Player_Close.tres"),
	4 : preload("res://Entities/Enemies/El_Muerto/Attack_Pattern_EL_MUERTO_El_Final.tres")
}

# Export Variables
export(NodePath) var bossHealthBarUINode :NodePath

# Variables
onready var rotatingProjectileSpawner = $RotatingProjectileSpawner
onready var stats = $Stats
onready var phaseSwitcherTimer = $PhaseSwitcherTimer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var storyTrigger = $StoryTrigger
onready var collectableDropper = $CollectableDropper

var bossHealthBarUI
var player :KinematicBody2D
var state
var spawnPoint :Vector2

# Phases
var currentAttackPattern :ProjectileSpawnPattern
var nextState : int
var phaseSwitchTiming :float = 5
var switchPhase = false

var playerCloseRadius = 80

# Movement
var velocity :Vector2
var maxSpeed :float = 25
var acceleration :float = 15

func _ready() -> void:
	player = null
	state = IDLE
	currentAttackPattern = null
	animationTree.active = true
	animationState.start("Idle")
	bossHealthBarUI = get_node(bossHealthBarUINode)
	spawnPoint = global_position
	

func _process(delta) -> void:
	# El Muerto is dying wait for distruction
	if state == ATTACK_EL_MUERTO_EL_FINAL:
		return
	
	# If player is dead or delete just don't do anything
	if !is_instance_valid(player):
		rotatingProjectileSpawner.stop()
		phaseSwitcherTimer.stop()
		animationState.travel("Idle")
		return
	
	# Set Animation Blender
	var directionToPlayer = global_position.direction_to(player.global_position)
	animationTree.set("parameters/Attack/blend_position", directionToPlayer)
	animationTree.set("parameters/Walk/blend_position", directionToPlayer)
	
	var distanceToPlayer = global_position.distance_to(player.global_position)
	if distanceToPlayer <= playerCloseRadius and state != ATTACK_PLAYER_CLOSE:
		switchState(ATTACK_PLAYER_CLOSE)
		phaseSwitcherTimer.stop()
	else:
		if distanceToPlayer > playerCloseRadius and state == ATTACK_PLAYER_CLOSE:
			switchState(ATTACK_PATTERN_NORMAL)
		
	
	match state:
		# Move to Player and Shoot
		ATTACK_PATTERN_NORMAL:
			moveToPlayer(delta, directionToPlayer)
						
			nextState = ATTACK_PATTERN_FAST
		
		# Stay still and make spread pattern
		ATTACK_PATTERN_FAST:
			# Bring him to a stop
			velocity = velocity.move_toward(Vector2.ZERO, delta)
			animationState.travel("Attack")
			nextState = ATTACK_PATTERN_NORMAL
			
		ATTACK_PLAYER_CLOSE:
			# Walk away from player 8x as fast
			moveToPlayer(delta, -directionToPlayer * 8)
			

func moveToPlayer(delta :float, directionToPlayer:Vector2) -> void:	
	animationState.travel("Walk")

	velocity = velocity.move_toward(directionToPlayer * maxSpeed, acceleration * delta)
	velocity = move_and_slide(velocity)


func switchState(newState :int):
	state = newState
	rotatingProjectileSpawner.init(ATTACK_PATTERNS[state])
	phaseSwitcherTimer.start(phaseSwitchTiming)

# Player is deteced - Fight begins - Only ends with DEATH
func _on_PlayerDetectionZone_player_detected(playerObj):
	if state != IDLE:
		return
		
	print("Starting El Muerto Fight")
	player = playerObj
	player.connect("player_death", self, "playerDied")
	switchState(ATTACK_PATTERN_NORMAL)
	
	# Connect to Boss Health Bar
	if is_instance_valid(bossHealthBarUI):
		bossHealthBarUI.initializeBossUI(stats.health, "El Muerto")
		stats.connect("no_health", bossHealthBarUI, "bossDied")
		stats.connect("health_changed", bossHealthBarUI, "changeValue")
		

func die():
	print("El Muerto Dead")
	switchState(ATTACK_EL_MUERTO_EL_FINAL)
	animationState.travel("Die")
	
	storyTrigger.trigger()
	collectableDropper.dropLoot()
	
	# warning-ignore:return_value_discarded
	get_tree().create_timer(5).connect("timeout", self, "queue_free")

func playerDied():
	# If is dying the same moment than player, do not change
	if state == ATTACK_EL_MUERTO_EL_FINAL:
		return
		
	# Reset the Boss
	global_position = spawnPoint
	stats.resetTofullHealth()
	state = IDLE
	animationState.travel("Idle")
	currentAttackPattern = null
	rotatingProjectileSpawner.stop()
	phaseSwitcherTimer.stop()
	player = null
	
	# Reset the UI	
	bossHealthBarUI.resetBar()
	
	
# Death
func _on_Stats_no_health():
	die()

func _on_PhaseSwitcherTimer_timeout():
	switchState(nextState)

func _on_Hurtbox_hurtbox_got_hit(damage):
	stats.take_damage(damage)
