extends Resource
class_name StoryBlock

const ENUMS = preload("res://Scripts/Enums.gd")

# NPC Name and the Name of the timeline
export(Dictionary) var dialogs

# NPC Positions
export(Dictionary) var npcsPositions

# Teleporters are ready to use
export(Dictionary) var teleporterUseable

# Conditions that need to be fullfilled to progress to the next Story Block
export(Array, ENUMS.StoryTriggerCondition) var conditions

# Title of the current Story Block
export(String, MULTILINE) var storyTitle
# The description of the Story Block that tells the Player what needs to be done
# to progress to the next Story Block
export(String, MULTILINE) var storyDescription
