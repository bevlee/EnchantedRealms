extends MarginContainer

@onready var cardDatabase = preload("res://CardsDatabase.gd")

var cardName = "Footman"
var level = 10


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func load_card(cardName, level):
	var cardInfo = cardDatabase.DATA[cardName]
	var cardImg = str("res://Assets/Cards/Units/", cardName, ".png")

	var cardSize = size
	print(cardImg)
	$Border.scale *= cardSize / $Border.texture.get_size()
	$Card.texture = load(cardImg)
	$Card.scale *= cardSize/$Card.texture.get_size()
	
	$CardBars/TopBar/MidSection/Label.text = cardName
	
	
	#load in the type icon
	var cardType = cardInfo[0]
	var cardTypeIcon = str("res://Assets/Cards/Type/", cardType, ".png")
	print(cardTypeIcon)
	$CardBars/TopBar/TypeIcon/TypeIconSprite.texture = load(cardTypeIcon)
	$CardBars/TopBar/TypeIcon/TypeIconSprite.scale *= $CardBars/TopBar/TypeIcon.custom_minimum_size / $CardBars/TopBar/TypeIcon/TypeIconSprite.texture.get_size()
	
	# Load in the stars 
	var stars = cardInfo[1]
	for n in range(stars):
		var starImg = str("res://Assets/Cards/Misc/star.png")
		var starSprite = Sprite2D.new()
		starSprite.texture = load(starImg)
		starSprite.position = $CardBars/TopBar/MidSection/MarginContainer/Star.get_position()
		starSprite.position.y += 10
		starSprite.position.x += 15*n + 5
		starSprite.scale *= Vector2(15, 15) / starSprite.texture.get_size()
		$CardBars/TopBar/MidSection/MarginContainer/Star.add_child(starSprite)
	
	# Set Skills
	$CardBars/Skill1.text = cardInfo[4] + "    "
	$CardBars/Skill2.text = cardInfo[5] + "    "
	$CardBars/Skill3.text = cardInfo[6] + "    "
	
	# Set Cost
	var cost = cardInfo[2]
	$CardBars/TopBar/MarginContainer/Cost.text = str(cost)
	
	# Set Level
	$CardBars/LvHPRow/Level/LevelLabel.text = str(level)
	
	# Set ATK
	var atk = cardInfo[8] + cardInfo[11]*level
	$CardBars/ATKWeightRow/ATK/ATKLabel.text = "          " + str(atk)
	
	# Set Wait
	var wait = cardInfo[3]
	$CardBars/ATKWeightRow/WaitTime/WaitLabel.text = "  " + str(wait)
	
	# Set hp
	var hp = cardInfo[9] + cardInfo[12]*level
	$CardBars/LvHPRow/HP/HPLabel.text = "     " + str(hp)
	
