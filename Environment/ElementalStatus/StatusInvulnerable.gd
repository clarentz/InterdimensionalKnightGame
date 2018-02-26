extends "res://Environment/ElementalStatus/Status.gd"

func _init(t, dur, lv).(t, dur, lv):
	type = Utils.STATUS.INVULNERABLE
	tick_time = dur

func combine(status, delta):
	if status.type == Utils.STATUS.INVULNERABLE:
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
	print("Invulnerable")
	target.hurtbox.call_deferred("set_enable_monitoring", false)
	target.hurtbox.call_deferred("set_monitorable", false)
	run_anim()
	pass
#reverse the effect happen at the start
func rev_start_effect():
	print("End Invulnerable")
	target.hurtbox.call_deferred("set_enable_monitoring", true)
	target.hurtbox.call_deferred("set_monitorable", true)
	anim_status.stop()
	anim_status.play("init")
	pass
