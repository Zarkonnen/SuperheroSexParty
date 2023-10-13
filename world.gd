extends Node

func _ready():
	var children = $/root/Root/Characters.get_children()
	children.shuffle()
	children[0].guilty = true
	children[1].guilty = true
	children[2].guilty = true

var social_seats = []
var sex_seats = []

func getFreeSocialSeat():
	return Util.pick_random(social_seats.filter(func(s): return s.occupants.is_empty()))
	
	
func getFreeSexSeat():
	return Util.pick_random(sex_seats.filter(func(s): return s.occupants.is_empty()))
