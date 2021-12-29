extends Node

const ENUMS = preload("res://Scripts/Enums.gd")

export(ENUMS.StoryTriggerCondition) var condition

# Triggers the condition in the StoryController to progress in the Story Block
func trigger():
	# Default Condtion is never triggered
	if condition == 0:
		return
		
	StoryController.conditionFullfilled(condition)
