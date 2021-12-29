extends Node

const ENUMS = preload("res://Scripts/Enums.gd")

# Gets Triggered when the Story progresses to a new Story Block
signal new_story_block(title, description)

# List of all Story Blocks in sequence of progression 
export(Array, Resource) var story :Array
#export(Dictionary) 
# All NPCS in Scene with their according "ID" as Key
# and the actual Node as Value
var npcs :Dictionary

# Current selected Story Block
var currentStoryBlockID = -1
var currentStoryBlock

# Condtions that need to be met to process to next story block
# Are from type ENUM from Enums.StoryTriggerCondition
var currentStoryBlockConditions :Array

func _ready():
	findAndAssignNPCs()
	# Singleton seem to be loaded before anything else and so the first
	# Signal is never sent out because everyone connected to it is loaded
	# after this is finish, therefore delay the script for one frame
	yield(get_tree(), "idle_frame")
	#nextStoryBlock()
	

# Find all NPCS in the Scene and adds them to the dictionary
func findAndAssignNPCs():
	var found_npcs = get_tree().get_nodes_in_group("NPC")
	for npc in found_npcs:
		if npcs.has(npc.npcID):
			print("NPC with ID ", npc.npcID, " already exist with node name ", npc.name)
			continue
		
		npcs[npc.npcID] = npc

# Continue to the next Story Block
func nextStoryBlock():
	# Story finished - Make sure to not try to load more Blocks that dont exist!
	if story.size() - 1 == currentStoryBlockID:
		print("Story finished! End reached")
		return
	
	# Get Next Block
	currentStoryBlockID += 1
	currentStoryBlock = story[currentStoryBlockID]
	
	# Reset all dialogs after completion of Story Block
	# Performance goes BRRRRRR
	for npcKey in npcs:
		npcs[npcKey].deleteTimeline()
	
	# Set the Timelines to the NPCs
	for key in currentStoryBlock.dialogs:
		var value = currentStoryBlock.dialogs[key]
		
		if !npcs.has(key):
			print("NPC ", key, "does not exist!")
			continue
			
		npcs.get(key).assignTimeline(value)
		
		
	# Set Positions of NPCS
	for key in currentStoryBlock.npcsPositions:
		var pos = currentStoryBlock.npcsPositions[key]
		
		if !npcs.has(key):
			print("NPC ", key, "does not exist!")
			continue
			
		npcs.get(key).global_position = pos
		
	# Set teleporter useable
	for key in currentStoryBlock.teleporterUseable:
		var teleporterName = currentStoryBlock.teleporterUseable[key]
		var teleporters = get_tree().get_nodes_in_group("Teleporter")
		for teleporter in teleporters:
			if teleporter.name == teleporterName:
				teleporter.teleportIsUseable = true
		
		
	# Load Conditions
	currentStoryBlockConditions = currentStoryBlock.conditions
		
	# Sent out signal that a new Story Block is set
	print("Reached new Story Block! '", currentStoryBlock.storyTitle, "'")
	emit_signal("new_story_block", currentStoryBlock.storyTitle, currentStoryBlock.storyDescription)

# Fullfill a condition. If it doesnt needed to be fullfilled it just gets ignored
func conditionFullfilled(condition):
	print("Fullfilling condition", condition)
	currentStoryBlockConditions.erase(condition)
	
	# No more condtions - Therefore can progress to next Story Block
	if currentStoryBlockConditions.empty():
		nextStoryBlock()

# Start of block of functions for saving and loading
func init():
	findAndAssignNPCs()
	yield(get_tree(), "idle_frame")
	currentStoryBlockID = -1
	nextStoryBlock()

func getStroyState():
	var dict = {
		"currentStoryBlockID": currentStoryBlockID,
		"currentStoryBlock": currentStoryBlock,
		"currentStoryBlockConditions": currentStoryBlockConditions,
	}
	return dict
	
func setStroyState(dict):
	currentStoryBlockID = dict["currentStoryBlockID"] - 1
	currentStoryBlockConditions = dict["currentStoryBlockConditions"]

# End of block of functions for saving and loading
