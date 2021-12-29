extends Control

# General
onready var audioPlayer = $AudioStreamPlayer

# Story Popup UI
onready var popupFaderTween = $StoryPopupUI/PopupFaderTween
onready var storyPopupUI = $StoryPopupUI
onready var storyPopupBlockTitleLabel = $StoryPopupUI/StoryBlockTitleLabel
onready var storyPopupShowTimer = $StoryPopupUI/StoryPopupShowTimer

var isExitingPopupAnimation = false

# Story Info UI
onready var storyInfoUI = $StoryInfoUI
onready var storyBlockTitleLabel = $StoryInfoUI/Background/VBoxContainer/StoryBlockTitleLabel
onready var storyDescriptionRichTextLabel = $StoryInfoUI/Background/VBoxContainer/HBoxContainer/StoryDescriptionRichTextLabel

func _ready():
	# warning-ignore:return_value_discarded
	StoryController.connect("new_story_block", self, "newStory")
	storyInfoUI.visible = false

func _input(event):
	if event.is_action_pressed("show_story"):
		switchStoryInfoUIVisibility()

func newStory(storyTitle, storyDescription):
	storyBlockTitleLabel.text = storyTitle
	storyDescriptionRichTextLabel.text = storyDescription
	
	showNewStory(storyTitle)

func switchStoryInfoUIVisibility():
	storyInfoUI.visible = !storyInfoUI.visible

func setStoryInfoUIVisibility(isVisible):
	storyInfoUI.visible = isVisible

func showNewStory(storyTitle):
	audioPlayer.play()
	
	# Fade Popup In
	popupFaderTween.interpolate_property(storyPopupUI, "modulate", Color(1,1,1,0), Color(1,1,1,1), 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	popupFaderTween.start()
	
	storyPopupBlockTitleLabel.text = storyTitle
	storyPopupShowTimer.start(4)
	
	storyPopupUI.visible = true

func _on_Button_pressed():
	setStoryInfoUIVisibility(false)

func _on_StoryPopupShowTimer_timeout():
	# Fade Popup Out
	popupFaderTween.interpolate_property(storyPopupUI, "modulate", Color(1,1,1,1), Color(1,1,1,0), 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	popupFaderTween.start()
	isExitingPopupAnimation = true

func _on_PopupFaderTween_tween_all_completed():
	# If is fading out only then set visible to false
	if isExitingPopupAnimation:
		isExitingPopupAnimation = false
		storyPopupUI.visible = false
