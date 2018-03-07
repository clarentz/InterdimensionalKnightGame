extends Node2D

# Display health Percentage
export (bool) var display_health_text = true
onready var health_text = get_node("health_text")

# Health value
var max_value
var current_value

# Health
onready var health = get_node("health")

# Start
func _ready():
	if(!display_health_text):
		health_text.hide()
	pass
	
# Initializing the health bar
func init(max_value, current_value):
	self.max_value = max_value * 1.0
	self.current_value = clamp(current_value * 1.0, 0, max_value)
	
	# Update health bar
	update()

# Set current health value 
func set_health(value):
	current_value = clamp(value, 0, max_value)
	
	# Update health bar
	update()

func update():
	# Calculate the health percentage
	var percentage = current_value/max_value
	
	# Update health bar scale
	health.set_scale(Vector2(percentage, 1))
	
	#Update label
	var percentage_text = str(percentage * 100) + "%"
	health_text.set_text(percentage_text.pad_decimals(0))
	