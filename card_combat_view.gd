extends MarginContainer

@onready var cardDatabase = load("res://CardsDatabase.gd")
@onready var skillDatabase = preload("res://SkillsDatabase.gd")
var default_cardName = "Footman"
var cardName
var level  = 1
var cardAtk
var cardHP
var skill1
var skill2
var skill3
# Called when the node enters the scene tree for the first time.
func _ready():
	if cardName == null:
		cardName = default_cardName
	load_card(cardName, level)
	
	set_active()
	await get_tree().create_timer(2).timeout
	set_inactive()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func set_active():
	print("active")
	$Border.material.set_shader_parameter("outline_color", Color(255,0,0,1)) 
	
func set_inactive():
	
	print("inactive")
	$Border.material.set_shader_parameter("outline_color", Color(0,0,0,1)) 

func load_card(cardName,  level):
	var cardInfo = cardDatabase.DATA[cardName]
	skill1 = cardInfo[4]
	skill2 = cardInfo[5]
	skill3 = cardInfo[6]
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
	cardAtk = atk
	
	# Set hp
	var hp = cardInfo[9] + cardInfo[12]*level
	$CardBars/LvHPRow/HP/HPLabel.text = "HP: " + str(hp)
	cardHP = hp
func get_skills() ->  Array:
	return [skill1, skill2, skill3]

