extends Control

onready var teleportingTexture = $TeleportingTexture
onready var faderTween = $FaderTween
onready var teleportAnimationTimer = $TeleportAnimationTimer

var teleportAnimationTime :float = 1.5
var isPlayingClosingAnimation = false

func _ready():
	yield(get_tree(), "idle_frame")
	# warning-ignore:return_value_discarded
	PlayerStats.connect("teleporting", self, "teleportAnimation")
	
	teleportingTexture.texture.pause = true
	visible = false
	isPlayingClosingAnimation = false
	
func teleportAnimation(teleportingStatus :bool, _areaName :String) -> void:
	if !teleportingStatus:
		return
		
	visible = true
	
	faderTween.interpolate_property(teleportingTexture, "modulate", Color(1,1,1,0), Color(1,1,1,1), .125, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	faderTween.start()
	
	isPlayingClosingAnimation = false 
	
	teleportingTexture.texture.pause = false
	teleportAnimationTimer.start(teleportAnimationTime)

func _on_TeleportAnimationTimer_timeout():	
	faderTween.stop_all()
	faderTween.interpolate_property(teleportingTexture, "modulate", Color(1,1,1,1), Color(1,1,1,0), .5, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	faderTween.start()
	
	isPlayingClosingAnimation = true

func _on_FaderTween_tween_all_completed():
	if isPlayingClosingAnimation:
		isPlayingClosingAnimation = false
		visible = false
		teleportingTexture.texture.pause = true
