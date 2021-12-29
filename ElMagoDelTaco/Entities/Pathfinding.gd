extends Node2D

onready var debugLine :Line2D = $Line2D

var path: Array = []
var levelNavigation: Navigation2D = null
var player = null

func _ready():
	var tree = get_tree()
	if tree.has_group("LevelNavigation"):
		levelNavigation = tree.get_nodes_in_group("LevelNavigation")[0]
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]

func get_waypoint(currentPos :Vector2):
	if path.size() > 0:
		while (currentPos - path[0]).abs() <= Vector2.ONE * 0.1:
			path.pop_front()
			
			if path.size() == 0:
				return Vector2.ZERO
				
		return path[0]
	else:
		return Vector2.ZERO

func generate_path(currentPos):
	if levelNavigation != null and player != null and is_instance_valid(player):
		path = levelNavigation.get_simple_path(currentPos, player.global_position, true)
		#debugLine.clear_points()
		#for p in path:
		#	p = p - global_position
		#	debugLine.add_point(p)
	else:
		print("No Player or Level Navigation!")
