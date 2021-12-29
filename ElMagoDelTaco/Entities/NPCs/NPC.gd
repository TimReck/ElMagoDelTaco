extends KinematicBody2D

export(String) var npcID : String
export(String) var currentTimeline :String
export(bool) var hasTimeline: bool

# Timer that runs after finishing a dialog so it does not get startet again
# with the finishing ui_accept event
onready var talkCooldownTimer = $TalkCooldownTimer
var talkCooldownTime = 1
var talkCooldownEnded = true

onready var storyTrigger = $StoryTrigger

# Is the Player in Talk Range?
var canTalk = false
# Is the Player currently talking to the NPC
var isTalking = false
# Can the current conversation be repeated?
var isRepeatableDialog = false

func _process(_delta):
	playerTalkToNPC()

func playerTalkToNPC():
	if canTalk and hasTimeline and Input.is_action_just_pressed("ui_accept") and !isTalking and talkCooldownEnded:
		var dialog = Dialogic.start(currentTimeline)
		add_child(dialog)
		dialog.connect("timeline_end", self, "timelineFinished")
		dialog.connect("dialogic_signal", self, "dialogic_signal")
		isTalking = true

# Gets called by the Story Controller to assign a timeline to the NPC
func assignTimeline(timeline :String):
	hasTimeline = true
	currentTimeline = timeline

# Function gets Called when dialogic finish the timeline
func timelineFinished(_timeline_name):
	print("Dialog", currentTimeline, "finished | Repeatable ", isRepeatableDialog)
	isTalking = false
	
	# The Dialog is over and can not be repeated
	if(!isRepeatableDialog):
		hasTimeline = false
		currentTimeline = ""
		
	# Start TalkCoolDownTimer to prevent directly starting the dialog again
	talkCooldownTimer.start(talkCooldownTime)
	talkCooldownEnded = false
	
	# If NPC needs to be talked to, trigger that you have talked with him to
	# progress in the story
	storyTrigger.trigger()

# The dialog system sents a signal
func dialogic_signal(argument):
	if argument == "repeat":
		isRepeatableDialog = true

# Gets called by Story Controller when a story block changes
# So the NPC will lose the outdated timeline still has a timeline
func deleteTimeline():
	hasTimeline = false
	currentTimeline = ""
	isRepeatableDialog = false

# Player entered the area where the npc is talkable
func _on_TalkArea_body_entered(body):
	if body.is_in_group("Player"):
		canTalk = true

# Player left the area where the npc is talkable
func _on_TalkArea_body_exited(body):
	if body.is_in_group("Player"):
		canTalk = false

# The player can talk again to the NPC
func _on_TalkCooldownTimer_timeout():
	talkCooldownEnded = true

func save():
	var dict = {
		"filename" : get_filename(),
		"npcID":npcID,
		"parent" : get_parent().get_path(),
		"currentTimeline":currentTimeline,
		"hasTimeline":hasTimeline,
		"talkCooldownTimer":var2str(talkCooldownTimer),
		"talkCooldownTime":talkCooldownTime,
		"talkCooldownEnded":talkCooldownEnded,
		"storyTrigger":var2str(storyTrigger),
		"canTalk":canTalk,
		"isTalking":isTalking,
		"isRepeatableDialog":isRepeatableDialog,
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
	}
	return dict
