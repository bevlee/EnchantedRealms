extends MarginContainer

signal view_card_detail(cardName, level)
signal ready_card(cardName, level, handPosition)
signal unready_card(cardName, level, handPosition)
var shader_material
enum cardStates {
	Preparing, Ready, Played,
}
@onready var cardDatabase = preload("res://CardsDatabase.gd")
var handPosition = null
var cardName = 'Footman'
var level = 1
var default_wait_timer = 4
var current_wait_timer
var state = cardStates.Preparing


# Called when the node enters the scene tree for the first time.
func _ready():
	load_card(cardName, level)
	# Create a ShaderMaterial with your shader
	shader_material = ShaderMaterial.new()
	shader_material.shader = load("res://card_hand_view.gdshader")
	
	# Assign the ShaderMaterial to this specific instance of the Sprite2D node
	$Card.set_material(shader_material)

	# Optionally, set shader parameters if needed
	#shader_material.set_shader_parameter("parameter_name", value)

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
	default_wait_timer = cardInfo[3]
	$Rows/LvHPRow/Wait/WaitLabel.text = "  " + str(default_wait_timer)
	current_wait_timer = default_wait_timer
	
	
	# Set ATK
	var atk = cardInfo[8] + cardInfo[11]*level
	$Rows/ATKRow/ATK/ATKLabel.text = "ATK: " + str(atk)
	
	# Set hp
	var hp = cardInfo[9] + cardInfo[12]*level
	$Rows/LvHPRow/HP/HPLabel.text = "HP: " + str(hp)
	
func process_hand_turn():
	current_wait_timer = int($Rows/LvHPRow/Wait/WaitLabel.text)
	if (current_wait_timer <= 1):
		current_wait_timer = 0
		$Rows/LvHPRow/Wait/WaitLabel.text = "0"
		var playableBorder = str("res://Assets/Cards/Borders/square_border_playable.png")
		$Border.texture = load(playableBorder)
		state = cardStates.Ready
	else: 
		current_wait_timer = current_wait_timer - 1
		$Rows/LvHPRow/Wait/WaitLabel.text = str(current_wait_timer)
		

func _on_interact_pressed():
	#match state:
		#cardStates.Ready:
			#ready_card.emit()
		#cardStates.Played:
			#unready_card.emit()
		
	print("clicked", cardName, handPosition)
	if state == cardStates.Ready:
		ready_card.emit(cardName, level, handPosition)
		state = cardStates.Played
		shader_material.set_shader_parameter("active", state == cardStates.Played)
		
	elif state == cardStates.Played:
		unready_card.emit(cardName, level, handPosition)
		state = cardStates.Ready
		shader_material.set_shader_parameter("active", state == cardStates.Played)
	else:
		view_card_detail.emit(cardName, level)
