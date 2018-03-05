extends "res://Environment/ElementalStatus/Status.gd"

func _init(t, dur, lv).(t, dur, lv):
	type = Utils.STATUS.OIL
	tick_time = 1

func combine(status, delta):
	if status.type == Utils.STATUS.OIL:
		#extent duration
		if duration < status.duration:
			duration = status.duration
		return self
	elif status.type == Utils.STATUS.FIRE:
		status.duration = (duration*level + status.duration*status.level)/(level+status.level)
		if status.level <= level:
			status.level = level + 1
		rev_start_effect()
		status.start_effect()
		return status
	#no match type
	return false
	pass
#update
func update(delta):
	.update(delta)
	timer += delta
	if timer >= tick_time:
		tick_effect.call_func()
		timer = 0
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