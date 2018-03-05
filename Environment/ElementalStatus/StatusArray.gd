
var list = Array()

#add a status in to the array
#check if we can combine the new status into any existing status
func add(status, delta):
	var done = false
	var size = list.size()
	for i in range(size):
		done = list[i].combine(status, delta)
		if !done:
			continue
		else:
			list[i] = done
			return
	#cannot combine into anything
	list.append(status)
	status.start_effect.call_func()
	pass

#update all status inside the array
func update(delta):
	var iter = list.size() - 1
	while(iter >= 0):
		list[iter].update(delta)
		if list[iter].duration <= 0:
			call_deferred("remove", list[iter], iter)
#			remove(list[iter], iter)
		iter -= 1
	pass

#remove the status from the array
#pos: its position inside the array
func remove(status, pos):
	status.rev_effect.call_func()
	list.remove(pos)
	pass