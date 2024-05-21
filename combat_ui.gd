extends Node2D

signal nextTurn
signal backToMainMenu
const handCardSize = Vector2(100,100)
const detailCardSize = Vector2(250,350)
const combatCardSize = Vector2(160,220)
var handCardBase = preload("res://card_hand_view.tscn")
var detailCardBase = preload("res://card_detail_view.tscn")
var combatCardBase = preload("res://card_combat_view.tscn")
var detailedCardView
var oppoenentDeck = []
var opponentHand = []
var opponentQueuedCards = []
var oppoenentHeroHP = 9000
var playerHeroHP = 9000
var playerQueuedCards = []
var playerDeck = []
var playerHand = []
var player_battlefield_cards = []
var opponent_battlefield_cards = []
var auto_combat = true
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
	
	
func playCards():
	var card_pos
	var card
	var cards_played = 0
	while len(playerQueuedCards) > 0:
		print("playerqueued cards are: ")
		print(playerQueuedCards)
		card_pos = playerQueuedCards.pop_front()
		card = playerHand[card_pos]
		move_card(card.cardName, "hand", "battlefield", card_pos)
		
		
		var combat_card = combatCardBase.instantiate()
		combat_card.cardName = card.cardName
		combat_card.level = card.level
		
		combat_card.position = $NinePatchRect/BattleField/Player1Area/Cards.position
		combat_card.position.x += 160 * len(player_battlefield_cards)
		
		combat_card.scale *= combatCardSize / combat_card.size
		
		$NinePatchRect/BattleField/Player1Area/Cards.add_child(combat_card)
		player_battlefield_cards.push_back(combat_card)
		var playerbattlefieldCardNames = []
		for battlefield_card in player_battlefield_cards:
			playerbattlefieldCardNames.append(battlefield_card.cardName)
		print("battle cards: ")
		print( playerbattlefieldCardNames)
		cards_played += 1
		
	
func rerender(location):
	if location == "hand":
		for i in range(len(playerHand)):
			playerHand[i].position = $NinePatchRect/Player1Hand/Cards.position
			playerHand[i].position.x += 100*i
			


func update_queued_cards(position):	
	for i in range(len(playerQueuedCards)):
		if playerQueuedCards[i] > position:
			playerQueuedCards[i] -= 1 

func move_card(cardName, location, destination, position):
	print("moving card" + cardName + "from " + location +  "in position " + str(position) + " to " + destination)
	if (location == "hand"):
		playerHand[position].queue_free()
		playerHand.remove_at(position)
		update_queued_cards(position)
	print("player hand after moving")
	print(playerHand)
	
	rerender(location)
	rerender(destination)
	
func pre_draw_phase():
	turn = turn + 1
	$TurnLabel.text = "Turn: " + str(turn)
	var handCards = $NinePatchRect/Player1Hand/Cards.get_children()
	#decrease timer of cards in hand
	for i in range(len(handCards)):
		handCards[i].process_hand_turn()
	

func draw_phase():
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
			
func play_card_phase():
	var handCards = $NinePatchRect/Player1Hand/Cards.get_children()
	if (auto_combat):
		for i in range(len(handCards)):
			if handCards[i].current_wait_timer == 0:
				playerQueuedCards.append(i)
				print(handCards[i].cardName)
	
	if len(playerQueuedCards) > 0:
		playCards()

func action_phase():
	for i in len(player_battlefield_cards):
		var card = player_battlefield_cards[i]
		# perform card skill
		var cardSkills = card.get_skills()
		
		#attack
		basic_attack(card, i)
func basic_attack(card, position):
	if has_opposing_card(position):
		opponent_battlefield_cards[position].cardHP -= card.cardAtk
	else:
		oppoenentHeroHP -= card.cardAtk
	#dp something
func has_opposing_card(position):
	if len(opponent_battlefield_cards) > position and opponent_battlefield_cards[position] != "":
		return true
	return false
func _on_next_turn_button_pressed():
	pre_draw_phase()
	draw_phase()
	play_card_phase()
	action_phase()
	#var playerHandCardNames = []
	#for card in playerHand:
		#playerHandCardNames.append(card.cardName)
	#print("hand cards: ")
	#print( playerHandCardNames)


func _on_view_card_detail(cardName, level):
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
	detailedCardView.queue_free()


func _on_unready_card(cardName, level, handPosition):
	var position
	for i in range(len(playerQueuedCards)):
		if (playerQueuedCards[i] == handPosition):
			position = i
	playerQueuedCards.remove_at(position)
	
func _on_ready_card(cardName, level, handPosition):
	playerQueuedCards.append(handPosition)

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
