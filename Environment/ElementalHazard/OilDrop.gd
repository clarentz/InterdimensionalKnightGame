extends RigidBody2D

onready var touch_zone = get_node("touch_zone") 

export var duration = 10
var level = 0

var areas

func _ready():
	set_process(true)
	pass
	
func _process(delta):
	areas = touch_zone.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("HURTBOX"):
			area.get_parent().apply_status(Utils.STATUS.OIL, duration, level)
	pass
