extends MarginContainer

@onready var cardDatabase = load("res://CardsDatabase.gd")

var cardName = "Footman"
var level  = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	


func load_card(cardName,  level):
	var cardInfo = cardDatabase.DATA[cardName]
	var cardImg = str("res://Assets/Cards/Units/", cardName, ".png")

	var cardSize = size
	print(cardImg)
	$Border.scale *= cardSize / $Border.texture.get_size()
	$Card.texture = load(cardImg)
	$Card.scale *= cardSize/$Card.texture.get_size()
	
	
	#load in the type icon
	var cardType = cardInfo[0]
	var cardTypeIcon = str("res://Assets/Cards/Type/", cardType, ".png")
	print(cardTypeIcon)
	$CardBars/TopBar/TypeIcon/TypeIconSprite.texture = load(cardTypeIcon)
	$CardBars/TopBar/TypeIcon/TypeIconSprite.scale *= $CardBars/TopBar/TypeIcon.custom_minimum_size / $CardBars/TopBar/TypeIcon/TypeIconSprite.texture.get_size()
	
	# Set Level
	$CardBars/LvHPRow/Level/LevelLabel.text = str(level)
	
	# Set ATK
	var atk = cardInfo[8] + cardInfo[11]*level
	$CardBars/ATKRow/ATK/ATKLabel.text = "ATK: " + str(atk)
	
	# Set hp
	var hp = cardInfo[9] + cardInfo[12]*level
	$CardBars/LvHPRow/HP/HPLabel.text = "HP: " + str(hp)
	

