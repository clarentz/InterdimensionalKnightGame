var body
var stack = Array()

var update_func
var prev_state = ""

func _init(body):
	self.body = body
	pass

func update():
	var cur_state = get_current_state()
	if cur_state != null and cur_state != prev_state:
		update_func = funcref(body, cur_state)
		prev_state = cur_state
	update_func.call_func()
	pass

func pop_state():
	stack.pop_back()
	pass

func push_state(state):
	if get_current_state() != state:
		stack.push_back(state)
	pass

func get_current_state():
	if stack.empty():
		return null
	else:
		return stack.back()
	pass

func flush():
	stack.clear()
