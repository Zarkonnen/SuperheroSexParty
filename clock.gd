extends Node2D

@export var timeout = 300
var time = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()
	time += delta
	if time > timeout and not %Player.lost:
		%Player.lost = true
		%Player.say("You've done your best, but the party is winding down. People are drunk, tired, chafed, and they depart before you're able to finish your mission.")
		

func _draw():
	draw_circle(Vector2(0, 0), 25, Color.BLACK)
	draw_circle(Vector2(0, 0), 23, Color.WHITE)
	draw_line(
		Vector2(0, 0),
		Vector2(cos(PI * 2 * time / timeout - PI / 2) * 21, sin(PI * 2 * time / timeout - PI / 2) * 21),
		Color.BLACK, 2)

