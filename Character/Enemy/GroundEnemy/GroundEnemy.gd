extends "res://Character/Enemy/Enemy.gd"

# onready var
onready var ground_dt    = get_node("ground_detector")
onready var bound_dt_1   = get_node("bound_detector_1")
onready var bound_dt_2   = get_node("bound_detector_2")
onready var wall_dt      = flip.get_node("wall_detector")
onready var player_dt    = flip.get_node("player_detector")
onready var attack_dt    = flip.get_node("attack/att_detector")

# Character
# export var
export (bool) var JUMPABLE      = false
export (int) var JUMP_FORCE     = 1200
export (int) var PURSUIT_VELOCITY = 300
export (int) var PURSUIT_RANGE  = 1200
export (Vector2) var WALK_TIME  = Vector2(1, 6)
export (Vector2) var IDLE_TIME  = Vector2(1, 3)
export (int) var TRACE_AMOUNT   = 10

# private var
var user = self
var attack_time

func _ready():
	set_process(true)
	ground_dt.add_exception(self)
	wall_dt.add_exception(self)
	bound_dt_1.add_exception(self)
	bound_dt_2.add_exception(self)
	player_dt.add_exception(self)
	attack_dt.add_exception(self)
	
	player_dt.set_cast_to(Vector2(DETECTION_RANGE, 0))
	attack_dt.set_cast_to(Vector2(ATTACK_RANGE, 0))
	
	attack_time = anim.get_animation("attack").get_length() / anim.get_speed()
	pass

func _process(delta):
	
	pass

# define how SELF moves
func move(target, max_velocity):
	var position = get_pos()
	var velocity = Vector2(target - position).normalized() * max_velocity
	set_linear_velocity(Vector2(velocity.x, get_linear_velocity().y).floor())
	pass

func is_target_out_of_range(x_range, y_range):
	var length_dist = abs(get_pos().x - target.get_pos().x)
	var height_dist = abs(get_pos().y - target.get_pos().y)
	
	if length_dist >= x_range or height_dist >= y_range:
		return true
	else:
		return false
	pass

# Character
# Check for the ground
func ground_check():
	if ground_dt.is_colliding():
		var body = ground_dt.get_collider()
		if body.is_in_group("GROUND"):
			return true
	else:
		return false
	pass

func die():
	.die()
	randomize()
	set_linear_velocity(-100*Vector2(direction*floor(rand_range(2,5)), floor(rand_range(5,10))))
	pass