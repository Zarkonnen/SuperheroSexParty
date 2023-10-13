@tool
extends Node2D
class_name Seat

@export var social = true:
	set(value):
		social = value
		queue_redraw()
@export var sex = false:
	set(value):
		sex = value
		queue_redraw()

var occupants = []

func _ready():
	if %Seats:
		if social:
			%Seats.social_seats.append(self)
		if sex:
			%Seats.sex_seats.append(self)

func _draw():
	if Engine.is_editor_hint():
		var clr = Color.BLUE
		if social:
			clr = Color.GREEN
		if sex:
			clr = Color.RED
		draw_rect(Rect2(-20, -20, 40, 40), clr, false, 2)
