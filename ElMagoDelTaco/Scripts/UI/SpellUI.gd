extends Control

onready var spellRect :TextureRect = $Panel/TextureRect

func _ready():
	PlayerStats.connect("spell_changed", self, "changeSpell")

func setSpellIcon(spellIcon :Texture):
	spellRect.texture = spellIcon

func changeSpell(spell):
	# Load Scene to get the Icon, big uff, but works
	var spellScene: Node2D = spell.instance()
	setSpellIcon(spellScene.get_node("Spell").spellIcon)
	spellScene.queue_free()
