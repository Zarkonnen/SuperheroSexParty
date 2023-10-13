extends Person
class_name Player

@export var speed:int = 120

var moveTo = Vector2.ZERO
var fuckee:Character = null
var vs:Character = null
var guiltyFound = 0
var lost = false
var fucked = 0

func interact(other:Character):
	vs = other
	other.talkingToPlayer = true
	if other.name == "Gluon":
		gluon()
	if other.name == "Pyra":
		pyra()
	if other.name == "England":
		england()
	if other.name == "Glamour":
		glamour()
	if other.name == "Groupie":
		groupie()
	if other.name == "Leader":
		leader()
	if other.name == "Ourobouros":
		ourobouros()
	if other.name == "Telekinesis":
		telekinesis()
	if other.name == "Squirrels":
		squirrels()
	if other.name == "Speedo":
		speedo()
	
func goTo(other:Character, location):
	other.clearSeat()
	other.seat = get_node("%" + location)
	moveTo = other.seat.position + Vector2(15, 0)
	other.moveTo = other.seat.position - Vector2(15, 0)
	other.talkingToPlayer = true
	
func fuck(other:Character):
	other.doneByPlayer = true
	fuckee = other
	other.clearSeat()
	other.seat = %Seats.getFreeSexSeat()
	if not other.seat:
		other.seat = %SexFallback
	other.seat.occupants.append(other)
	if other.seat:
		moveTo = other.seat.position + Vector2(15, 0)
		other.moveTo = other.seat.position - Vector2(15, 0)
		other.talkingToPlayer = true

func stopFucking():
	fuckee.clearSeat()
	fuckee.talkingToPlayer = false
	moveTo = %Home.position

func _ready():
	ask("The Limited Space is a small area in Greece where superpowers almost don't work, making it neutral ground. Every year, superpowered beings from across the world congregate to have a party, get drunk, get laid - and not leave behind a crater in the process. Three of tonight's attendees are planning a heist tomorrow, but you don't know who exactly.", [["OK", intro_2]])

func intro_2():
	say("Usually, your vast telepathic powers would tell you, but usually they'd not go anywhere near you for that reason. But tonight, if you can get them close enough and alone enough - say in the bedroom - your limited powers will be enough to read their minds and figure it out before the party ends. Good luck!")

func _process(delta):
	if position.x < %TopLeft.position.x - 20 or position.x > %BottomRight.position.x + 20:
		AudioServer.get_bus_effect(0, 0).cutoff_hz = 500
	else:
		AudioServer.get_bus_effect(0, 0).cutoff_hz = 20000
	if guiltyFound >= 3 and fucked == 0:
		%AchievementPanel.achieve("chaste", "Chaste: Win the game without having sex with anyone.")
	if fucked >= 10:
		%AchievementPanel.achieve("slut", "Super-slut: Have sex with everyone at the party!")
	if %Dialog.text.is_empty():
		if lost:
			get_tree().change_scene_to_file("res://defeat.tscn")
			return
		elif guiltyFound >= 3:
			get_tree().change_scene_to_file("res://victory.tscn")
			return
	if moveTo != Vector2.ZERO:
		var amt = 400 * delta
		if position.distance_squared_to(moveTo) <= amt * amt:
			position = moveTo
			moveTo = Vector2.ZERO
		else:
			position += (moveTo - position).normalized() * amt
	elif %Dialog.text.is_empty():
		var velocity = Vector2.ZERO # The player's movement vector.
		if Input.is_action_pressed("move_right"):
			velocity.x += 1
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1
		if Input.is_action_pressed("move_down"):
			velocity.y += 1
		if Input.is_action_pressed("move_up"):
			velocity.y -= 1

		if velocity.length() > 0:
			velocity = velocity.normalized() * speed
		
		position += velocity * delta
		position.x = clamp(position.x, %TopLeft.position.x, %BottomRight.position.x)
		position.y = clamp(position.y, %TopLeft.position.y, %BottomRight.position.y)
		
		if Input.is_action_just_released("interact") and overlapping() and overlapping().moveTo == Vector2.ZERO:
			interact(overlapping())

# Interactions
func ask(t, options):
	%Dialog.ask(t, options)

func say(t):
	%Dialog.ask(t, [["OK", end]])

func end():
	if fuckee:
		stopFucking()
	%Dialog.clear()
	if vs:
		vs.playerTimeout = 20
		vs.talkingToPlayer = false
		vs.fucking = false
		vs.timeUntilMove = 0
	vs = null
	fuckee = null

func notGuilty():
	if vs.guilty:
		return ""
	else:
		return "not "

func discover():
	if vs.guilty:
		guiltyFound += 1
		%Score.text = str(guiltyFound) + "/3"
	vs.doneByPlayer = true

func gluon():
	if vs.doneByPlayer:
		say("Gluon smiles at you and carries on.")
	elif vs.playerTimeout > 0:
		say("Gluon nods to you but does not seem interested in any more conversation for now.")
	else:
		var t = "The face of Captain Gluon, science hero, lights up when he sees you approach."
		if vs.horny > 50:
			t = "Captain Gluon, science hero, is fiddling with the brooch on his jumpsuit."
		if vs.tired > 50:
			t = "Captain Gluon nods to you tiredly."
		ask(t, [["Hello, star sailor! I'd like to inspect your rocket.", gluon_inspect], ["How's it going, Gluon?", gluon_hi]])

func gluon_inspect():
	ask("\"Uh, my actual...\"", [["Grin and incline your head towards the bedrooms.", gluon_fuck], ["Oh sorry, I meant your actual rocket!", gluon_rocket]])

func gluon_fuck():
	if vs.tired > 50:
		ask("\"Oh, um, that's really sweet but I'm kind of tired. I'm sorry!\"", [["Okay, sweetie!", end]])
	else:
		vs.horny -= 20
		vs.tired += 10
		fuck(vs)
		discover()
		fucked += 1
		say("Gluon is a bit shy at first, but his rocket soon takes off. Now you are alone, you can focus your telepathic power. Mid-thrust, you discover that Gluon is " + notGuilty() + "one of the gang you seek.")
	
func gluon_rocket():
	if vs.horny > vs.tired:
		say("\"Maybe later?\" Gluon looks insulted.")
	else:
		goTo(vs, "Rocket")
		discover()
		say("Gluon looks a bit relieved and leads you into the garden where he's parked his rocket. He goes on excitedly about plasma conduits, and you're able to scan him, determining that he is " + notGuilty() + "one of the gang.")

func gluon_hi():
	vs.tired += 10
	say("You chat amicably. There's too much telepathic interference for you to be able to read his mind.")

func pyra():
	if vs.doneByPlayer:
		say("Pyra winks at you and moves on.")
	elif vs.playerTimeout > 0:
		say("\"I'll catch up with you later, babe!\"")
	else:
		var t = "Pyra, fire queen, is sipping listlessly at her cocktail."
		if vs.horny > 50:
			t = "Pyra sizes you up hungrily."
		if vs.angry > 50:
			t = "Pyra glares at you when you approach."
		if %Cigar.visible:
			ask(t, [["Hold out the cigar.", pyra_cigar], ["Hey Pyra! How's the party?", pyra_hi]])
		else:
			ask(t, [["Hey Pyra! How's the party?", pyra_hi]])

func pyra_cigar():
	%Cigar.visible = false
	ask("You hold the cigar in your mouth and Pyra grins, concentrates, and summons a tiny flame from the tip of her finger, just enough to light the thing.", [["Inhale deeply.", pyra_inhale], ["Puff smoke rings at Pyra.", pyra_rings], ["Thanks, Sweetie!", pyra_thanks]])
	
func pyra_inhale():
	say("You forgot that this is one of Ourobouros' cigars. His lungs grow back. Yours have just taken permanent damage, and you bend over, coughing. Pyra can't help but laugh at you, and the moment is broken.")

func pyra_rings():
	vs.angry += 10
	ask("She starts coughing. Oh yes, this is one of Ourobouros' infamously potent cigars.", [["I'm sorry! Can I make it up to you?", pyra_makeup], ["Oh no! Let's get some air?", pyra_air]])

func pyra_makeup():
	if vs.horny > vs.angry:
		fuck(vs)
		discover()
		fucked += 1
		say("You better! She leads you off to one of the bedrooms. Thankfully, she has very firm ideas on how you can make it up to her. With your head firmly between her thighs, you are able to focus your telepathy and determine that she is " + notGuilty() + "one of the supers you're looking for.")
	else:
		say("She just glares at you and turns away.")
		
func pyra_air():
	if vs.angry < 50:
		goTo(vs, "Garden")
		discover()
		say("She nods and you head out to the garden. You discard the cigar and the two of you chat, giving you ample time to probe her brain. She is " + notGuilty() + "one of the gang you're looking for.")
	else:
		say("\"Can you just go... over there for now?\"\nYou slink off.")

func pyra_thanks():
	if vs.horny > 40:
		fuck(vs)
		discover()
		fucked += 1
		say("You smile invitingly and tilt the cigar in what you hope is a sexy manner. Pyra takes the hint, and you find a convenient place to fuck. While your tongue is busy, you probe her mind and find out that she is " + notGuilty() + "one of the gang you're looking for.")
	else:
		say("You smile invitingly and tilt the cigar in what you hope is a sexy manner. But now the damn smelly thing is in between you, and Pyra does not seem interested in getting to know you better.")
	
func pyra_hi():
	if vs.angry + vs.drunk < 50:
		ask("\"Better now you're here!\"", [["Well thank you! I do know a way to make it even more fun, if you'd like to join me?", pyra_join]])
	else:
		ask("\"You know, the usual bunch of superpowered losers getting drunk like every year.\"", [["Well, wanna go somewhere quieter and make our own fun?", pyra_quieter], ["Yeah, fair, fair.", pyra_fair]])

func pyra_join():
	if vs.horny > 60:
		fuck(vs)
		discover()
		fucked += 1
		say("She grins, you link arms, and find your way to an empty room. As soon as the door is closed, Pyra starts to make out with you furiously. Somewhere between removing her bra and removing her pants you discover that she is " + notGuilty() + "one of the people you're looking for - but you're not in any hurry to leave even so.")
	else:
		vs.horny += 10
		say("She inclines her head. \"Maybe later?\"")

func pyra_quieter():
	if vs.horny > vs.angry + 20:
		fuck(vs)
		discover()
		fucked += 1
		say("Why not? The two of you link arms, weave past the drinkers, and find yourselves a room. As soon as the door is closed, Pyra starts to make out with you furiously. Somewhere between removing her bra and removing her pants you discover that she is " + notGuilty() + "one of the people you're looking for - but you're not in any hurry to leave even so.")
	else:
		vs.horny += 5
		say("\"No thank you\", she replies frostily.")

func pyra_fair():
	vs.angry -= 10
	say("You chat amicably. There's too much telepathic interference for you to be able to read her mind.")

func england():
	if vs.doneByPlayer:
		say("Commander England, swaying slightly from drink, ignores you.")
	elif vs.playerTimeout > 0:
		say("Commander England leers at you and then moves on in search of other people to impress.")
	else:
		var t = "Commander England is holding on to a can of beer, and holding forth about football. He's been working his way through the party, hitting on everyone."
		if vs.angry + vs.drunk > 60:
			t = "Commander England is looking even more bloated and pink-skinned than usual. He's been working his way through the party, hitting on everyone."
		ask(t, [["Greetings, Commander! How's things?", england_greetings], ["England, you old drunk!", england_drunk]])

func england_greetings():
	ask("He clunks your drink against his beer can.\n\"Oh, can't complain. Just got interviewed by Zulxiprax, again. Good mate of mine.\"", [["Oh, wow! You know, I have some questions to ask you as well. Maybe we can go somewhere more private?", england_private], ["I really doubt that.", england_doubt]])

func england_private():
	fuck(vs)
	discover()
	vs.horny -= 20
	vs.angry -= 20
	fucked += 1
	say("Commander England gets your hint readily enough, and you move to one of the bedrooms for an interview. Well, for him to mount you, grunting and sweating, while you endure and scan his mind: he is " + notGuilty() + "one of the gang you're looking for. Then he finally comes, twitching and spasming. You get dressed and leave.")

func england_doubt():
	if vs.angry < 50:
		ask("\"Naw really! We can go somewhere quiet and I can get Zulxiprax on the phone right now, and we can chat. Pretty cool, right?\"", [["Agree to go with him.", england_dial], ["Laugh.", england_bitch]])
	else:
		england_bitch()

func england_bitch():
	ask("\"You bitch, are you talking shit about me? Want to take this outside? I'll knock you down, teach you a lesson!\"", [["Sure, let's go!", england_fight]])

func england_fight():
	goTo(vs, "Garden")
	discover()
	ask("The two of you head outside and square off. Outside the limited space, Commander England is a formidable opponent, but here he's just a wheezing middle-aged man. You dodge his clumsy swings easily and read his mind at the same time - he is " + notGuilty() + "one of the gang!", [["Okay, okay, let's stop this!", england_concede]])

func england_concede():
	say("Out of breath, he concedes and you go back inside.")

func england_dial():
	fuck(vs)
	ask("You go to a room, fully expecting him to make a move on you, but he's actually dialling a number. No one picks up, and he gets visibly flustered.", [["Laugh at him.", england_laugh], ["I'm sure this doesn't usually happen to you. Try again?", england_try_again], ["You know, now we're here, I have other things in mind...", england_other_things]])

func england_laugh():
	vs.angry += 20
	if vs.horny > 50:
		say("He rounds on you with an angry glint in his eye. You become acutely aware of being alone in a room with him and depart in a hurry.")
	else:
		england_bitch()
	
func england_try_again():
	vs.angry += 10
	if vs.angry < 80:
		ask("He tries dialling again as you concentrate on reading his mind. He fails, again. You're nearly there!", [["Laugh at him.", england_laugh], ["Can you try one more time? I'm a huge fan of Zulxiprax!", england_fan], ["You know, now we're here, I have other things in mind...", england_other_things]])
	else:
		england_laugh()

func england_fan():
	ask("\"Really? Name three of his videos!\"", [["Zulxiprax interviews Commander England, Zulxiprax interviews Captain Gluon, Zulxiprax interviews Ourobouros", england_interviews]])

func england_interviews():
	discover()
	ask("\"That's on me\", he mutters, and tries dialling again, giving you enough time to complete your scan and determine that he is " + notGuilty() + "one of the people you're looking for. Then he fails to get through.", [["That's all right, we'll try again later.", end]])

func england_other_things():
	say("He is momentarily confused and then grins at you. Soon enough, he's on top of you, humping away, giving you ample time to scan his brain and determine that he is " + notGuilty() + "one of the people you're looking for. Then you just have to wait for him to finish so you can leave.")

func england_drunk():
	if vs.angry > 50:
		england_bitch()
	else:
		say("He grins and toasts you, and you spend some time chatting. There's too much interference to be able to scan his brain.")

func glamour():
	if vs.doneByPlayer:
		say("Mixatrix looks at you, embarrassed.")
	elif vs.playerTimeout > 0:
		say("Mixatrix stops for a quick word but then moves on.")
	else:
		var t = "nervous."
		if vs.drunk > 40:
			t = "inebriated."
		ask("Mixatrix the illusionist usually relies on glamours, so it's strange to see her in the flesh. She looks " + t, [["Hey Mix, how's de-powered life?", mix_life], ["Cheers, Mix!", mix_cheers]])

func mix_cheers():
	vs.drunk += 5
	vs.angry -= 5
	say("You clink drinks and have a friendly chat. She looks less nervous now.")

func mix_life():
	if vs.angry > 20:
		say("\"Why would you even ask me that? You know it's horrible. I don't even know why I'm here!\"\nShe turns away abruptly.")
	else:
		ask("\"Eh, I'm coping. And they're not quite gone, you know.\"\nA thin smile.", [["So can you still do some illusions?", mix_illusions]])

func mix_illusions():
	%Ring.visible = true
	ask("\"Yeah, tiny ones. See?\"\nShe detaches a pull tab from a beer can and concentrates. It takes on the appearance of a massive diamond ring. She hands it to you, and you put it on your finger.", [["Oh, what a valuable present! I'm... just overwhelmed, and I really need to thank you properly!", mix_overwhelmed]])

func mix_overwhelmed():
	if vs.tired > 20:
		say("\"Oh, it's no big deal.\"\nShe looks tired - that small glamour must have taken a lot of work.")
	else:
		fuck(vs)
		ask("Mixatrix grins, nods, and follows you to the bedroom.", [["OK", mix_fuck]])
		
func mix_fuck():
	ask("\"Uh, this is the point where I usually ask who or what I should look like, but...\"", [["Don't worry about it. Come here.", mix_come], ["Oh Mix, I like you the way you are!", mix_like]])

func mix_come():
	discover()
	fucked += 1
	say("She soon calms down under your ministrations and begins enjoying herself. You read her mind and determine that she is " + notGuilty() + "one of the people you're looking for.")

func mix_like():
	discover()
	say("She looks at you with big eyes and breaks down sobbing. This is not what you had planned. You comfort her, and guiltily scan her mind. She's " + notGuilty() + "one of the gang. Eventually, she regains her composure somewhat, and you both return to the party.")

func groupie():
	if vs.doneByPlayer:
		if %Camera.visible:
			say("You show Lithvak the pictures you've taken.\n\"Oh, those are great. No, keep it for now, it's probably good for me to not carry it all the time, you know?\"")
		else:
			say("Lithvak gives you an uneasy smile.")
	elif %Camera.visible:
		%Camera.visible = false
		say("You hand back the camera to Lithvak, who starts going through the pictures you took, ignoring you.")
	elif vs.playerTimeout > 0:
		say("Lithvak seems to be busy with other photographic subjects for now.")
	else:
		ask("Lithvak... was a superhero groupie until he got some minor rock powers himself. Now he can be found at every super event, taking selfies with everyone who gets close enough. He waves you over, camera in hand.", [["Move in for the inevitable selfie and give him a firm grope to establish your intentions.", groupie_grope], ["Make a terrible duck face for the camera.", groupie_duck]])

func groupie_grope():
	if vs.horny < 30:
		say("He takes the picture, looking flustered and confused. Then he moves on to get his next selfie.")
	else:
		fuck(vs)
		discover()
		fucked += 1
		ask("He takes the picture, cheek to cheek, which lets you easily transition into making out with him. Soon you're in a side room, taking your clothes off. You have to guide him through where you like to be touched, but he warms up to the task pretty fast. You scan his brain and determine he's " + notGuilty() + "one of the gang. When you're all done, he wants to show you photos on his camera.", [["Hey, can I borrow that for a bit?", groupie_borrow]])

func groupie_borrow():
	%Camera.visible = true
	say("He hesitates for a moment and then hands you the camera.")

func groupie_duck():
	if vs.angry > 30:
		vs.tired += 5
		say("He frowns at the result and leaves.")
	else:
		ask("He frowns at the result.", [["Hey, can I borrow your camera for a bit? I'll get some good shots with you in.", groupie_borrow], ["Let's go out into the garden for some nicer background, yeah?", groupie_garden]])

func groupie_garden():
	if vs.drunk < 30:
		ask("\"But it's dark out there! That won't work!\"", [["You roll your eyes and leave him to it.", end]])
	else:
		goTo(vs, "Statue")
		discover()
		vs.drunk -= 10
		vs.horny += 10
		ask("The two of you head to the garden and you make sexy poses in front of the statue of a Greek god. Lithvak is pleased with himself, and you're able to scan his mind. He's " + notGuilty() + "one of the people you're looking for.", [["Thanks, dear!", end], ["Hey, can I borrow your camera for a bit? I'll get some good shots with you in.", groupie_borrow]])
	

func leader():
	if vs.doneByPlayer:
		say("Zalgomma walks up to you, gropes your ass possessively, and leaves again without a word.")
	elif vs.playerTimeout > 0:
		say("Zalgomma eyes you suspiciously.")
	else:
		ask("Zalgomma, the magnificent, the powerful, the controlling bitch. She sizes you up and gives you a fake smile.\n\"So glad you could join us. How are your powers, my dear?\"", [["Oh, they're quite gone, Zalgomma.", leader_gone], ["Mostly gone. I can just feel vague emotions, like how pleased you are to see me.", leader_mostly]])

func leader_gone():
	ask("Really? I don't believe that. Surely you must know what I'm thinking about right now? Or do you need to move closer? She takes you by the waist and pulls you towards her, fixing your eyes in her gaze.", [["Lie.", leader_lie], ["Try to read her mind.", leader_read], ["Grind your hips against hers and ask to have this interrogation somewhere more private.", leader_private]])

func leader_lie():
	say("You make up something on the spot: \"That really won't work. You'd have to hold perfectly still for ten minutes for me to get any kind of read at all.\"\n\"Is that so? Very well.\"")

func leader_read():
	ask("So close up, looking into her eyes, it's perhaps possible. And yes, she's doing her best to broadcast a mental image of you with your hands tied behind your back and your face buried in her crotch. You can't help but blush.", [["I really can't tell, Zalgomma.", leader_cant], ["I can tell you want me.", leader_want]])

func leader_cant():
	lost = true
	say("\"Oh, but your face is telling me that you can. I'll not have you pick people's brains tonight!\"\nShe lets you go, then swiftly moves around the room, whispering to the attendants, who turn to you with stony faces. It looks like your plan has just failed.")

func leader_want():
	fuck(vs)
	discover()
	fucked += 1
	say("You offer up your lips and let her kiss you. She leads you away to another room, forces you to kneel, and makes you go down on her until your jaw hurts. At least you're able to scan her mind, determining that she is " + notGuilty() + "one of the gang you're looking for.")

func leader_private():
	fuck(vs)
	ask("She marches you off to a spare room and sits you down.", [["Take your clothes off.", leader_clothes], ["Read her mind.", leader_mind]])

func leader_clothes():
	if vs.guilty:
		ask("She stops you.\n\"Oh no, you are going to sit here and actually read my mind.\"", [["Read her mind.", leader_mind]])
	else:
		ask("She stops you.\n\"I know exactly why you're here. You're looking for the people doing that heist tomorrow. Well, I'm not one of them. Feel free to check my mind. But if you want me to keep quiet about it, I need you to obey me for a little while.\"", [["Nod.", leader_nod], ["Leave.", leader_leave]])

func leader_nod():
	ask("Good girl. Kneel down and, yes, put your hands behind your back. She takes off her golden sash and uses it to tie your hands, very tightly. Then she pulls her skirt to the side and commands you to start.", [["Start licking.", leader_nod2]])

func leader_nod2():
	discover()
	fucked += 1
	say("As you demurely start eating her out, she clamps her thighs together trapping you, cutting off your breath. You struggle. Keep licking. You comply. You start seeing stars, and your vision is getting dark - and then she finally comes. She releases you and leaves, letting you recover.")

func leader_leave():
	lost = true
	say("Zalgomma leaves the room alongside you and tells the others about your plan.")

func leader_mind():
	discover()
	if guiltyFound >= 3:
		say("She sits still as you read her mind. Now you know that she suspected your intent from the start, and has now confirmed it in her mind. Of course, since she was the last one you needed to scan, it doesn't matter now.")
	else:
		lost = true
		say("She sits still as you read her mind. Now you know that she suspected your intent from the start, and has now confirmed it in her mind. She leaves the room and tells the others, foiling your plan.")

func leader_mostly():
	if vs.horny > 50:
		ask("\"Oh, I am? And why is that so?\"", [["Because you've been eyeing me up since the moment I got in. And because you know I'm happy to give you... tribute.", leader_tribute]])
	else:
		ask("\"Oh, don't avoid the question. Surely you must know what I'm thinking about right now? Or do you need to move closer?\"\nShe takes you by the waist and pulls you towards her, fixing your eyes in her gaze.", [["Lie.", leader_lie], ["Try to read her mind.", leader_read], ["Grind your hips against hers and ask to have this interrogation somewhere more private.", leader_private]])

func leader_tribute():
	fuck(vs)
	discover()
	fucked += 1
	say("\"Quite right!\"\nThe two of you find an empty room and you lick her out until you can barely move your jaw. At least you now know she's (not) one of the people you're looking for.")

func ourobouros():
	if vs.doneByPlayer:
		say("Ourobouros winks at you and continues holding forth.")
	elif vs.playerTimeout > 0:
		say("Ourobouros exchanges a few quick pleasantries with you, and then excuses himself until later.")
	else:
		var t = "Ourobouros the Immortal is looking in fine form tonight, bragging and smoking heinous cigars."
		if vs.tired > 50:
			t = "Ourobouros the Immortal is looking just a little... tired? And sad?"
		if %Cigar.visible:
			ask(t, [["O great Ourobouros, can I ask you some questions about history?", our_history], ["Listen to his tales.", our_tales]])
		else:
			ask(t, [["Hey, can I have a cigar?", our_cigar], ["O great Ourobouros, can I ask you some questions about history?", our_history], ["Listen to his tales.", our_tales]])

func our_history():
	if vs.angry < 10 and vs.horny < 50:
		ask("\"I'll allow it, for once. What do you want to know?\"", [["Can we go somewhere quieter?", our_quieter]])
	else:
		vs.tired += 5
		say("\"Oh, you young people always want to ask me about history, and then you don't get the point, and then you mess things up anyway. I'm too old for this.\"")
	
func our_quieter():
	if vs.tired > 50:
		goTo(vs, "Garden")
		discover()
		say("Of course! You head off to the garden and ply Ourobouros with questions about ancient Mesopotamia, to which he gives rambling answers. You are able to scan his mind and determine that he is " + notGuilty() + "one of the gang you're looking for.")
	else:
		vs.horny += 5
		say("While the party's still going? Let's do that later.")

func our_cigar():
	%Cigar.visible = true
	if %Camera.visible:
		ask("\"Of course, my dear!\"\nHe hands you a cigar, which you tuck suggestively into your decolletage.\n\"Anything else I can do for you?\"", [["Well, you know. Me?", our_me], ["Can I take some photos of you? Maybe outside?", our_photos]])
	else:
		ask("\"Of course, my dear!\"\nHe hands you a cigar, which you tuck suggestively into your decolletage.\n\"Anything else I can do for you?\"", [["Well, you know. Me?", our_me]])

func our_me():
	if vs.horny > 30 and vs.tired < 60:
		fuck(vs)
		discover()
		fucked += 1
		say("\"Ah, a woman who knows what she wants! Excellent! Come this way!\"\nYou decamp into a private room. Ourobouros turns out to be a gentle and attentive lover. Evidently several millennia of experience do pay off. You just about remember to read his mind and learn that he is " + notGuilty() + "one of the gang you're looking for.")
	else:
		vs.horny += 5
		vs.tired += 5
		say("He frowns and looks tired.\n\"That's flattering, but not now.\"")

func our_photos():
	if vs.tired < 60:
		say("While the party's still going? Let's do that later.")
	else:
		goTo(vs, "Statue")
		discover()
		say("\"I could use a bit of quiet. Let's go.\"\nYou head out into the garden and Ourobouros poses in front of the statue - to which has an uncanny resemblance - while you take photos and read his mind. He is " + notGuilty() + "one of the gang you're seeking.")

func our_tales():
	vs.horny += 5
	vs.angry -= 5
	vs.tired += 5
	say("Ourobouros regales you with his exploits, which are actually really interesting. Still, you are unable to scan his mind in this crowd.")

func telekinesis():
	if vs.doneByPlayer:
		say("Lexandra gives you a brittle smile.")
	elif vs.playerTimeout > 0:
		say("Lexandra gives you a smile that does not quite reach her eyes.")
	else:
		var t = "Lexandra, telekinetic wonder, clearly chose her dress to show off her excellent legs, which are quite distracting."
		if vs.drunk > 40:
			t = "\"Oh hiii! How are you?\"\nApparently, Lexandra, telekinetic wonder, is in a good mood."
		if vs.angry > 40:
			t = "Lexandra, telekinetic wonder, is looking ravishing in her dress, as usual. And quite pissed off, as usual."
		ask(t, [["Hiii! You look lovely!", tele_lovely], ["Hey Lex, how are you holding up?", tele_holding], ["Oh wow, that's quite a dress!", tele_dress]])

func tele_lovely():
	vs.angry -= 5
	say("\"Why thank you!\"\nYou make polite chit-chat for a while, but you are unable to scan her brain.")

func tele_holding():
	ask("\"Oh you know, I'm always cranky when I can't use my powers properly. I guess it's the same for you? Can you still do anything?\"", [["Nope! And you?", tele_nope]])

func tele_nope():
	if vs.drunk < 50:
		vs.drunk += 20
		vs.angry -= 10
		vs.tired += 10
		ask("\"Oh, I don't want to talk about it. Let's just get drunk, my dear!\"", [["Get drunk.", end]])
	elif %Ring.visible:
		ask("\"Maybe a tiny bit - I could probably levitate that ring of yours.\"", [["Hand her the ring.", tele_ring]])
	else:
		ask("\"Maybe a tiny bit - I can demonstrate on a suitably tiny object, if you like?\"", [["I'll get back to you.", end]])

func tele_ring():
	%Ring.visible = false
	ask("She holds the ring in the palm of her hand and concentrates. It stirs, then lifts off, and slowly floats around the room.", [["Do you need to keep it in line of sight?", tele_sight]])

func tele_sight():
	ask("\"Oh, I don't know. Let me try...\"\nShe floats the ring out into the garden and to the side, out of sight. Then she flinches.\n\"Oh no, I dropped it!\"", [["I'll help you look for it!", tele_look]])

func tele_look():
	goTo(vs, "Garden")
	discover()
	say("So the two of you go out into the garden, trying to spot an englamoured pull tab in the darkness, giving you ample time to scan Lexandra's brain. She is " + notGuilty() + "one of the people you're looking for. Eventually, you find it. Its glamour is wearing off, so you quickly shove it into a pocket and go back inside.    ")

func tele_dress():
	if vs.angry > vs.horny:
		say("Well, at least it's not from a dumpster like yours! She stalks off.")
	else:
		ask("\"Why thank you! Yours is great too!\"", [["Thanks! It was half off!", tele_half]])

func tele_half():
	ask("Lexandra makes a did-you-really-just face and intones \"I'd like it better if it was 100% off.\"", [["That can be arranged.", tele_fuck]])

func tele_fuck():
	fuck(vs)
	discover()
	fucked += 1
	say("The two of you make your way to a more private location and rapidly remove your dresses, nice as they might be. A happy tangle of limbs ensues. While you're enjoying yourself, you read Lexandra's mind and determine that she is " + notGuilty() + "one of the gang you're looking for.")

func squirrels():
	if vs.doneByPlayer:
		say("The squirrels chatter to you happily.")
	elif vs.playerTimeout > 0:
		say("The squirrels are on a mission to get more nuts from the bowl, and only briefly say hi.")
	else:
		var t = "anxiously"
		if vs.tired > 40:
			t = "quietly"
		if vs.angry > 40:
			t = "angrily"
		ask("The Squirrel Gang is the consciousness of a single man split among a dozen hypercompetent squirrels, each with their own area of expertise. They are " + t + " nibbling on some salted nuts.", [["Hey squirrels, can I get you anything?", squirrels_get], ["Hey squirrels, lovely to see you!", squirrels_lovely]])

func squirrels_get():
	if vs.angry > 40:
		vs.tired += 5
		say("The squirrels speak in unison: \"We are perfectly capable of getting whatever you need, and you know that. Please don't talk down to us.\"")
	else:
		ask("The squirrels whisper in unison: \"Well, uh, you're a telepath, right? We do have a rather delicate question.\"", [["Of course, let's go somewhere more private.", squirrels_private]])

func squirrels_private():
	fuck(vs)
	ask("The thirteen of you head off to a bedroom. You sit down and listen to them explain:\n\"It's so tough seeing all those people flirt with each other. We feel so excluded.\"", [["I guess no one wants to...", squirrels_no_one]])

func squirrels_no_one():
	ask("\"It's not even that! When we transformed into our current form, we became squirrels, with the instincts of squirrels. So we're um physically attracted to squirrels. But other squirrels aren't sentient.\"", [["Oh shit, so it's a consent issue?", squirrels_consent]])

func squirrels_consent():
	ask("\"Exactly! You wouldn't want to have sex with a human with the IQ of a squirrel, right? But maybe there's something you can help us with? Fix us somehow?\"", [["Not with my current powers, but I can psychically scan you and think about it.", squirrels_scan], ["Well, I could probably psychically project as a squirrel...", squirrels_project]])

func squirrels_scan():
	if vs.guilty:
		say("\"Uh, perhaps we can meet up again about this later?\"\nThe squirrels leave before you're able to determine if they're part of the gang you're looking for.")
	else:
		discover()
		say("The squirrels readily agree. You scan their brains and determine that they're not a part of the gang you're looking for. Of course, you've now promised to alter their mind, which is something you usually steer away from, but if they really want it - that's a problem for another day.")
	
func squirrels_project():
	ask("\"Would you? We mean, we know it's a weird thing to ask, but it would mean a lot to us!\"", [["Sure, let's do it.", squirrels_sex]])
	
func squirrels_sex():
	discover()
	fucked += 1
	%AchievementPanel.achieve("orgy", "That Was Weird: Have psychic group sex with a hive mind of sentient squirrels.")
	say("The squirrels all snuggle up to you and you concentrate on their little brains and their collective mind, projecting the image of a sexy female sentient squirrel. Usually, psychic sex is easy for you, but this is tough. Still, it sort of works, and the squirrels take turns while you try not to think too much about what you're doing, and focus on reading their mind - they're " + notGuilty() + "part of the gang you're looking for.")

func squirrels_lovely():
	if vs.angry < 20 and vs.tired > 30:
		goTo(vs, "Garden")
		discover()
		say("The squirrels are pleased to see you. Two of them climb up your legs and perch on your shoulders for a while, gossiping about recent events. You take a turn out in the garden, giving you enough time to scan their little squirrel brains and determine that they're " + notGuilty() + "part of the gang you're looking for.")
	else:
		vs.tired += 5
		vs.angry -= 10
		say("The squirrels fractionally relax and chat with you in their weird squirrel chorus voice.")

func speedo():
	if vs.doneByPlayer:
		say("Prestissimo gives you a quick, friendly nod.")
	elif vs.playerTimeout > 0:
		say("Prestissimo gives you a quick nod and goes to find more coffee.")
	else:
		var t = "Prestissimo, speedster and coffee hound, is actually looking relaxed for once."
		if vs.drunk > 30 and vs.tired < 70:
			t = "Prestissimo, speedster and coffee hound, is fairly vibrating with caffeine at this point. Why does he drink the stuff?"
		ask(t, [["Yo Prestissimo, how many coffees are you on now?", speedo_coffee], ["Hey, how's it going?", speedo_hey]])

func speedo_coffee():
	if vs.angry > 30:
		say("\"Hey, not funny.\"")
	else:
		ask("\"Oh, I don't count them anymore. This space is just making everything so damn... slow, you know.\"", [["Okay, okay, but can you actually go slow?", speedo_slow]])

func speedo_slow():
	ask("\"Like what?\"", [["Like with me, in the bedroom, sweetie.", speedo_bedroom], ["Oh, I know what. I challenge you to a reverse race! Slowest across the garden wins?", speedo_race]])

func speedo_bedroom():
	fuck(vs)
	discover()
	fucked += 1
	say("\"I'm happy to give it a try\", he says. You walk - quickly - to a spare room. He takes just long enough to finish for you to read his mind. He is " + notGuilty() + "one of the gang.")

func speedo_race():
	goTo(vs, "Garden")
	ask("\"That's pretty funny. Let's try it.\"\nThe two of you go to the garden and start very slowly walking from one end to the other.", [["OK", speedo_race2]])

func speedo_race2():
	discover()
	say("Prestissimo is twitching and sweating, forcing himself to walk slower than you. You scan his mind - he is " + notGuilty() + "one of the gang - and then let him win.")

func speedo_hey():
	vs.angry -= 10
	say("\"Slowly\", he deadpans. You manage to have a quick conversation, but can't scan his brain.")
