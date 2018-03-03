extends "res://Character/Character.gd"

onready var target = Utils.get_main_node().get_node("player")

export (int) var ATTACK_DMG     = 0
export (int) var CONTACT_DMG    = 0
export (Vector2) var KNOCKBACK_FORCE = Vector2(0, 0)
export (int) var DETECTION_RANGE   = 1200
export (int) var ATTACK_RANGE   = 200
export (float) var ATTACK_COOLDOWN = 1

# Stats
var status = ""

func _ready():
	anim = flip.get_node("sprite/anim")
	pass