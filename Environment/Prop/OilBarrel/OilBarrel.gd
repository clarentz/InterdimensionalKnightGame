extends RigidBody2D

onready var spark = get_node("spark")
onready var oil_leak = get_node("oil_leak")
onready var spawn_pos = get_node("spawn_pos")

export var MAX_HEALTH = 8
export var MAX_AMOUNT = 20
export var FLYING_FORCE = Vector2(1500, -1000)
export var SPAWN_INS = preload("res://Environment/ElementalHazard/oil_drop.tscn")
export var TICK_TIME = 0.1

var health
var amount
#if true set spawning the oil drops
var leaking = false
var timer = 0
#if true the barrel is throwed
var flying = false

func _ready():
	health = MAX_HEALTH
	amount = MAX_AMOUNT
	
	oil_leak.set_emitting(false)
	spark.set_emitting(false)
	
	set_process(true)
	pass

#process
func _process(delta):
	#leaking
	if timer >= TICK_TIME && leaking && amount > 0:
		spawn()
		amount -= 1
		timer = 0
	elif amount <= 0:
		oil_leak.set_emitting(false)
	elif timer < TICK_TIME:
		timer += delta
	#flying
	pass

func spawn():
	var oil_ins = SPAWN_INS.instance()
	var temp_spawn_pos = spawn_pos.get_global_pos()
	#random
	var offsetX = randf(-32,32)
	temp_spawn_pos.x += offsetX
	oil_ins.set_global_pos(temp_spawn_pos)
	Utils.get_main_node().add_child(oil_ins)
	pass

func take_damage(damage, filter1, filter2):
	health -= damage
	spark.set_emitting(true)
	if !leaking:
		leak()
	if health <= 0:
		explode()
	pass

func leak():
	leaking = true
	oil_leak.set_emitting(true)
	pass

func interact_effect(user):
	var direction = user.direction
	var temp_force = FLYING_FORCE
	temp_force.x = temp_force.x * direction
	set_linear_velocity(temp_force)
	flying = true
	pass

func explode():
	print("create explosion")
	#disappear
	queue_free()
	pass
#flying and hit the floor
func _on_ground_dt_body_enter( body ):
	if body.is_in_group("GROUND"):
		if flying && leaking:
			explode()
		else:
			flying = false
	pass # replace with function body
