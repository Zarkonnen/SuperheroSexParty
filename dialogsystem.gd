extends Label

var options = []

func _process(delta):
	for i in range(options.size()):
		if Input.is_action_just_released(["option_1", "option_2", "option_3"][i]):
			options[i][1].call()

func ask(text, options):
	%Panel.visible = true
	self.options = options
	var n = 1
	for o in options:
		text += "\n" + str(n) + ". " + o[0]
		n += 1
	self.text = text

func clear():
	%Panel.visible = false
	options = []
	text = ""
