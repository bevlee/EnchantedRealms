extends Node2D

signal nextTurn
signal backToMainMenu
const handCardSize = Vector2(100,100)
const detailCardSize = Vector2(250,350)
const combatCardSize = Vector2(160,220)
var handCardBase = preload("res://card_hand_view.tscn")
var detailCardBase = preload("res://card_detail_view.tscn")
var combatCardBase = preload("res://card_combat_view.tscn")
var skillsDatabase = preload("res://SkillsDatabase.gd")
var card = preload("res://scenes/card.tscn")
var active_skills = skillsDatabase.ACTIVE_SKILLS

var detailedCardView

var active_player = 0
var players = [
	#Player 1
	{
		"hero_hp": 9000,
		"queued_cards": [],
		"deck": [],
		"hand": []
	},
	#Player 2
	{
		"hero_hp": 9000,
		"queued_cards": [],
		"deck": [],
		"hand": []
	}
]
var battlefield_cards = [
	#Player 1
	[],
	#Player 2
	[]
]

# general settings
var auto_combat = true
var turn = 0
const MAX_HAND_SIZE = 5
const MAX_TURN_COUNT = 1000

#track the current
enum phases {
	# all hand cards decrease their wait timer by 1
	pre_draw_phase, 
	# the player draws a card if the deck is not empty
	draw_phase, 
	# cards with 0 CD will enter the battlefield in FIFO order
	play_card_phase, 
	# each card on the battlefield
	action_phase,
	# final phase
	end_phase
}
var state
var currentCardPosition = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#var card
	#var cardSkills

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
	
func play_cards():
	var active_card
	var cards_played = 0
	var queued_cards = players[active_player]["queued_cards"]
	for i in range(len(queued_cards)):
		active_card = queued_cards.pop_front()
		players[active_player]["hand"].erase(active_card)
		move_card(active_card, "player" + str(active_player) + "_hand", "player" + str(active_player) + "_battlefield")
		
		var player_cards_path = "MainArea/BattleField/Player" + str(active_player) + "BattleArea/Cards"
		var player_battlefield_cards_parent_scene = get_node(player_cards_path)
		# base position for cards on battlefield for this player
		active_card.position = Vector2(0,0)
		var player_battlefield_cards = battlefield_cards[active_player]
		active_card.position.x += 172 * (len(player_battlefield_cards) - 1)
		cards_played += 1
		
# needs to be fixed, we dont want updates when cards go to graveyard until end of turn
func rerender(location):
	if location == "player0_hand":
		var hand_cards = $MainArea/Player0Hand/Cards
		for i in range(len(players[0]["hand"])):
			players[0]["hand"][i].position = hand_cards.position
			players[0]["hand"][i].position.x += 100*i
	
	if location == "player1_hand":
		var hand_cards = $MainArea/Player1Hand/Cards
		for i in range(len(players[1]["hand"])):
			players[1]["hand"][i].position = hand_cards.position
			players[1]["hand"][i].position.x += 100*i
			
	if location == "player0_battlefield":
		var all_cards = $MainArea/BattleField/Player0BattleArea/Cards
		for i in range(len(battlefield_cards[0])):
			battlefield_cards[0][i].position = all_cards.position
			battlefield_cards[0][i].position.x += 172*i
	if location == "player1_battlefield":
		var all_cards = $MainArea/BattleField/Player1BattleArea/Cards
		for i in range(len(battlefield_cards[1])):
			battlefield_cards[1][i].position = all_cards.position
			battlefield_cards[1][i].position.x += 172*i

func move_card(card: Object, src: String, destination: String):
	print("moving card" + card.card_name + "from " + src + " to " + destination)
	
	if (src == "player0_hand"):
		# remove card scene from hand and move it to battlefield
		var src_parent = get_node("MainArea/Player0Hand/Cards")
		src_parent.remove_child(card)
		var hand_scene = get_node("MainArea/Player0Hand/Cards")
		
	if (src == "player1_hand"):
		var src_parent = get_node("MainArea/Player1Hand/Cards")
		src_parent.remove_child(card)
		var hand_scene = get_node("MainArea/Player1Hand/Cards")
		
	if (src == "player0_battlefield"):
		battlefield_cards[0]["hand"].remove_at(position)
	if (src == "player1_battlefield"):
		battlefield_cards[1]["hand"].remove_at(position)
	var destination_parent
	if (destination == "player0_battlefield"):
		destination_parent = get_node("MainArea/BattleField/Player0BattleArea/Cards")
		destination_parent.add_child(card)
		card.dead.connect(move_card, card, card.position, card.owner)
		card.set_view("combat")
		battlefield_cards[0].append(card)
	if (destination == "player1_battlefield"):
		destination_parent = get_node("MainArea/BattleField/Player1BattleArea/Cards")
		destination_parent.add_child(card)
		card.set_view("combat")
		battlefield_cards[1].append(card)
		
		
	rerender(src)
	rerender(destination)

# both players have their card timers decreased every turn
func pre_draw_phase():
	var player0_cards_scene : Sprite2D = get_node("MainArea/Player0Hand/Cards")
	var player1_cards_scene : Sprite2D = get_node("MainArea/Player1Hand/Cards")
	var hand_cards = player0_cards_scene.get_children() + player1_cards_scene.get_children()
	# decrease timer of cards in hand
	for i in range(len(hand_cards)):
		hand_cards[i].wait_timer -= 1

func draw_phase():
	var player_hand = players[active_player]["hand"]
	var player_cards_scene : Sprite2D = get_node("MainArea/Player" + str(active_player) + "Hand/Cards") 
	if (len(player_hand) < MAX_HAND_SIZE):
		var nextCard = draw(players[active_player]["deck"])
		
		if nextCard != null:
			var newCard = card.instantiate()
			newCard.load_card(nextCard, 2, "compact")
			#newCard.handPosition = len(player_hand)
			# put the new card in the next hand position
			newCard.position = player_cards_scene.position
			newCard.position.x += 100*(len(player_hand))
			#scale the image to fit the hand area
			#newCard.scale *= handCardSize / newCard.size
			
			player_cards_scene.add_child(newCard)
			#newCard.ready_card.connect(_on_ready_card)
			#newCard.unready_card.connect(_on_unready_card)
			#newCard.view_card_detail.connect(_on_view_card_detail)
			player_hand.push_back(newCard)
			
func play_card_phase():
	var hand_cards : Array[Node] = get_node("MainArea/Player" + str(active_player) + "Hand/Cards").get_children()
	if (auto_combat):
		for i in range(len(hand_cards)):
			if hand_cards[i].wait_timer == 0:
				players[active_player]["queued_cards"].append(hand_cards[i])
	
	if len(players[active_player]["queued_cards"]) > 0:
		play_cards()

func action_phase():
	state = phases.action_phase
	var card: Object
	var cardSkills: Array
	var player_battlefield_cards = battlefield_cards[active_player]
	for currentCardPosition in range(player_battlefield_cards.size()):
		card = player_battlefield_cards[currentCardPosition]
		# perform card skill
		cardSkills = card.get_skills()
		for skill in cardSkills:
			if skill in active_skills:
				await use_skill(card, currentCardPosition, skill)
		
		## TODO implement skills for active (look into reaction/defensive later)
		await basic_attack(card, currentCardPosition)
		await card.take_action("basic attack")
		
	state = phases.end_phase
	
	
func basic_attack(card, position):
	var other_player = 1 - active_player
	if has_opposing_card(position):
		modify_entity(card, battlefield_cards[other_player][position], "physical", -card.card_atk, 0, "", "", 0)
	else:
		var other_player_hp_label : Label = get_node("MainArea/Player" + str(other_player) + "Profile/HPLabel")
		players[other_player]["hero_hp"] -= card.card_atk
		other_player_hp_label.text = "HP: " + str(players[other_player]["hero_hp"])
	
func use_skill(card, card_position: int, skill_name: String) -> void:
	match skill_name:
		"Snipe_2":
			var opponent_id = 1 - active_player
			var opponent_battlefield_cards = battlefield_cards[opponent_id]
			var card_with_lowest_hp
			var lowest_hp: int = 100000
			
			for opponent_card in opponent_battlefield_cards:
				if opponent_card.card_hp < lowest_hp:
					lowest_hp = opponent_card.card_hp
					card_with_lowest_hp = opponent_card
			modify_entity(card, card_with_lowest_hp, "physical", -200, 0, "", "")
		"Berserk":
			card.modify(card, "buff", 0, card.card_atk, "", "", 1)
			
# turns end in the end phase of each players action
func modify_entity(source: Object, target: Object, effect_type: String, hp_change: int = 0, atk_change: int = 0, add_effect: String = "", remove_effect: String = "", effect_duration=0):
	# if the target is a card
	if target is Card:
		target.modify(source, effect_type, hp_change, atk_change, add_effect, remove_effect)
	
func end_phase():
	$NextTurnButton.disabled = false
	for card in battlefield_cards[0] + battlefield_cards[1]:
		card.tick()
	
func has_opposing_card(position):
	var opponent_id = 1 - active_player
	var opponent_battlefield_cards = battlefield_cards[opponent_id]
	if len(opponent_battlefield_cards) > position and opponent_battlefield_cards[position] is Object:
		return true
	return false
	
func _on_next_turn_button_pressed():
	$NextTurnButton.disabled = true
	turn = turn + 1
	$TurnLabel.text = "Turn: " + str(turn)
	
	# Player 1 is 0, Player 2 is 1
	active_player = (turn + 1) % 2
	if turn %2 ==0:
		$TurnPointer.rotation = 0
	else:
		$TurnPointer.rotation_degrees = 180
	pre_draw_phase()
	draw_phase()
	play_card_phase()
	await action_phase()
	end_phase()


func _on_view_card_detail(card_name, level):
	detailedCardView = card.instantiate()
	detailedCardView.card_name = card_name
	detailedCardView.level = level
	detailedCardView.view = "detail"
	#detailedCardView.position = Vector2(1000,500)
	#print(detailedCardView.position)
	#detailedCardView.scale *= 2#detailCardSize / detailedCardView.size
	add_child(detailedCardView)
	detailedCardView.show()
	var exit_button = detailedCardView.get_node("Background")
	exit_button.leave_detailed_view.connect(_on_exit_view_card_detail)
	#players[active_player]["hand"].push_back(detailedCardView)
	
func _on_exit_view_card_detail():
	detailedCardView.queue_free()

func start():
	print("combatStarting")
	show() 
	players[active_player]["deck"] = Global.playerStateMachine.deck.duplicate(true)	
	#players[active_player]["deck"] = ["Footman"]
	players[active_player+ 1]["deck"] = Global.playerStateMachine2.deck.duplicate(true)
	shuffle_deck(players[active_player]["deck"])

func finish():
	hide()

func _on_back_button_pressed():
	backToMainMenu.emit()
