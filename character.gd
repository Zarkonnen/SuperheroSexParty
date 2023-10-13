extends Person
class_name Character

@export var horny = 0
@export var drunk = 20
@export var tired = 10
@export var angry = 10

@export var fucks = true
@export var guilty = false

@export var fightAngry = 10
@export var fightTired = 10
@export var partyDrunk = 10
@export var partyAngry = 0
@export var partyHorny = 5
@export var partyTired = 5
@export var fuckHorny = -10
@export var fuckTired = 10
@export var talkTired = 5

@export var timeAngry = -2
@export var timeTired = 1
@export var timeHorny = 2
@export var timeDrunk = 1

@export var enemy:Character = null
@export var fancies:Character = null

@export var speed = 120
var seat:Seat = null
var moveTo:Vector2 = Vector2.ZERO
var timeUntilMove = 0
var timeUntilInteract = 0
var talkingToPlayer = false
var timeUntilSpeechClear = 0
var timeUntilVarChange = 0
var fucking = false
var doneByPlayer = false
var playerTimeout = 0

func _ready():
	timeUntilMove = randf_range(1, 7)
	timeUntilInteract = randf_range(1, 3)

func _process(delta):
	playerTimeout -= delta
	if moveTo != Vector2.ZERO:
		var amt = speed * delta
		if seat and (seat.sex or seat.name == "SexFallback"):
			amt = 400 * delta
		if position.distance_squared_to(moveTo) <= amt * amt:
			position = moveTo
			moveTo = Vector2.ZERO
			timeUntilInteract = randi_range(1, 6)
		else:
			position += (moveTo - position).normalized() * amt
	elif not talkingToPlayer:
		timeUntilSpeechClear -= delta
		if timeUntilSpeechClear <= 0:
			shutUp()
		timeUntilVarChange -= delta
		if timeUntilVarChange <= 0:
			angry = clamp(angry + timeAngry, 0, 100)
			tired = clamp(tired + timeTired, 0, 100)
			horny = clamp(horny + timeHorny, 0, 100)
			drunk = clamp(drunk + timeDrunk, 0, 100)
			timeUntilVarChange = 10
		timeUntilInteract -= delta
		if timeUntilInteract <= 0 and overlapping() and overlapping() is Character and overlapping().timeUntilInteract <= 0 and overlapping().moveTo == Vector2.ZERO and not overlapping().talkingToPlayer and not fucking and not overlapping().fucking:
			interact(overlapping())
			timeUntilInteract = randi_range(5, 15)
		else:
			timeUntilMove -= delta
			if timeUntilMove <= 0:
				fucking = false
				clearSeat()
				seat = %Seats.getFreeSocialSeat()
				if seat:
					seat.occupants.append(self)
					moveTo = seat.position
					timeUntilMove = randf_range(10, 25)
					shutUp()
				else:
					print("No free social seat!")

func clearSeat():
	if seat:
		seat.occupants = []
		seat = null

func fight(other:Character):
	say("!!!")
	angry = clamp(angry + fightAngry, 0, 100)
	tired = clamp(tired + fightTired, 0, 100)
	if other:
		other.fight(null)

func party(other:Character):
	say(":)")
	angry = clamp(angry + partyAngry, 0, 100)
	horny = clamp(horny + partyHorny, 0, 100)
	drunk = clamp(drunk + partyDrunk, 0, 100)
	tired = clamp(tired + partyTired, 0, 100)
	if other:
		other.party(null)

func talk(other:Character):
	say("...")
	tired = clamp(tired + talkTired, 0, 100)
	if other:
		other.talk(null)

func fuck(other:Character):
	clearSeat()
	other.clearSeat()
	seat = %Seats.getFreeSexSeat()
	if seat:
		other.seat = seat
		seat.occupants.append(self)
		moveTo = seat.position + Vector2(15, 0)
		other.moveTo = seat.position - Vector2(15, 0)
		timeUntilMove = randf_range(10, 40)
		other.timeUntilMove = timeUntilMove
		horny = clamp(horny + fuckHorny, 0, 100)
		tired = clamp(tired + fuckTired, 0, 100)
		other.horny = clamp(other.horny + other.fuckHorny, 0, 100)
		other.tired = clamp(other.tired + other.fuckTired, 0, 100)
		say("<3")
		other.say("<3")
		fucking = true
		other.fucking = true
	else:
		party(other)

func interact(other:Character):
	var fightV = min(angry, other.angry) + randi_range(0, 30)
	if enemy == other or other.enemy == self:
		fightV += 40
	var partyV = min(drunk, other.drunk) + randi_range(0, 30)
	var fuckV = min(horny, other.horny) + randi_range(0, 30)
	if fancies == other or other.fancies == self:
		fuckV += 40
	if not fucks or not other.fucks:
		fuckV = -100
	var talkV = min(tired, other.tired) + randi_range(0, 30)
	var options = [[fightV, fight], [partyV, party], [fuckV, fuck], [talkV, talk]]
	options.sort_custom(func(a, b): return a[0] > b[0])
	options[0][1].call(other)

func say(text):
	$Bubble/Speech.text = text
	$Bubble.visible = true
	timeUntilSpeechClear = 5

func shutUp():
	$Bubble/Speech.text = ""
	$Bubble.visible = false
	timeUntilSpeechClear = 10000
