extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

enum {
	IDLE,
	FIGHTING,
	SEARCHING,
	RETURN_TO_START
}

onready var hitbox = $Hitbox
onready var hurtbox = $Hurtbox
onready var pathfinding = $Pathfinding
onready var playerDetectionZone = $PlayerDetectionZone
onready var attackCooldown = $AttackCooldown
onready var animatedSprite = $AnimatedSprite
onready var stats = $Stats
onready var storyTrigger = $StoryTrigger

export(float) var chaseTime = 1
export(float) var attackCooldownTime = 1
export(float) var attackDamage = 1
export(float) var attackSpeed = 200

export var ACCELERATION = 200
export var MAX_SPEED = 150
export var FRICTION = 100

var movementSpeed = 30
var state = IDLE
var canAttack = true
var levelNavigation: Navigation2D = null
var sight = 200

var starting_position :Vector2
var player
var player_in_range : bool
var player_in_sight : bool
var lastKnownPlayerLocation :Vector2
var pathNeedsRecalculation : bool = true
var currentPath :Array = []

var currState :String
var lastState :String

func _ready():
	hitbox.damage = attackDamage
	var tree = get_tree()
	starting_position = get_global_position()
	if tree.has_group("LevelNavigation"):
		levelNavigation = tree.get_nodes_in_group("LevelNavigation")[0]
		
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]
	

#func _process(delta):
func _process(delta):
	if !is_instance_valid(player):
		getPlayerFromTree()
		
	if !is_instance_valid(player):
		return
		
	if currState != lastState:
		pass
		#print(currState)
	lastState = currState
	
	match state:
		IDLE:
			currState = "IDLE"
			animatedSprite.animation = "Idle"
			# Nothing to do, check if in range collider
			if player_in_range:
				# Is in range, check if also visible to the enemy
				if isPlayerInSight():
					state = FIGHTING
		FIGHTING:
			currState = "FIGHTING"
			lastKnownPlayerLocation = player.global_position
			animatedSprite.animation = "Attack"
			# Check if player is still in range collider
			if !player_in_range:
				# Not anymore since last frame, so set to search and
				# define the current position as the last seen position
				pathNeedsRecalculation = true
				state = SEARCHING
			else:
				if !isPlayerInSight():
					# In Range, but still cant see him, search his last
					# position
					state = SEARCHING
					pathNeedsRecalculation = true
				else:
					# In Range and Can see -> go to him and attack that nobba
					goToPoint(getNavigationPathToPosition(player.global_position, true), delta)
		SEARCHING:
			currState = "SEARCHING"
			if player_in_range:
				# Player is seen, therefore can fight again agsinst him
				if isPlayerInSight():
					state = FIGHTING
				else:
					# Player is in range but not in sight, therefore try to find him
					# if path at the end -> go home
					if pathNeedsRecalculation:
						currentPath = getNavigationPathToPosition(lastKnownPlayerLocation, false)
						pathNeedsRecalculation = false
					
					goToPoint(currentPath, delta)
					if areVectorsApproximatlyEqual(global_position, lastKnownPlayerLocation):
						state = RETURN_TO_START
						pathNeedsRecalculation = true

			else:
				if pathNeedsRecalculation:
					currentPath = getNavigationPathToPosition(lastKnownPlayerLocation, false)
					pathNeedsRecalculation = false
					
				goToPoint(currentPath, delta)
				if areVectorsApproximatlyEqual(global_position, lastKnownPlayerLocation):
					state = RETURN_TO_START
					pathNeedsRecalculation = true
			
		RETURN_TO_START:
			currState = "RETURN_TO_START"
			if player_in_range:
				if isPlayerInSight():
					# On the way back the player appeared again, fight him!
					state = FIGHTING
				else:
					# Go home my friend
					if pathNeedsRecalculation:
						currentPath = getNavigationPathToPosition(starting_position, false)
						pathNeedsRecalculation = false
					
					goToPoint(currentPath, delta)
					if areVectorsApproximatlyEqual(global_position, starting_position):
						state = IDLE
			else:
				# Go home my friend
				if pathNeedsRecalculation:
					currentPath = getNavigationPathToPosition(starting_position, false)
					pathNeedsRecalculation = false
				
				goToPoint(currentPath, delta)
				if areVectorsApproximatlyEqual(global_position, starting_position):
					state = IDLE

func isPlayerInSight():
	if global_position.distance_to(player.global_position) > sight:
		return false	
	
	var space_state = get_world_2d().direct_space_state
	var raycastHit = space_state.intersect_ray(global_position, player.global_position, [self], collision_mask)
	
	if raycastHit:
		if raycastHit.collider.is_in_group("Player"):
			return true
		else:
			return false
			
func getNavigationPathToPosition(destination :Vector2, optimized: bool):
	var path = []
	if !optimized:
		path = levelNavigation.get_simple_path(global_position, destination)
	else:
		path.append(global_position + Vector2(global_position.direction_to(destination).normalized()))
	
	if !path:
		return []
	return path

func goToPoint(path, delta):
	# Debug Path
	#if(path.size() > 0):
	#	pathfinding.get_node("Line2D").clear_points()
	#	for p in path:
	#		p = p - global_position
	#		pathfinding.get_node("Line2D").add_point(p)

	var move_distance = movementSpeed * delta
	var starting_point = global_position
	
	for point in range(path.size()):
		var distance_to_next_point = starting_point.distance_to(path[0])
		if move_distance <= distance_to_next_point:
			var move_rotation = get_angle_to(starting_point.linear_interpolate(path[0], move_distance / distance_to_next_point))
			var motion = Vector2(movementSpeed,0).rotated(move_rotation)
			move_and_slide(motion)
			break
		move_distance -= distance_to_next_point
		starting_point = path[0]	
		path.remove(0)


func areVectorsApproximatlyEqual(vec1 :Vector2, vec2 :Vector2):
	if vec1.distance_to(vec2) <= 5:
		return true
	else:
		return false

func getPlayerFromTree():
	var tree = get_tree()
	
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]

# Chili RIP
func _on_Stats_no_health():
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	
	storyTrigger.trigger()

	queue_free()
	
func _on_PlayerDetectionZone_player_detected(_player):
	player_in_range = true


func _on_PlayerDetectionZone_player_lost():
	player_in_range = false

# Chilli can Attack again
func _on_AttackCooldown_timeout():
	canAttack = true

func _on_Hurtbox_hurtbox_got_hit(damage):
	stats.take_damage(damage)
