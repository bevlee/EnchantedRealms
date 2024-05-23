extends Node
#Controls the player hand, deck and battlefield
class_name Player

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
var hand = []
var deck = []
var battlefield = []

func draw_card():
	if deck.size() > 0:
		var card = deck.pop_back()
		hand.append(card)
	else:
		print("Deck is empty")

func play_card(index):
	if index >= 0 and index < hand.size():
		var card = hand[index]
		hand.remove_at(index)
		battlefield.append(card)
	else:
		print("Invalid card index")
