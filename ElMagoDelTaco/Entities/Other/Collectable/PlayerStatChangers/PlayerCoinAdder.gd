extends Node

export(int) var amount :int = 1

func _ready():
	# warning-ignore:return_value_discarded
	get_parent().connect("entity_collected", self, "addPlayerCoin")

func addPlayerCoin():
	PlayerStats.addCoins(amount)
