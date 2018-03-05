extends Position2D

onready var label = get_node("label")
onready var tween = get_node("tween")

export (int) var DISTANCE = Vector2(100, 200)
export (int) var SPREAD = 30
export (float) var MAX_SCALE = 2
export (float) var DURATION = 1

const TYPE = {
	REGULAR = "regular",
	DOT = "dot"
}

var parent
var damage
var color
var start_position = Vector2(0,0)
var final_position = Vector2(0,0)

func init_variables(parent):
	self.parent = parent
	start_position = parent.get_pos()
	pass

func show_damage(damage_type, damage, direction, status):
	self.damage = str(damage)
	
	# Set the label's movement
	if damage_type == TYPE.REGULAR:
		randomize()
		var angle = deg2rad(floor(rand_range(-SPREAD, SPREAD)))
		var distance = floor(rand_range(DISTANCE.x, DISTANCE.y))
		final_position.x = start_position.x + distance * cos(angle) * direction
		final_position.y = start_position.y + distance * sin(angle)
		
		# Red color for damages dealt to PLAYER
		if parent.is_in_group("PLAYER"):
			color = Color(1, 0, 0, 1)    # Red
		elif status == Utils.STATUS.NONE:
			color = Color(1, 1, 1, 1)    # White
	elif damage_type == TYPE.DOT:
		randomize()
		final_position = start_position
		final_position.y = start_position.y - floor(rand_range(DISTANCE.x, DISTANCE.y))
		
		if status == Utils.STATUS.POISON:
			color = Color(0.133, 0.545, 0.133, 1)    # ForestGreen
		elif status == Utils.STATUS.FIRE:
			color = Color(1, 0.549, 0, 1)    # Dark Orange
	pass

func _ready():
	set_process(true)
	label.set_text(damage)
	label.set("custom_colors/font_color", color)
	
	tween.interpolate_property(self, "transform/pos", start_position, final_position,
	DURATION, Tween.TRANS_EXPO, Tween.EASE_OUT)
	
	tween.interpolate_property(self, "transform/scale", get_scale(), get_scale()*MAX_SCALE,
	DURATION, Tween.TRANS_QUART, Tween.EASE_OUT)
	
	tween.interpolate_property(self, "visibility/opacity", get_opacity(), 0,
	DURATION, Tween.TRANS_QUINT, Tween.EASE_IN)
	
	tween.start()
	pass

func _process(delta):
	yield(tween, "tween_complete")
	queue_free()
	pass
