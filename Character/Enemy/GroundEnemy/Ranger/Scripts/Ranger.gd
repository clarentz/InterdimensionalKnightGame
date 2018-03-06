extends "res://Character/Enemy/GroundEnemy/GroundEnemy.gd"

onready var alert_sign = flip.get_node("alert_sign")
onready var backoff_trail = flip.get_node("backoff_trail")
onready var fire_position = flip.get_node("attack").get_node("fire_position")

var ArrowScene      = preload("res://Character/Enemy/GroundEnemy/Ranger/arrow.tscn")

export var PROJECTILE_SPEED = 600
export var BACKOFF_COOLDOWN = 4
export var BACKOFF_PROXIMITY = 150
export var BACKOFF_DISTANCE = 1000

# STATES
const STATE = { 
	WANDER = "wander",
	PURSUIT = "pursuit",
	ATTACK = "attack",
	BACKOFF = "backoff",
	HURT = "hurt",
	ALERT = "alert"
}

var attack_timer = 0
var backoff_timer = 0

# READY
func _ready():
	state_machine.push_state(STATE.WANDER)
	pass

func _process(delta):
	if backoff_timer > 0:
		backoff_timer = backoff_timer - Utils.fixed_delta
	pass

func _draw():
	if DEBUG_MODE:
		draw_circle(Vector2(0,0), PURSUIT_RANGE, Color(0, 1, 0, 0.1))
		draw_circle(Vector2(0,0), BACKOFF_PROXIMITY, Color(1, 0, 0, 0.5))
		var prev_item = get_pos()
		for item in PursuitBehavior.traces:
			draw_line(prev_item-get_pos(), item-get_pos(), Color(0,0,1), 2)
			draw_circle(item-get_pos(), 10, Color(0,0,1))
			prev_item = item
	pass

# Override
# Take damage when being attacked
func take_damage(damage, direction, push_back_force):
	if anim.get_current_animation() == STATE.ATTACK:
		push_back_force = Vector2(0,0)
	else:
		state_machine.push_state(STATE.HURT)
		run_anim()
	
	if not state_machine.get_current_state() == STATE.BACKOFF:
		.take_damage(damage, direction, push_back_force)
	pass

## Animation handling
func run_anim():
	current_state = state_machine.get_current_state()
	
	if current_state == STATE.WANDER:
		if WanderBehavior.is_wandering():
			play_loop_anim(STATE.WANDER)
		else:
			idle()
	elif current_state == STATE.PURSUIT:
		play_loop_anim(STATE.PURSUIT)
	elif current_state == STATE.HURT:
		anim.stop()
		anim.play(STATE.HURT)
	elif current_state == STATE.ATTACK:
		anim.stop()
		anim.play(STATE.ATTACK)
	elif current_state == STATE.ALERT:
		anim.stop()
	elif current_state == STATE.BACKOFF:
		play_loop_anim(STATE.BACKOFF)
	pass


# WANDER STATE ------------------------------------------------------------------------
# WANDERING and IDLING
func wander():
	WanderBehavior.wander()
	run_anim()
	
	## EXIT
	# WANDER -> ALERT
	if player_dt.is_colliding():
		WanderBehavior.exit()
		state_machine.push_state(STATE.ALERT)
	pass


# ALERT STATE ------------------------------------------------------------------------
# ALERTING
func alert():
	run_anim()
	direction = sign(target.get_pos().x - get_pos().x)
	alert_sign.set_hidden(false)
	var animation = alert_sign.get_node("anim")
	if not animation.is_playing():
		animation.play("alert")
	yield(animation, "finished")
	alert_sign.set_hidden(true)
	
	## EXIT
	# ALERT -> PURSUIT
	state_machine.pop_state()
	state_machine.push_state(STATE.PURSUIT)
	pass


# PURSUIT STATE -----------------------------------------------------------------------
# PURSUIT the PLAYER when they are detected
func pursuit():
	PursuitBehavior.pursuit()
	run_anim()
	
	
	## EXIT
	# PURSUIT -> PREVIOUS STATE
	if is_target_out_of_range(PURSUIT_RANGE, OS.get_window_size().y):
		PursuitBehavior.exit()
		state_machine.pop_state()
	
	## EXIT
	# PURSUIT -> ATTACK
	if attack_dt.is_colliding() and ground_check():
		PursuitBehavior.exit()
		attack_timer = 0
		state_machine.push_state(STATE.ATTACK)
	pass

	## EXIT
	# PURSUIT -> BACKOFF
	if backoff_timer <= 0 and get_pos().distance_to(target.get_pos()) <= BACKOFF_PROXIMITY:
		state_machine.push_state(STATE.BACKOFF)
	pass

# HIT STATE -----------------------------------------------------------------------------
# When SELF is take_damage
func hurt():
	## EXIT
	# HURT -> PREVIOUS STATE
	if ground_check() and not anim.is_playing():
		attack_timer = 0
		state_machine.pop_state()
	pass


# ATTACK STATE -------------------------------------------------------------------------
# ATTACK the PLAYER
func attack():
	attack_timer = attack_timer - Utils.fixed_delta
	
	# Start Attack condition
	if attack_timer <= 0:
		run_anim()
		attack_timer = ATTACK_COOLDOWN + attack_time 
	
	# Running Attack condition
	if attack_timer >= ATTACK_COOLDOWN:
		direction = sign(target.get_pos().x - get_pos().x)
	else:
		idle()
	
	## EXIT
	# ATTACK -> PREVIOUS STATE
	if is_target_out_of_range(ATTACK_RANGE*1.5, OS.get_window_size().y) or not ground_check():
		attack_timer = 0
		state_machine.pop_state()
	
	## EXIT
	# ATTACK -> BACKOFF
	if backoff_timer <= 0 and get_pos().distance_to(target.get_pos()) <= BACKOFF_PROXIMITY:
		if not anim.get_current_animation() == STATE.ATTACK:
			attack_timer = 0
			state_machine.push_state(STATE.BACKOFF)
	pass

func fire():
	var arrow = ArrowScene.instance()
	arrow.init_variables(self)
	Utils.get_main_node().add_child(arrow)
	pass


# BACKOFF STATE -----------------------------------------------------------------------------
# Back off a step when PLAYER get too close
func backoff():
	if backoff_timer <= 0:
		if ground_check():
			run_anim()
			backoff_trail.set_emitting(true)
			set_axis_velocity(Vector2(BACKOFF_DISTANCE * -direction, -JUMP_FORCE))
			backoff_timer = BACKOFF_COOLDOWN
	elif get_linear_velocity().floor().y == 0:
		while(backoff_trail.is_emitting()):
			backoff_trail.set_emitting(false)
		
		## EXIT
		# BACKOFF -> PREVIOUS STATE
		state_machine.pop_state()
	pass

func die():
	.die()
	backoff_trail.set_emitting(false)
	pass
