extends Sprite2D
class_name Person

var overlaps = []

func _entered(area:Area2D):
	if area.get_parent() is Character:
		overlaps.append(area.get_parent())

func _exited(area:Area2D):
	overlaps.erase(area.get_parent())

func overlapping():
	overlaps.sort_custom(func (a, b): return a.position.distance_squared_to(position) < b.position.distance_squared_to(position))
	if overlaps.is_empty():
		return null
	else:
		return overlaps[0]
