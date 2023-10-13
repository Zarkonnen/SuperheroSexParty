extends Panel

var timeout = 0

func _process(delta):
	if visible:
		timeout -= delta
		if timeout <= 0:
			visible = false

func achieve(img, text):
	$Icon.texture = load("res://" + img + ".png")
	$Label.text = text
	timeout = 10
	visible = true
