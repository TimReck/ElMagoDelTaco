extends Control

var hearts: float setget set_hearts
var max_hearts :float setget set_max_hearts

onready var heartsTextureProgress = $HeartsTextureProgress
	
func _ready():	
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	
	# warning-ignore:return_value_discarded
	PlayerStats.connect("health_changed", self, "set_hearts")
	# warning-ignore:return_value_discarded
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
	
	#yield(get_tree(), "idle_frame")
	#heartsTextureProgress.max_hp_value = hearts
	#heartsTextureProgress.current_hp_value = hearts
	

func set_hearts(value):
	print("Hearts changed: ", value)
	hearts = clamp(value, 0, max_hearts)
	
	# Use set deferred Otherwise it don't work. Somethings buggy with the TextureProgress
	heartsTextureProgress.set_deferred("current_hp_value", hearts)
	
func set_max_hearts(value):
	print("Max Hearts changed: ", value)
	max_hearts = max(value, 1)
	self.hearts = min(hearts, max_hearts)
	
	heartsTextureProgress.set_deferred("max_hp_value", max_hearts)

