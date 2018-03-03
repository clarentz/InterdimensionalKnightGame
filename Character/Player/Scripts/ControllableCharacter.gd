extends "res://Character/Character.gd"

##import
var input_states = preload("res://Utils/InputStates.gd")

onready var ground_detector = get_node("ground_detector")

##CONST
const STATE = {
	GROUND = "state_ground",
	AIR = "state_air",
	ATKING = "state_attacking",
	HURT = "state_hurt"
}
##minor state
var falling = false

export (int) var JUMP_FORCE = 800
export (float) var INVULNERABLE_TIME = 1

#inputs
var btn_left = input_states.new("btn_left")
var btn_right = input_states.new("btn_right")
var btn_up = input_states.new("btn_up")
var btn_down = input_states.new("btn_down")
var btn_jump = input_states.new("btn_jump")
var btn_atk1 = input_states.new("btn_atk1")
var btn_atk2 = input_states.new("btn_atk2")

#weapon
onready var anim_status = get_node("anim_status")
onready var weapon = flip.get_node("DefaultSword")
#air atk already or not
var is_air_atk = false

func _ready():
	state_machine.push_state(STATE.AIR)
	pass

##FUNCTION
##ovrride take_damage
func take_damage(damage, direction, push_back_force):
	.take_damage(damage, direction, push_back_force)
	if state_machine.get_current_state() == STATE.ATKING:
		weapon.stop_all_hitboxes()
	state_machine.pop_state()
	state_machine.push_state(STATE.HURT)
	ground_detector.set_enabled(false)
	apply_status(Utils.STATUS.INVULNERABLE, INVULNERABLE_TIME, 0)
	pass
#move function
func move(to_speed, acc): 
	current_speed.x = lerp(current_speed.x, to_speed, acc*0.01) #acc * 0.01, turn into percent
	set_linear_velocity(Vector2( current_speed.x, get_linear_velocity().y ))
	pass
	
#jump function
func jump(force):
	set_axis_velocity( Vector2(0,-force) )
	pass

#ground check
func ground_check():
	if ground_detector.is_colliding():
		var body = ground_detector.get_collider()
		if body.is_in_group("GROUND"):
			return true
	else:
		return false
	pass

func platform_check():
	if ground_detector.is_colliding():
		var body = ground_detector.get_collider()
		if body.is_in_group("PLATFORM"):
			return body
	else:
		return null
	pass

##STATES
#ground
func state_ground():
	#inputs
	if btn_left.check() == 2:
		play_loop_anim("run")
		direction = -1
		move( direction * max_run_speed, accerleration)
	elif btn_right.check() == 2:
		play_loop_anim("run")
		direction = 1
		move( direction * max_run_speed, accerleration)
	else:
		play_loop_anim("idle")
		move(0, accerleration)
	
	#press
	if btn_jump.check() == 1:
		#if on platform
		var body = platform_check()
		if body != null:
			if btn_down.check() == 1 || btn_down.check() == 2:
				add_collision_exception_with(body)
			else:
				jump(JUMP_FORCE)
		else:
			jump(JUMP_FORCE)
	elif btn_atk1.check() == 1:
		state_machine.push_state(STATE.ATKING)
		weapon.state_atk1_init()
	elif btn_atk2.check() == 1:
		state_machine.push_state(STATE.ATKING)
		weapon.state_atk2_init()
	
	#check state
	if !ground_check():
		state_machine.pop_state()
		state_machine.push_state(STATE.AIR)
		is_air_atk = true
		falling = false
	pass

#air
func state_air():
	#animation:
	if get_linear_velocity().y < 0 and !falling:
		anim.play("jumping_up")
	elif get_linear_velocity().y >= 0:
		anim.play("falling_down")
		falling = true
	#inputs
	#movement
	if btn_left.check() == 2:
		direction = -1
		move( direction * max_run_speed, accerleration/10)
	elif btn_right.check() == 2:
		direction = 1
		move( direction * max_run_speed, accerleration/10)
	else:
		move(0, accerleration)
	#atk1
	if btn_atk1.check() == 1 && is_air_atk:
		state_machine.push_state(STATE.ATKING)
		weapon.state_atk1_air_init()
		is_air_atk = false
		pass
	elif btn_atk2.check() == 1 && is_air_atk:
		state_machine.push_state(STATE.ATKING)
		weapon.state_atk2_air_init()
		is_air_atk = false
		pass
	#state
	if ground_check():
		if platform_check() != null && !falling:
			return
		else:
			state_machine.pop_state()
			state_machine.push_state(STATE.GROUND)
	pass

#state attacking
func state_attacking():
	weapon.update()
	pass
#state hurt
func state_hurt():
	if ground_check():
		state_machine.pop_state()
		state_machine.push_state(STATE.GROUND)
#		hurtbox.set_monitorable(true)
	ground_detector.set_enabled(true)
	pass
#detect if leave the one way platform
func _on_oneway_leave_body_enter( body ):
	if body.is_in_group("PLATFORM"):
		remove_collision_exception_with(body)
	pass # replace with function body
