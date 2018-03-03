extends "res://Character/Enemy/Enemy.gd"

onready var detect_area = get_node("detect_area")

export var TURN_RATE    = 10

var time = 0

func die():
	.die()
	var direction = get_pos() - target.get_pos()
	var velocity = direction.normalized() * max_run_speed/2
	set_linear_velocity(velocity.floor())
	pass