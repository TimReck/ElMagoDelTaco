extends Node

# Constants
const ENUMS = preload("res://Scripts/Enums.gd")

# Health
export(int) var max_health = 1 setget p_set_max_health
export(int) var health = 1

signal no_health()
signal health_changed(value)
signal max_health_changed(value)

# Coins
var coins = 0
signal coins_changed(value)

# Upgrades
signal advancedUpgrade(type, newValue, maxValue, nextUpgradeCost)

var healthUpgrades = [4, 5, 6, 7, 8]
var healthUpgradeCost = [3, 5, 10, 15, -1]
var currentHealthUpgrade = 0

var castTimeUpgrades = [1.0, 0.6, 0.4, 0.2]
var castTimeUpgradeCost = [1, 3, 5, -1]
var currentCastTimeUpgrade = 0

var damageUpgrades = [0, 1, 2, 3, 4]
var damageUpgradeCost = [4, 10, 15, 20, -1]
var currentDamageUpgrade = 0

func advanceUpgrade(type :int):
	match type:
		ENUMS.UpgradeType.HEALTH:
			if currentHealthUpgrade < healthUpgrades.size() - 1:
				if coins < healthUpgradeCost[currentHealthUpgrade]:
					return
				coins -= healthUpgradeCost[currentHealthUpgrade]
				
				currentHealthUpgrade += 1
				p_set_max_health(healthUpgrades[currentHealthUpgrade])
				emit_signal("advancedUpgrade", type, currentHealthUpgrade, healthUpgrades.size() - 1, healthUpgradeCost[currentHealthUpgrade])
		ENUMS.UpgradeType.CAST_TIME:
			if currentCastTimeUpgrade < castTimeUpgrades.size() - 1:
				if coins < castTimeUpgradeCost[currentCastTimeUpgrade]:
					return
				coins -= castTimeUpgradeCost[currentCastTimeUpgrade]
				
				currentCastTimeUpgrade += 1
				emit_signal("advancedUpgrade", ENUMS.UpgradeType.CAST_TIME, currentCastTimeUpgrade, castTimeUpgrades.size() - 1, castTimeUpgradeCost[currentCastTimeUpgrade])
		ENUMS.UpgradeType.DAMAGE:
			if currentDamageUpgrade < damageUpgrades.size() - 1:
				if coins < damageUpgradeCost[currentDamageUpgrade]:
					return
				coins -= damageUpgradeCost[currentDamageUpgrade]
				
				currentDamageUpgrade += 1
				emit_signal("advancedUpgrade", ENUMS.UpgradeType.DAMAGE, currentDamageUpgrade, damageUpgrades.size() - 1, damageUpgradeCost[currentDamageUpgrade])
	
	# If Upgrade was made, make sure the UI gets notified
	emit_signal("coins_changed", coins)

func setHealthUpgrade(healthUpgrade):
	if healthUpgrade < healthUpgrades.size() - 1:
		currentHealthUpgrade = healthUpgrade
		emit_signal("advancedUpgrade", ENUMS.UpgradeType.HEALTH, currentHealthUpgrade, healthUpgrades.size() - 1, healthUpgradeCost[currentHealthUpgrade])

func setCastTimeUpgrade(castTimeUpgrade):
	if castTimeUpgrade < castTimeUpgrades.size() - 1:
		currentCastTimeUpgrade = castTimeUpgrade
		emit_signal("advancedUpgrade", ENUMS.UpgradeType.CAST_TIME, currentCastTimeUpgrade, castTimeUpgrades.size() - 1, castTimeUpgradeCost[currentCastTimeUpgrade])

func setDamageUpgrade(damageUpgrade):
	if damageUpgrade < damageUpgrades.size() - 1:
		currentDamageUpgrade = damageUpgrade
		emit_signal("advancedUpgrade", ENUMS.UpgradeType.DAMAGE, currentDamageUpgrade, damageUpgrades.size() - 1, damageUpgradeCost[currentDamageUpgrade])

# Teleporting
signal teleporting(teleportingStatus, areaName)

# Spell 
signal spell_changed(spell)


func _ready():
	# Wait One Frame until
	yield(get_tree(), "idle_frame")
	
	# Emit current Upgrades
	emit_signal("advancedUpgrade", ENUMS.UpgradeType.HEALTH, currentHealthUpgrade, healthUpgrades.size() - 1, healthUpgradeCost[currentHealthUpgrade])
	emit_signal("advancedUpgrade", ENUMS.UpgradeType.CAST_TIME, currentCastTimeUpgrade, castTimeUpgrades.size() - 1, castTimeUpgradeCost[currentCastTimeUpgrade])
	emit_signal("advancedUpgrade", ENUMS.UpgradeType.DAMAGE, currentDamageUpgrade, damageUpgrades.size() - 1, damageUpgradeCost[currentDamageUpgrade])

func updateUI():
	# Emit current Upgrades
	emit_signal("advancedUpgrade", ENUMS.UpgradeType.HEALTH, currentHealthUpgrade, healthUpgrades.size() - 1, healthUpgradeCost[currentHealthUpgrade])
	emit_signal("advancedUpgrade", ENUMS.UpgradeType.CAST_TIME, currentCastTimeUpgrade, castTimeUpgrades.size() - 1, castTimeUpgradeCost[currentCastTimeUpgrade])
	emit_signal("advancedUpgrade", ENUMS.UpgradeType.DAMAGE, currentDamageUpgrade, damageUpgrades.size() - 1, damageUpgradeCost[currentDamageUpgrade])

func getCurrentCastTimeModifier():
	return castTimeUpgrades[currentCastTimeUpgrade]
	
func getCurrentDamageModifier():
	return damageUpgrades[currentDamageUpgrade]

# Private Function, used as Getter/Setter
func p_set_max_health(value):
	max_health = value
	health = max(health, max_health)
	
	emit_signal("max_health_changed", max_health)
	emit_signal("health_changed", health)
	
func take_damage(amount):
	health -= abs(amount)
	
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")
		
func heal(amount):
	health += abs(amount)
	health = clamp(health, 1, max_health)
	
	emit_signal("health_changed", health)
	
func changeHealth(amount):
	if amount > 0:
		heal(amount)
	else:
		take_damage(amount)
		
func setHealth(amount):
	health = clamp(amount, 0, max_health)
	emit_signal("health_changed", health)
	
func resetTofullHealth():
	heal(max_health)
	
func addCoins(amount):
	coins += amount
	emit_signal("coins_changed", coins)
	
func setCoins(amount):
	coins = max(amount, 0)
	emit_signal("coins_changed", coins)
	
func teleport(teleportingStatus: bool, areaName :String) -> void:
	emit_signal("teleporting", teleportingStatus, areaName)
	
func changeSpell(spell :PackedScene) -> void:
	emit_signal("spell_changed", spell)









