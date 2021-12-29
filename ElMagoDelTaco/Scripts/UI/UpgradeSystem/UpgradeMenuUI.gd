extends NinePatchRect

onready var upgradeVBoxContainer = $UpgradeVBoxContainer


func _input(event):
	if event.is_action_pressed("show_upgrade_menu"):
		switchUpgradeMenuUIVisibility()
		
func switchUpgradeMenuUIVisibility():
	visible = !visible


func setUpgradeInfoUIVisibility(isVisible):
	visible = isVisible

func _on_Button_pressed():
	setUpgradeInfoUIVisibility(false)
	
