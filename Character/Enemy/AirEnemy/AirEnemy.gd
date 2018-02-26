extends "res://Character/Enemy/Enemy.gd"

onready var detect_area = get_node("detect_area")

export var MAX_VELOCITY = 800
export var TURN_RATE    = 10

var time = 0

func _ready():
	pass

func die():
	.die()
	set_linear_velocity(Vector2(0,0))
	pass