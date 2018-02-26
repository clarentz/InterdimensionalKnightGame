extends "res://Character/Enemy/Enemy.gd"

onready var detect_area = get_node("detect_area")

export var MAX_VELOCITY = 800
export var TURN_RATE    = 10

var time = 0

func _ready():
	pass

func die():
	.die()
	var direction = get_pos() - target.get_pos()
	var velocity = direction.normalized() * MAX_VELOCITY/2
	set_linear_velocity(velocity.floor())
	pass