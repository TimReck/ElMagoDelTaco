extends HBoxContainer

# Constants
const ENUMS = preload("res://Scripts/Enums.gd")

signal doUpgrade(type)
export(ENUMS.UpgradeType) var upgradeType

onready var valueLabel = $ValueLabel
onready var upgradeCostLabel = $CostValueLabel
onready var coinSymbol = $CoinTextureRect

func _ready():
	PlayerStats.connect("advancedUpgrade", self, "advancedUpgrade")
	connect("doUpgrade", PlayerStats, "advanceUpgrade")

func advancedUpgrade(type :int, newValue :int, maxValue :int, newUpgradeCost :int):
	if type == upgradeType:
		valueLabel.text = str(newValue) + "/" + str(maxValue)
		upgradeCostLabel.text = str(newUpgradeCost)
		
		if newUpgradeCost == -1:
			coinSymbol.visible = false
			upgradeCostLabel.visible = false


func _on_UpgradeButton_pressed():
	emit_signal("doUpgrade", upgradeType)

