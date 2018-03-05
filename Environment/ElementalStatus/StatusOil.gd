extends "res://Environment/ElementalStatus/Status.gd"

func _init(t, dur, lv).(t, dur, lv):
	type = Utils.STATUS.OIL
	tick_time = 1

func combine(status, delta):
	if status.type == Utils.STATUS.OIL:
		#extent duration
		if duration < status.duration:
			duration = status.duration
		return true
		pass
	#no match type
	return false
	pass
#effect happen when the status is added into array or combined 
func start_effect():
	print("Oil! Time: %d Level: %d" % [duration, level])
	pass
#reverse the effect happen at the start
func rev_start_effect():
	print("End Oil")
	anim_status.stop()
	anim_status.play("init")
	pass

#call when timer == tick_time
func tick_effect():
	print("duration: %f" % duration)
	pass