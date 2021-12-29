extends VBoxContainer

onready var bossNameLabel = $BossNameLabel
onready var healthProgressBar = $HealthProgressBar

func _ready():
	visible = false

func initializeBossUI(bossHealth :float, bossName :String):
	visible = true
	bossNameLabel.text = bossName
	healthProgressBar.max_value = bossHealth
	healthProgressBar.value = bossHealth
	
func changeValue(newValue :float):
	if newValue <= 0:
		visible = false
		return
		
	healthProgressBar.value = newValue

func resetBar():
	visible = false
	bossNameLabel.text = ""
	

func bossDied():
	visible = false
