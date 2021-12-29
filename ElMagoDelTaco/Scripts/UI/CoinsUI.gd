extends Control

onready var richTextLabel = $RichTextLabel

func _ready():
	# warning-ignore:return_value_discarded
	PlayerStats.connect("coins_changed", self, "update_coins")
	
func update_coins(value):
	richTextLabel.text = str(value)
