extends RigidBody2D

var StackFSM = preload("res://Utils/StackFSM.gd")

onready var flip         = get_node("flip")
onready var anim         = flip.get_node("sprite/anim")
onready var target       = Utils.get_main_node().get_node("player")

# Collision boxes
onready var hurtbox = get_node("hurtbox")
onready var physics_box = get_node("physics_box")

export (bool) var DEBUG_MODE    = false
export (Vector2) var START_POSITION = Vector2(0, 0)
export (int) var MAX_HEALTH     = 10
export (int) var ATTACK_DMG     = 0
export (int) var CONTACT_DMG    = 0
export (int) var EXTRA_GRAVITY  = 2500
export (Vector2) var KNOCKBACK_FORCE = Vector2(0, 0)
export (int) var DETECTION_RANGE   = 1200
export (int) var ATTACK_RANGE   = 200
export (float) var ATTACK_INTERVAL = 1
export var ELEMENT = "none"

# init the StateMachine
var state_machine = StackFSM.new(self)

# Stats
var current_health = 0
var direction  = 1
var current_state = ""
var status = ""

func _ready():
	set_process(true)
	set_fixed_process(true)
	
	set_applied_force(Vector2(0, EXTRA_GRAVITY))
	current_health = MAX_HEALTH
	pass

# PROCESS
func _process(delta):
	# flip the sprite
	flip.set_scale(Vector2(direction, 1))
	
	# death
	if current_health <= 0:
		die()
	pass

# FIXED PROCESS
func _fixed_process(delta):
	state_machine.update()
	update()
	pass

func take_damage(damage, direction, push_back_force):
	current_health -= damage
	set_linear_velocity(Vector2(push_back_force.x*direction, push_back_force.y))
	direction = -self.direction
	pass

# Handle looped animations
func play_loop_anim(name):
	if anim.get_current_animation() != name:
		anim.play(name)
	pass

# Call this to be idle
func idle():
	move(get_pos(), 0)
	play_loop_anim("idle")
	pass

func die():
	set_process(false)
	set_fixed_process(false)
	hurtbox.queue_free()
	physics_box.queue_free()
	anim.play("die")
	yield(anim, "finished")
	queue_free()
	pass