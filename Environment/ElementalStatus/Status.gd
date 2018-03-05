
#var
#the object affected by this status
var target
var anim_status

var duration = 0
var timer = 0
var tick_time = 0
var level = 0

var type

##FUNCREF: to change default function when the character has different reaction to 
var start_effect
var rev_effect
var tick_effect
#function
func _init(t, dur, lv):
	target = t
	duration = dur
	level = lv
	anim_status = target.anim_status
	timer = tick_time
	#assign function
	start_effect = funcref(self, "start_effect")
	rev_effect = funcref(self, "rev_start_effect")
	tick_effect = funcref(self, "tick_effect")
	pass

#combine with other status, return true if can combine, false if not
func combine(status):
	pass

#update call by array each process 
func update(delta):
	duration -= delta
	pass

#effect happen when the status is added into array or combined 
func start_effect():
	pass

#reverse the effect happen at the start
func rev_start_effect():
	pass

#call when timer == tick_time
func tick_effect():
	pass
