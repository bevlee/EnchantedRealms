extends MarginContainer

signal view_card_detail(cardName, level)
signal ready_card(cardName, level, handPosition)
signal unready_card(cardName, level, handPosition)

enum cardStates {
	Preparing, Ready, Played,
}
@onready var cardDatabase = preload("res://CardsDatabase.gd")
var handPosition = null
var cardName = 'Footman'
var level = 1
var wait = 4

var state = cardStates.Preparing


# Called when the node enters the scene tree for the first time.
func _ready():
	load_card(cardName, level)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	


func load_card(cardName, level):
	var cardInfo = cardDatabase.DATA[cardName]
	var cardImg = str("res://Assets/Cards/UnitIcons/", cardName, ".png")

	var cardSize = size
	$Border.scale *= cardSize / $Border.texture.get_size()
	$Card.texture = load(cardImg)
	$Card.scale *= cardSize/$Card.texture.get_size()
	
	
	# Load in the stars 
	var stars = cardInfo[1]
	for n in range(stars):
		var starImg = str("res://Assets/Cards/Misc/star.png")
		var starSprite = Sprite2D.new()
		starSprite.texture = load(starImg)
		starSprite.position = $Rows/Stars.get_position()
		starSprite.position.y += 15
		starSprite.position.x += 165 - 15*n
		starSprite.scale *= Vector2(15, 15) / starSprite.texture.get_size()
		$Rows/Stars.add_child(starSprite)
		
		
	# Set Wait
	var wait = cardInfo[3]
	$Rows/LvHPRow/Wait/WaitLabel.text = "  " + str(wait)
	
	
	# Set ATK
	var atk = cardInfo[8] + cardInfo[11]*level
	$Rows/ATKRow/ATK/ATKLabel.text = "ATK: " + str(atk)
	
	# Set hp
	var hp = cardInfo[9] + cardInfo[12]*level
	$Rows/LvHPRow/HP/HPLabel.text = "HP: " + str(hp)
	
func process_turn():
	var currentWait = int($Rows/LvHPRow/Wait/WaitLabel.text)
	if (currentWait != 0):
		$Rows/LvHPRow/Wait/WaitLabel.text = str(currentWait - 1)
	else: 
		var playableBorder = str("res://Assets/Cards/Borders/square_border_playable.png")
		$Border.texture = load(playableBorder)
		state = cardStates.Ready
		
		


func _on_interact_pressed():
	#match state:
		#cardStates.Ready:
			#ready_card.emit()
		#cardStates.Played:
			#unready_card.emit()
		
	print("clicked", cardName, handPosition)
	if state == cardStates.Ready:
		ready_card.emit(cardName, level, handPosition)
	elif state == cardStates.Played:
		unready_card.emit(cardName, level, handPosition)
	else:
		view_card_detail.emit(cardName, level)

