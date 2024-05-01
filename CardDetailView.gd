extends NinePatchRect

@onready var cardDatabase = preload("res://CardsDatabase.gd")

var cardName = "Footman"
var level = 10


# Called when the node enters the scene tree for the first time.
func _ready():
	load_card(cardName, level)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func load_card(cardName, level):
	var cardInfo = cardDatabase.DATA[cardName]
	var cardImg = str("res://Assets/Cards/Units/", cardName, ".png")

	var cardSize = $CardArea.size
	print(cardImg)
	$CardArea/Border.scale *= cardSize / $CardArea/Border.texture.get_size()
	$CardArea/Card.texture = load(cardImg)
	$CardArea/Card.scale *= cardSize / $CardArea/Card.texture.get_size()
	
	$CardArea/CardBars/TopBar/MidSection/Label.text = cardName
	
	
	#load in the type icon
	var cardType = cardInfo[0]
	var cardTypeIcon = str("res://Assets/Cards/Type/", cardType, ".png")
	print(cardTypeIcon)
	$CardArea/CardBars/TopBar/TypeIcon/TypeIconSprite.texture = load(cardTypeIcon)
	$CardArea/CardBars/TopBar/TypeIcon/TypeIconSprite.scale *= $CardArea/CardBars/TopBar/TypeIcon.custom_minimum_size / $CardArea/CardBars/TopBar/TypeIcon/TypeIconSprite.texture.get_size()
	
	# Load in the stars 
	var stars = cardInfo[1]
	for n in range(stars):
		var starImg = str("res://Assets/Cards/Misc/star.png")
		var starSprite = Sprite2D.new()
		starSprite.texture = load(starImg)
		starSprite.position = $CardArea/CardBars/TopBar/MidSection/MarginContainer/Star.get_position()
		starSprite.position.y += 10
		starSprite.position.x += 15*n + 5
		starSprite.scale *= Vector2(15, 15) / starSprite.texture.get_size()
		$CardArea/CardBars/TopBar/MidSection/MarginContainer/Star.add_child(starSprite)
	
	# Set Skills
	$CardArea/CardBars/Skill1.text = cardInfo[4] + "    "
	$CardArea/CardBars/Skill2.text = cardInfo[5] + "    "
	$CardArea/CardBars/Skill3.text = cardInfo[6] + "    "
	
	# Set Cost
	var cost = cardInfo[2]
	$CardArea/CardBars/TopBar/MarginContainer/Cost.text = str(cost)
	
	# Set Level
	$CardArea/CardBars/LvHPRow/Level/LevelLabel.text = str(level)
	
	# Set ATK
	var atk = cardInfo[8] + cardInfo[11]*level
	$CardArea/CardBars/ATKWeightRow/ATK/ATKLabel.text = "          " + str(atk)
	
	# Set Wait
	var wait = cardInfo[3]
	$CardArea/CardBars/ATKWeightRow/WaitTime/WaitLabel.text = "  " + str(wait)
	
	# Set hp
	var hp = cardInfo[9] + cardInfo[12]*level
	$CardArea/CardBars/LvHPRow/HP/HPLabel.text = "     " + str(hp)
	
