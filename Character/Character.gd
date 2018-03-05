extends RigidBody2D

##PRELOAD
var StatusArray = preload("res://Environment/ElementalStatus/StatusArray.gd")
var StackFSM = preload("res://Utils/StackFSM.gd")
var DamageLabel = preload("res://HUD/damage_label.tscn")

##onready
onready var flip = get_node("flip")
onready var anim = get_node("anim")
onready var hurtbox      = get_node("hurtbox")
onready var physics_box  = get_node("physics_box")

##EXPORT VAR
export (bool) var DEBUG_MODE   = false
export (Vector2) var START_POSITION = Vector2(0, 0)
export (int) var MAX_HEALTH = 20
export (int) var EXTRA_GRAVITY = 2500
export (int) var MAX_RUN_SPEED = 800
export (int) var ACCERLERATION = 100
export var ELEMENT = "none"

##PRIVATE VAR
var max_run_speed = 0 #
var extra_gravity = 0
var accerleration = 0
var max_health = 0

##Common var
var direction = 1 #direction = -1:left; 1:right
var current_speed = Vector2()
var current_health = 0
var current_state = ""
var elapsed_time = 0

#states: "ground", "air",...
var state_machine = StackFSM.new(self)

##ELEMENTS_HARMFUL
var status_array = StatusArray.new()

func _ready():
	init_variable()
	#set fixed process
	set_process(true)
	set_fixed_process(true)
	#apply gravity
	set_applied_force(Vector2(0,extra_gravity))
	#set begin health
	current_health = max_health
	pass

#inti variable
func init_variable():
	max_run_speed = MAX_RUN_SPEED
	extra_gravity = EXTRA_GRAVITY
	accerleration = ACCERLERATION
	max_health = MAX_HEALTH
	pass

func _fixed_process(delta):
	state_machine.update()
	update()
	pass

func _process(delta):
	elapsed_time = delta
	flip.set_scale(Vector2(direction,1))
	active_status(delta)
	
	if current_health <= 0:
		die()
	pass

# Handle looped animations
func play_loop_anim(name):
	if anim.get_current_animation() != name:
		anim.play(name)
	pass

##take_damage: Can be extend depend character
#direction: push direction in x-axis
func take_damage(damage, direction, push_back_force):
	current_health -= damage
	set_linear_velocity(Vector2(push_back_force.x * direction, push_back_force.y))
	self.direction = -direction
	
	# Show Damage
	var label = DamageLabel.instance()
	label.init_variables(self)
	label.show_damage(label.TYPE.REGULAR, damage, direction, Utils.STATUS.NONE)
	Utils.get_main_node().add_child(label)
	pass

##to apply element
func apply_status(type, duration, level):
	var new_status = Utils.creat_status(type, self, duration, level)
	status_array.add(new_status, elapsed_time)
	pass

#make element effect run
func active_status(delta):
	status_array.update(delta)
	pass

# Call this to be idle
func idle():
	move(get_pos(), 0)
	play_loop_anim("idle")
	pass

func die():
	set_process(false)
	set_fixed_process(false)
	state_machine.flush()
	hurtbox.queue_free()
	physics_box.queue_free()
	anim.play("die")
	yield(anim, "finished")
	queue_free()
	pass

