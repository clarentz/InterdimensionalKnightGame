var body
var body_position
var target_position
var traces
var trace_range

func _init(body):
	self.body = body
	init_variable()
	pass

func init_variable():
	body_position   = body.get_pos()
	target_position = body.target.get_pos()
	trace_range = round(body.PURSUIT_RANGE/body.TRACE_AMOUNT)
	traces = Array()
	pass

func pursuit():
	body_position   = body.get_pos().floor()
	target_position = body.target.get_pos().floor()
	set_trace()
	
	if body.ground_check():
		move_to_next_trace()
		if body.get_linear_velocity().x != 0:
			body.direction = sign(body.get_linear_velocity().x)
	pass

func set_trace():
	if traces.empty():
		traces.append(body_position)
	
	# Make a trace every "trace_range" distance
	if traces.back().distance_to(target_position) >= trace_range:
		traces.append(target_position)
	
	# To avoid making too many traces
	if traces.size() > round(body.PURSUIT_RANGE/trace_range):
		traces.pop_front()
	
	pass

func move_to_next_trace():
	if body_position.distance_to(target_position) <= trace_range:
		body.move(target_position, body.PURSUIT_VELOCITY)
	else:
		body.move(traces.front(), body.PURSUIT_VELOCITY)
		
	# Detect when to jump
	if body_position.y > traces.front().y + 50:
		if body.target.ground_check() and body.JUMPABLE:
			jump()
		else:
			# won't jump if BODY and TARGET is on the same ground
			traces.pop_front()
	# Remove the trace when BODY gets close to it
	elif body_position.distance_to(traces.front()) <= trace_range:
		traces.pop_front()
	elif body_position.y <= traces.front().y:
		var dir = sign(target_position.x - body_position.x)
		if dir == 0:
			dir = -1
		body.move(body.get_pos() + Vector2(200,0) * dir, body.PURSUIT_VELOCITY)
	pass

func jump():
	if body.ground_check():
		body.set_axis_velocity(Vector2(0, -body.JUMP_FORCE))
	pass

func exit():
	traces.clear()
	pass