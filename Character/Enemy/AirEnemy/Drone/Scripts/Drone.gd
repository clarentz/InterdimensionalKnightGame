extends "res://Character/Enemy/AirEnemy/AirEnemy.gd"

var FlyingBehavior = preload("res://Character/Enemy/AirEnemy/AIBehaviors/FlyingBehavior.gd")

# STATES
const STATE = { 
	FLYING = "flying",
	
}

func _ready():
	FlyingBehavior = FlyingBehavior.new(self)
	state_machine.push_state(STATE.FLYING)
	pass

func flying():
	FlyingBehavior.fly()
	pass