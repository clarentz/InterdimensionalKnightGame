extends Node

var body
var target_position
var position
var velocity
var desired_velocity
var steering
var target

func _init(body):
	self.body = body
	pass

func steer(target):
	target_position  = target.get_global_pos()
	position         = body.get_global_pos()
	velocity         = body.get_linear_velocity()
	desired_velocity = Vector2(target_position - position).normalized() * body.max_run_speed
	steering         = desired_velocity - velocity
	steering         = steering.clamped(body.TURN_RATE)
	velocity         = velocity + steering
	body.set_linear_velocity(velocity)
	pass
