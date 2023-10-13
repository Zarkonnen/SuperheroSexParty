class_name Util

static func pick_random(a:Array):
	if a.size() == 0:
		return null
	return a[randi() % a.size()]
