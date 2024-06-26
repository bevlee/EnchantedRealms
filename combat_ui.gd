extends Node2D

signal nextTurn
signal backToMainMenu
const handCardSize = Vector2(100,100)
const detailCardSize = Vector2(250,350)
var handCardBase = preload("res://card_hand_view.tscn")
var detailCardBase = preload("res://card_detail_view.tscn")
var detailedCardView
var oppoenentDeck = []
var opponentHand = []

var playerDeck = []
var playerHand = []

var turn = 0
const MAX_HAND_SIZE = 5
const MAX_TURN_COUNT = 1000
# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	pass
		
		
			
func draw(cardList):
	return cardList.pop_front()
	
func shuffle_deck(cardList):
	for i in range(len(cardList) - 1, 0, -1):
		var randomIndex = randi() % i
		var tempValue = cardList[randomIndex]
		cardList[randomIndex] = cardList[i]
		cardList[i] = tempValue
	
	

func process_turn():
	turn = turn + 1
	$TurnLabel.text = "Turn: " + str(turn)
	var handCards = $NinePatchRect/Player1Hand/Cards.get_children()
	for i in range(len(handCards)):
		handCards[i].process_turn()
	
	
func _on_button_pressed():
	if (len(playerHand) < MAX_HAND_SIZE):
		var nextCard = draw(playerDeck)
		
		if nextCard != null:
			
			var newCard = handCardBase.instantiate()
			newCard.cardName = nextCard
			newCard.level = 2
			
			newCard.handPosition = len(playerHand)
			newCard.position = $NinePatchRect/Player1Hand/Cards.position
			newCard.position.x += 100*(len(playerHand))
			newCard.scale *= handCardSize / newCard.size
			#newCard.loadCard(nextCard, 2)
			$NinePatchRect/Player1Hand/Cards.add_child(newCard)
			
			newCard.ready_card.connect(_on_ready_card)
			newCard.unready_card.connect(_on_unready_card)
			newCard.view_card_detail.connect(_on_view_card_detail)
			playerHand.push_back(newCard)
	process_turn()


func _on_view_card_detail(cardName, level):
	print("we viewing the deets")
	detailedCardView = detailCardBase.instantiate()
	detailedCardView.cardName = cardName
	detailedCardView.level = level
	#detailedCardView.position = Vector2(1000,500)
	#print(detailedCardView.position)
	#detailedCardView.scale *= 2#detailCardSize / detailedCardView.size
	add_child(detailedCardView)
	detailedCardView.show()
	var exit_button = detailedCardView.get_node("Background")
	exit_button.leave_detailed_view.connect(_on_exit_view_card_detail)
	#playerHand.push_back(detailedCardView)
	
func _on_exit_view_card_detail():
	print("we not viewing the deets anymore")
	detailedCardView.queue_free()


func _on_unready_card(cardName, level, handPosition):
	print("readying")


func _on_ready_card(cardName, level, handPosition):
	print("unreadying")

func start():
	print("combatStarting")
	show() 
	playerDeck = Global.playerStateMachine.deck.duplicate(true)
	shuffle_deck(playerDeck)
	print(playerDeck)

func finish():
	hide()


func _on_back_button_pressed():
	backToMainMenu.emit()
