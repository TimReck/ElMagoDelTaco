tool
extends Position2D

onready var teleportCooldownTimer = $TeleportCooldownTimer
onready var teleportPointA = $TeleportPointA
onready var teleportPointB = $TeleportPointB

export(String) var teleportPointAreaNameA = "Teleport Point A"
export(String) var teleportPointAreaNameB = "Teleport Point B"

var teleportIsUseable = false
var canTeleport :bool = true
var teleportTime = 1.5

func _draw() -> void:
	if Engine.is_editor_hint():
		var debugteleportPointA = get_node("TeleportPointA")
		var debugteleportPointB = get_node("TeleportPointB")
		# No Idea why to substract the global position of the object
		draw_line(debugteleportPointA.global_position - global_position, debugteleportPointB.global_position - global_position, Color.greenyellow, 3)

# Check if the given Body is a Player or not
func isPlayer(body) -> bool:
	return body.is_in_group("Player")

func _on_TeleportPointA_body_entered(body):
	if teleportIsUseable == false:
		return
		
	if canTeleport and isPlayer(body):
		PlayerStats.teleport(true, teleportPointAreaNameB)
		
		body.global_position = teleportPointB.global_position
		canTeleport = false
		teleportCooldownTimer.start(teleportTime)
	
func _on_TeleportPointB_body_entered(body):
	if teleportIsUseable == false:
		return
	
	if canTeleport and isPlayer(body):
		PlayerStats.teleport(true, teleportPointAreaNameA)
		
		body.global_position = teleportPointA.global_position
		canTeleport = false
		teleportCooldownTimer.start(teleportTime)

func _on_TeleportCooldownTimer_timeout():
	PlayerStats.teleport(false, "")
	canTeleport = true
