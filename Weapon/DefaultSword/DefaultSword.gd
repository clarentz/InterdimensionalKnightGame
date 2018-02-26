extends "res://Weapon/Weapon.gd"
#tester visual

onready var hitboxes = get_node("hitboxes")
onready var anim = get_node("anim")
#atk1_comb
onready var atk1_combo1 = hitboxes.get_node("atk1_combo1")
onready var atk1_combo2 = hitboxes.get_node("atk1_combo2")
onready var atk1_combo3 = hitboxes.get_node("atk1_combo3")
onready var atk1_air_spin = hitboxes.get_node("atk1_air_spin")
onready var atk2_thrust = hitboxes.get_node("atk2_thrust")
onready var atk2_air_downward_thrust = hitboxes.get_node("atk2_air_downward_thrust")

#spawn position of hazard
onready var spawn_pos = hitboxes.get_node("spawn_pos")
onready var spawn_pos_2dwt = atk2_air_downward_thrust.get_node("spawn_pos_2dwt")
#hazard use to spawn
var stored_status = null
var SimpleHazard = preload("res://Environment/ElementalHazard/SimpleElementalHazard.tscn")
#all the state this weapon have

func _ready():
	stop_all_hitboxes()
#	stored_status = SimpleHazard
	pass

func stop_all_hitboxes():
	atk1_combo1.call_deferred("set_enable_monitoring", false)
	atk1_combo2.call_deferred("set_enable_monitoring", false)
	atk1_combo3.call_deferred("set_enable_monitoring", false)
	atk1_air_spin.call_deferred("set_enable_monitoring", false)
	atk2_thrust.call_deferred("set_enable_monitoring", false)
	atk2_air_downward_thrust.call_deferred("set_enable_monitoring", false)
	pass
##ground atk
func state_atk1_init():
	cur_atk_state = StateAtk1Combo1.new(self)
	pass
	
func state_atk1_air_init():
	cur_atk_state = StateAtk1AirSpin.new(self)
	pass
	
func state_atk2_init():
	if user.btn_down.check() == 1 || user.btn_down.check() == 2:
		cur_atk_state = StateAtk2ThrustDown.new(self)
	else:
		cur_atk_state = StateAtk2Thrust.new(self)
	pass
	
func state_atk2_air_init():
	cur_atk_state = StateAtk2AirThrustDownward.new(self)
	pass

##ATTACK STATES
class StateAtk1Combo1 extends "res://Utils/AttackState.gd":
	func _init(weapon).(weapon):
		HITBOX = WEAPON.atk1_combo1
		ANIM_PLAYER = WEAPON.anim
		ANIM_NAME = "atk1combo1"
		ANIM_PLAYER.play(ANIM_NAME)
		USER.move(0, USER.accerleration)
		switch_attack_func()
		pass
	func attack_func():
		if WEAPON.user.btn_atk1.check() == 1:
			ANIM_PLAYER.stop()
			HITBOX.call_deferred("set_enable_monitoring", false)
			WEAPON.cur_atk_state = WEAPON.StateAtk1Combo2.new(WEAPON)

		pass
	func callback_func():
		if WEAPON.user.btn_atk1.check() == 1:
			WEAPON.cur_atk_state = WEAPON.StateAtk1Combo2.new(WEAPON)
		if not ANIM_PLAYER.is_playing():
			WEAPON.stop_atking()
		pass

class StateAtk1Combo2 extends "res://Utils/AttackState.gd":
	func _init(weapon).(weapon):
		HITBOX = weapon.atk1_combo2
		ANIM_PLAYER = weapon.anim
		ANIM_NAME = "atk1combo2"
		ANIM_PLAYER.play(ANIM_NAME)
		switch_attack_func()
		pass
	func attack_func():
		if WEAPON.user.btn_atk1.check() == 1:
			ANIM_PLAYER.stop()
			HITBOX.call_deferred("set_enable_monitoring", false)
			WEAPON.cur_atk_state = WEAPON.StateAtk1Combo3.new(WEAPON)
		pass
	func callback_func():
		if WEAPON.user.btn_atk1.check() == 1:
			WEAPON.cur_atk_state = WEAPON.StateAtk1Combo3.new(WEAPON)
		if not ANIM_PLAYER.is_playing():
			WEAPON.stop_atking()
		pass

class StateAtk1Combo3 extends "res://Utils/AttackState.gd":
	func _init(weapon).(weapon):
		HITBOX = weapon.atk1_combo3
		ANIM_PLAYER = weapon.anim
		ANIM_NAME = "atk1combo3"
		ANIM_PLAYER.play("init")
		ANIM_PLAYER.play(ANIM_NAME)
		switch_attack_func()
		pass
	func attack_func():
		
		pass
	func callback_func():
		if not ANIM_PLAYER.is_playing():
			WEAPON.stop_atking()
		pass

class StateAtk1AirSpin extends "res://Utils/AttackState.gd":
	func _init(weapon).(weapon):
		HITBOX = weapon.atk1_air_spin
		ANIM_PLAYER = weapon.anim
		ANIM_NAME = "atk1airspin"
		ANIM_PLAYER.play("init")
		ANIM_PLAYER.play(ANIM_NAME)
		switch_attack_func()
		pass
	func attack_func():
		WEAPON.air_move(USER)
		pass
	func callback_func():
		WEAPON.air_move(USER)
		if not ANIM_PLAYER.is_playing():
			WEAPON.stop_atking()
		pass

##ATK2
#thrust
class StateAtk2Thrust extends "res://Utils/AttackState.gd":
	func _init(weapon).(weapon):
		HITBOX = weapon.atk2_thrust
		ANIM_PLAYER = weapon.anim
		ANIM_NAME = "atk2_thrust"
		ANIM_PLAYER.play(ANIM_NAME)
		switch_attack_func()
		pass
	func attack_func():
		USER.move( USER.direction*USER.max_run_speed*1.5, USER.accerleration)
		pass
		
	func switch_callback_func():
		ANIM_PLAYER.stop()
		ANIM_NAME = "atk2_thrust_callback"
		ANIM_PLAYER.play(ANIM_NAME)
		.switch_callback_func()
		pass
	func callback_func():
		USER.move( 0, USER.accerleration)
		if not ANIM_PLAYER.is_playing():
			WEAPON.stop_atking()
		pass
#hit ground to cause explosion
class StateAtk2ThrustDown extends "res://Utils/AttackState.gd":
	func _init(weapon).(weapon):
		HITBOX = null
		ANIM_PLAYER = weapon.anim
		ANIM_NAME = "atk2_thrust_down"
		ANIM_PLAYER.play(ANIM_NAME)
		switch_callback_func()
		pass
	
	func create_hazard(hazard):
		var Hazard_Ins = hazard.spawn_hazard.instance()
		Hazard_Ins.set_global_pos(WEAPON.spawn_pos.get_global_pos())
		Utils.get_main_node().add_child(Hazard_Ins)
		pass
		
	func switch_callback_func():
		if WEAPON.stored_status != null:
			create_hazard( WEAPON.stored_status )
			WEAPON.stored_status = null
		.switch_callback_func()
	func callback_func():
		USER.move( 0, USER.accerleration)
		if not ANIM_PLAYER.is_playing():
			WEAPON.stop_atking()
		pass
#air thrust downward
class StateAtk2AirThrustDownward extends "res://Utils/AttackState.gd":
	func _init(weapon).(weapon):
		HITBOX = weapon.atk2_air_downward_thrust
		ANIM_PLAYER = weapon.anim
		ANIM_NAME = "atk2_air_downward_thrust"
		ANIM_PLAYER.play(ANIM_NAME)
		switch_attack_func()
		pass
	func switch_attack_func():
		USER.jump(-USER.jump_force/2)
		.switch_attack_func()
		pass
	func attack_func():
		WEAPON.air_move(USER)
		if USER.btn_atk1.check() == 1:
			ANIM_PLAYER.stop()
			HITBOX.call_deferred("set_enable_monitoring", false)
			WEAPON.cur_atk_state = WEAPON.StateAtk1AirSpin.new(WEAPON)
		pass
	
	func create_hazard(hazard):
		var Hazard_Ins = hazard.spawn_hazard.instance()
		Hazard_Ins.set_global_pos(WEAPON.spawn_pos_2dwt.get_global_pos())
		Utils.get_main_node().add_child(Hazard_Ins)
		pass
	
	func switch_callback_func():
		ANIM_PLAYER.stop()
		ANIM_NAME = "atk2_air_downward_thrust_callback"
		ANIM_PLAYER.play(ANIM_NAME)
		if WEAPON.stored_status != null:
			create_hazard( WEAPON.stored_status )
			WEAPON.stored_status = null
		.switch_callback_func()
		pass
	#no bounce
	func switch_callback_func_no_bounce():
		ANIM_PLAYER.stop()
		ANIM_NAME = "atk2_air_downward_thrust_callback_no_bounce"
		ANIM_PLAYER.play(ANIM_NAME)
		HITBOX.call_deferred("set_enable_monitoring", false)
		update_func = funcref(self, "callback_func_no_bounce")
		pass
	func callback_func():
		WEAPON.air_move(USER)
		USER.jump(700)
		if not ANIM_PLAYER.is_playing():
			WEAPON.stop_atking()
		pass
	func callback_func_no_bounce():
		USER.move(0, USER.accerleration)
		if not ANIM_PLAYER.is_playing():
			WEAPON.stop_atking()
		pass
##HITBOXES
func _on_atk1_combo1_area_enter( area ):
	if area.is_in_group("ENEMY"):
		direction = flip.get_scale().x
		area.get_parent().take_damage(damage, direction,push_back_force*0.5)
	pass

func _on_atk1_combo2_area_enter( area ):
	if area.is_in_group("ENEMY"):
		direction = flip.get_scale().x
		area.get_parent().take_damage(damage, direction, push_back_force)
	pass

func _on_atk1_combo3_area_enter( area ):
	if area.is_in_group("ENEMY"):
		direction = flip.get_scale().x
		area.get_parent().take_damage(damage*2, direction, push_back_force*1.5)
	pass # replace with function body

func _on_atk1_air_spin_area_enter( area ):
	if area.is_in_group("ENEMY"):
		direction = flip.get_scale().x
		area.get_parent().take_damage(damage, direction, push_back_force)
	pass # replace with function body
	
func _on_atk2_thrust_area_enter( area ):
	if area.is_in_group("ENEMY"):
		direction = flip.get_scale().x
		var push_back_force_edit = Vector2(push_back_force.x*3, push_back_force.y)
		var enemy = area.get_parent()
		enemy.take_damage(damage, direction,push_back_force_edit)
		#check to get stored status
		if enemy.has_method("get_stored_status"):
			stored_status = enemy.get_stored_status()
		#stop moving while thrusting
		switch_atk_state_callback()
	pass # replace with function body

func _on_atk2_air_downward_thrust_area_enter( area ):
	if area.is_in_group("ENEMY"):
		direction = flip.get_scale().x
		var push_back_force_edit = Vector2(0, 0)
		area.get_parent().take_damage(damage, direction,push_back_force_edit)
		#stop moving while thrusting
		switch_atk_state_callback()
	pass # replace with function body

func _on_atk2_air_downward_thrust_body_enter( body ):
	if body.is_in_group("GROUND"):
		if stored_status == null:
			switch_atk_state_callback_downward_thrust_no_bounce()
		else:
			switch_atk_state_callback()
	pass # replace with function body

#for downward move only
func switch_atk_state_callback_downward_thrust_no_bounce():
	cur_atk_state.switch_callback_func_no_bounce()
	pass
