extends "res://Character/Enemy/GroundEnemy/GroundEnemy.gd"

onready var hitbox = flip.get_node("attack/hitbox")
onready var alert_sign = flip.get_node("alert_sign")

var StoredStatus = preload("res://Environment/ElementalStatus/StoredStatus.gd")
var SimpleHazard = preload("res://Environment/ElementalHazard/SimpleElementalHazard.tscn")

# STATES
const STATE = { 
	WANDER = "wander",
	PURSUIT = "pursuit",
	ATTACK = "attack",
	HURT = "hurt",
	ALERT = "alert"
}

#Stored Status
var stored_status
var attack_timer = 0
var obj_attack

# READY
func _ready():
	state_machine.push_state(STATE.WANDER)
	hitbox.set_enable_monitoring(false)
	var shape = hitbox.get_node("shape").get_shape()
	shape.set_extents(Vector2(ATTACK_RANGE/2, shape.get_extents().y))
	hitbox.set_pos(Vector2(ATTACK_RANGE/2, 0))
	attack_dt.set_cast_to(Vector2(ATTACK_RANGE*2/3, 0))
	
	stored_status = StoredStatus.new(Utils.STATUS.POISON, 3, 1, SimpleHazard)
	pass


func _draw():
	if DEBUG_MODE:
		draw_circle(Vector2(0,0), PURSUIT_RANGE, Color(0, 1, 0, 0.1))
		draw_circle(Vector2(0,0), ATTACK_RANGE, Color(1, 0, 0, 0.5))
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
	.take_damage(damage, direction, push_back_force)
	pass

# Deal damage to PLAYER on contact
func _on_hurtbox_area_enter( area ):
	if area.is_in_group("PLAYER") and not anim.get_current_animation() == STATE.ATTACK:
		var damage_dir = sign(target.get_pos().x - get_pos().x)
		target.take_damage(CONTACT_DMG, damage_dir, KNOCKBACK_FORCE)
	pass # replace with function body

# Deal damage to PLAYER while attacking
func _on_hitbox_area_enter( area ):
	if area.is_in_group("PLAYER"):
		var damage_dir = direction
		target.take_damage(ATTACK_DMG, damage_dir, KNOCKBACK_FORCE)
	pass # replace with function body

## Animation handling
func run_anim():
	current_state = state_machine.get_current_state()
	
	if current_state == STATE.WANDER:
		if WanderBehavior.is_wandering():
			play_loop_anim(STATE.WANDER)
		else:
			idle()
	elif current_state == STATE.PURSUIT:
		if ground_check():
			play_loop_anim(STATE.PURSUIT)
		else:
			anim.stop()
			anim.play("jump")
	elif current_state == STATE.HURT:
		anim.stop()
		anim.play(STATE.HURT)
	elif current_state == STATE.ATTACK:
		anim.stop()
		anim.play(STATE.ATTACK)
	elif current_state == STATE.ALERT:
		anim.stop()
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

# HIT STATE -----------------------------------------------------------------------------
# When SELF is take_damage
func hurt():
	hitbox.set_enable_monitoring(false)
	
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
		obj_attack = Attack.new(self)
		attack_timer = ATTACK_COOLDOWN + attack_time 
	
	# Running Attack condition
	if attack_timer >= ATTACK_COOLDOWN:
		move(get_pos(), 0)
		direction = sign(target.get_pos().x - get_pos().x)
		obj_attack.update()
	else:
		idle()
	
	## EXIT
	# ATTACK -> previous STATE
	if get_pos().distance_to(target.get_pos()) > ATTACK_RANGE or not ground_check():
		hitbox.set_enable_monitoring(false)
		attack_timer = 0
		state_machine.pop_state()
	pass

func switch_windup_func():
	obj_attack.switch_windup_func()
	pass

func switch_attack_func():
	obj_attack.switch_attack_func()
	pass

func switch_callback_func():
	obj_attack.switch_callback_func()
	pass

func get_stored_status():
	return stored_status
	pass

# Inner class that handles attack
class Attack extends "res://Utils/AttackState.gd":
	
	func _init(weapon).(weapon):
		ANIM_PLAYER = weapon.anim
		HITBOX = weapon.hitbox
		USER.run_anim()
		pass
