extends KinematicBody2D

const PlayerHurtSound = preload("res://Sounds/Hurt.wav")
const Projectile = preload("res://Entities/Projectile.tscn")

enum {
	MOVE,
	ROLL
}

signal player_death()

export(Array, PackedScene) var spells
var selectedSpell = 0
onready var spellCount = spells.size()

const MAX_SPEED = 150
const ACCELERATION = 700
const FRICTION = 650
const ROLL_SPEED = 120

var state = MOVE
var velocity = Vector2.ZERO
var current_direction = Vector2.DOWN
var stats = PlayerStats
var canAttack = true

var canMove = false

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var hurtbox = $Hurtbox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer
onready var AttackCooldown = $AttackCooldown

func _ready():
	stats.connect("no_health", self, "death")
	stats.connect("teleporting", self, "teleporting")
	animationTree.active = true
	canMove = true

# Runs every Physics Step
func _physics_process(delta):
	if !canMove:
		return
		
	spell_input()
	move_state(delta)
			
func spell_input():	
	# Loops through all Spells in List
	if(Input.is_action_just_pressed("next_spell")):
		selectedSpell = selectedSpell + 1
		if(selectedSpell > spellCount - 1):
			selectedSpell = 0
			
		PlayerStats.changeSpell(spells[selectedSpell])
		
	if(Input.is_action_just_pressed("previouse_spell")):
		selectedSpell = selectedSpell - 1
		if(selectedSpell < 0):
			selectedSpell = spellCount - 1
			
		PlayerStats.changeSpell(spells[selectedSpell])

func move_state(delta):
	var input_vector = Vector2.ZERO
	
	# Get Input from User 
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# Normalize Vector so diagonal movement is not faster
	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		current_direction = input_vector
		
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		
		animationState.travel("Run")
		
		# Add Acceleration to movement Vectory and cap it to max speed
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		# Add Friction by moving the Vector torowards 0 (= no movement)
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	move()
	
	#if Input.is_action_just_pressed("roll"):
	#	animationState.travel("Roll")
	#	state = ROLL
	
	if Input.is_action_just_pressed("attack") && canAttack:
		castSpell()
		animationState.travel("Attack")

func castSpell():
	var targetAngle = rad2deg(self.get_angle_to(global_position + current_direction))
	shoot(targetAngle, spells[selectedSpell])

func shoot(targetAngle :float, spellProjectile :PackedScene):
	var projectile: Node2D = spellProjectile.instance()
	get_parent().add_child(projectile)

	var spell = projectile.get_node("Spell")
	canAttack = false
	AttackCooldown.start(spell.castingCooldown * PlayerStats.getCurrentCastTimeModifier())
	projectile.init(global_position, targetAngle, spell.speed, spell.damage + PlayerStats.getCurrentDamageModifier())
	
	print("Damage", spell.damage + PlayerStats.getCurrentDamageModifier())

func roll_state(_delta):
	velocity = current_direction * ROLL_SPEED
	move()
	
func move():
	velocity = move_and_slide(velocity)

func attack_animation_finished():
	state = MOVE

func roll_animation_finished():
	state = MOVE

# This function is called when the player gets teleported
# Just restes the current velocity of the player
func teleporting(teleportingStatus :bool, _areaName):
	canMove = !teleportingStatus
	velocity = Vector2.ZERO

func death():
	global_position = Vector2(1248, 480)
	emit_signal("player_death")
	PlayerStats.resetTofullHealth()
	

func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")

func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")

func _on_AttackCooldown_timeout():
	canAttack = true

func _on_Hurtbox_hurtbox_got_hit(damage):
	stats.take_damage(damage)
	hurtbox.start_invincibility(0.5)
	hurtbox.create_hit_effect()

func save():
	var save_dict = {
		"filename" : get_filename(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"coins" : stats.coins,
		"health" : stats.health,
		"healthUpgrade": stats.currentHealthUpgrade,
		"castTimeUpgrade": stats.currentCastTimeUpgrade,
		"damageUpgrade": stats.currentDamageUpgrade
	}
	return save_dict
