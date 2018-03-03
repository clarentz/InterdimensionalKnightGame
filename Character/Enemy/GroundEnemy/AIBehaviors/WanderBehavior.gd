# private var
var body
var is_moving
var target    # fake target to follow
var target_dir
var time
var walk_time
var idle_time

func _init(body):
	self.body = body
	init_variable()
	pass

func init_variable():
	target_dir = body.direction
	set_target()
	time = 0
	walk_time = 0
	idle_time = 0
	pass

## BEHAVIOR SCRIPT
# PATROLING
func wander():
	if body.ground_check():
		# Check for platform edges
		if body.direction > 0 and not body.bound_dt_1.is_colliding():
			target_dir = -body.direction
		elif body.direction < 0 and not body.bound_dt_2.is_colliding():
			target_dir = -body.direction
		
		# Check for vertical walls
		if body.wall_dt.is_colliding():
			var normal = body.wall_dt.get_collision_normal()
			if sign(normal.x * body.direction) < 0:
				target_dir = -body.direction
	
	random_steps()
	set_target()
	body.direction = target_dir
	pass

func random_steps():
	time = time + Utils.fixed_delta
	
	if time >= walk_time + idle_time:
		randomize()
		walk_time = rand_range(body.WALK_TIME.x, body.WALK_TIME.y)
		idle_time = rand_range(body.IDLE_TIME.x, body.IDLE_TIME.y)
		
		if round(randf()):
			target_dir = 1
		else:
			target_dir = -1
		
		time = 0
	elif time < walk_time:
		body.move(target, body.max_run_speed)
		is_moving = true
	else:
		is_moving = false
		
	pass

func set_target():
	target = body.get_pos() + Vector2(100, 0) * target_dir
	pass

func is_wandering():
	return is_moving
	pass

func exit():
	
	pass