extends Node2D

export (float) var time :float

func _ready():
	# warning-ignore:return_value_discarded
	get_tree().create_timer(time).connect("timeout", self, "queue_free")
