extends MarginContainer
signal dead

@onready var cardDatabase = load("res://CardsDatabase.gd")
@onready var skillDatabase = preload("res://SkillsDatabase.gd")
@onready var hp_label: Label = $CardBars/LvHPRow/HP/HPLabel
@onready var atk_label: Label = $CardBars/ATKRow/ATK/ATKLabel


var default_cardName = "Footman"
var cardName
var level  = 1
var cardAtk :
	set(val):
		$CardBars/ATKRow/ATK/ATKLabel.text = "ATK: " + str( val)
		cardAtk = val
var default_hp
var cardHP : 
	set(val):
		var new_hp: int = max(0, val)
		
		hp_label.text = str(new_hp)
		# set black for default
		if new_hp == default_hp:
			hp_label.add_theme_color_override("font_color", Color(0,0,0,1)) 
			
		# set red if lower than default
		elif new_hp < default_hp:
			hp_label.add_theme_color_override("font_color", Color(1,0,0,1))
		# set green if higher than default
		elif new_hp > default_hp:
			hp_label.add_theme_color_override("font_color", Color(0,1,0,1))
		if new_hp == 0:
			dead.emit()
		
		
var skill1
var skill2
var skill3


# Called when the node enters the scene tree for the first time.
func _ready():
	if cardName == null:
		cardName = default_cardName
	load_card(cardName, level)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func take_action(action: String)-> void:
	print("starting action for card" + cardName)
	set_active()
	$ActionText.text = action
	var tween = create_tween()
	$ActionText.position=Vector2(100,225)
	$ActionText.visible=true
	tween.tween_property($ActionText, "position", Vector2(100,-100), 2.0)
	await tween.finished
	$ActionText.visible=false
	set_inactive()
	print("finishing action for card" + cardName)
func set_active():
	$Border.material.set_shader_parameter("outline_color", Color(255,0,0,1)) 
	
func set_inactive():
	
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
	default_hp = cardInfo[9] + cardInfo[12]*level
	#cardHP = default_hp
	cardHP = default_hp
	$CardBars/LvHPRow/HP/HPLabel.text = "HP: " + str(default_hp)
func get_skills() ->  Array:
	return [skill1, skill2, skill3]

