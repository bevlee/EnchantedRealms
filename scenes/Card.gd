extends Node2D

class_name Card

signal dead(location)

var cardDatabase = preload("res://CardsDatabase.gd")
var skillDatabase = preload("res://SkillsDatabase.gd")

var skillsDatabase = preload("res://SkillsDatabase.gd")
var passive_skills = skillsDatabase.PASSIVE_SKILLS

@onready var base_scene: Node2D 
# either detail, combat or hand 
var view: String

# battlefield or graveyard
var location
# player 1 or 2
var owned_by
var card_name: String 
var level = 1
var wait_timer : int :
	set(val):
		print("setting wait timer " + card_name + " to " + str(val))
		wait_timer = max(0, val)
		if view == "compact":
			base_scene.get_node("CardWait/WaitLabel").text = str(val)
			print(base_scene.get_children())
			if wait_timer == 0:
				var playableBorder = str("res://Assets/Cards/Borders/square_border_playable.png")
				base_scene.get_node("Sprites/Border").texture = load(playableBorder)
			
var card_atk :int = 100
var default_hp
var card_hp: int = 100 :
	set(val):
		var new_hp: int = max(0, val)
		card_hp = new_hp
		if view != "compact":
			var hp_label = base_scene.get_node("Attributes/HP/HPLabel")
			hp_label.text = "HP: " + str(new_hp)
			# set black for default
			print("default and self")
			print(default_hp)
			print(new_hp)
			if !default_hp:
				default_hp = 1
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
var card_type
# buffs and debuffs
var applied_effects: Dictionary
const CARD_SIZES = {
	"combat": Vector2(160,210),
	"detail": Vector2(240,320),
	"compact": Vector2(100,100),
	"sprite": Vector2(1000,1500),
	"border": Vector2(1150,1660)
}
	
func rerender():
	print("rerendering")
	
	# Set attributes correctly
	if view != "compact":
		base_scene.get_node("CardName/CardNameLabel").text = card_name
		base_scene.get_node("Attributes/HP/HPLabel").text = "HP: " + str(card_hp)
		base_scene.get_node("Attributes/Attack/AttackLabel").text = "ATK: " + str(card_atk)
		var card_texture = str("res://Assets/Cards/Units/" + card_name + ".png")
		base_scene.get_node("Sprites/Card").texture = load(card_texture)
		var card_type_icon = str("res://Assets/Cards/Type/" + card_type + ".png")
		base_scene.get_node("Attributes/Type/TypeIcon").texture = load(card_type_icon)
		
	else: 
		base_scene.get_node("CardWait/WaitLabel").text = str(wait_timer)
		if wait_timer == 0:
			var playableBorder = str("res://Assets/Cards/Borders/square_border_playable.png")
			base_scene.get_node("Sprites/Border").texture = load(playableBorder)
		else: 
			var border = str("res://Assets/Cards/Borders/square_border.png")
			base_scene.get_node("Sprites/Border").texture = load(border)
	base_scene.get_node("Sprites/Card").scale = CARD_SIZES["sprite"] / base_scene.get_node("Sprites/Card").texture.get_size()
	base_scene.get_node("Sprites/Border").scale = CARD_SIZES["border"] / base_scene.get_node("Sprites/Border").texture.get_size() 
	base_scene.scale = CARD_SIZES[view] / CARD_SIZES["border"]#Vector2(0.01, 0.01)#
	base_scene.position = CARD_SIZES[view] /2
	

func take_action(action: String) -> void:
	#print("starting action for card" + cardName)
	set_active()
	$Effects/ActionText.text = action
	var tween = create_tween()
	$Effects/ActionText.position=Vector2(0,225)
	$Effects/ActionText.visible=true
	$Effects/ActionText.modulate=Color(1,1,1,1)
	tween.tween_property($Effects/ActionText, "position", Vector2(0,-20), 1.0)
	tween.tween_property($Effects/ActionText, "modulate", Color(1,1,1,0), 0.5)
	await tween.finished
	$Effects/ActionText.visible=false
	set_inactive()
	
func set_active():
	base_scene.get_node("Sprites/Border").material.set_shader_parameter("outline_color", Color(255,0,0,1)) 
	
func set_inactive():

	base_scene.get_node("Sprites/Border").material.set_shader_parameter("outline_color", Color(0,0,0,1)) 

func load_card(card_name = self.card_name, level = self.level, view= self.view):
	print("loading card")
	set_view(view)
	var cardImg
	var cardInfo: Array = cardDatabase.DATA[card_name]
	self.card_name = card_name
	skill1 = cardInfo[4]
	skill2 = cardInfo[5]
	skill3 = cardInfo[6]
	## Set Level
	#base_scene.get_node("Attributes/HP/HPLabel").text = str(level)
	
	# Set ATK
	var atk = cardInfo[8] + cardInfo[11]*level
	card_atk = atk
	
	# Set hp
	self.default_hp = cardInfo[9] + cardInfo[12]*level
	#card_hp = default_hp
	card_hp = self.default_hp
	# Set wait timer
	wait_timer = cardInfo[3]
	card_type = cardInfo[0]
	
	if view == "compact":
		cardImg = str("res://Assets/Cards/UnitIcons/", card_name, ".png")
	else:
		cardImg = str("res://Assets/Cards/Units/", card_name, ".png")
		
		#load in the type icon
		var card_type_icon = str("res://Assets/Cards/Type/", card_type, ".png")
		
		base_scene.get_node("Attributes/Type/TypeIcon").texture = load(card_type_icon)
		
		base_scene.get_node("Attributes/Attack/AttackLabel").text = "ATK: " + str(atk)
		base_scene.get_node("Attributes/HP/HPLabel").text = "HP: " + str(default_hp)

	base_scene.get_node("Sprites/Card").texture = load(cardImg)
	rerender()
	
func get_skills() ->  Array:
	return [skill1, skill2, skill3]

func modify(source: Object, effect_type: String, hp_change: int = 0, atk_change: int = 0, add_effect: String = "", remove_effect: String = "", effect_duration = 0):
	var modified_hp_change = hp_change
	match effect_type:
		"physical":
			for skill in get_skills():
				if skill in passive_skills:
					match skill: 
						"Defender":
							modified_hp_change = modified_hp_change / 2 
						"Dodge":
							# 50% chance to dodge it
							if randf() < 0.5:
								modified_hp_change = 0
		"buff", "debuff":
			if add_effect != "":
				if add_effect in applied_effects:
					applied_effects[add_effect].duration += effect_duration
				else:
					applied_effects[add_effect] = { 
						"duration": effect_duration,
						"hp_change": hp_change,
						"atk_change": atk_change
					}
			elif remove_effect != "":
				var res = applied_effects.erase(remove_effect)
				print(remove_effect + " was removed: " + str(res))
	if modified_hp_change != 0:
		card_hp += modified_hp_change
		
func tick():
	for key in applied_effects:
		var duration = applied_effects[key]
		if duration <= 0:
			remove_effect(key)
			
func remove_effect(key: String):
	card_atk += applied_effects[key]["atk_change"]
	card_hp += applied_effects[key]["hp_change"]
	applied_effects.erase(key)

func set_view(view: String):
	match view:
		"detail":
			print("detail view")
			$DetailView.visible = true
			$CombatView.visible = false
			$CompactView.visible = false
			base_scene = $DetailView
			
		"combat":
			print("combat view")
			$DetailView.visible = false
			$CombatView.visible = true
			$CompactView.visible = false
			base_scene = $CombatView
		"compact": # hand + graveyard
			print("compact view")
			$DetailView.visible = false
			$CombatView.visible = false
			$CompactView.visible = true
			base_scene = $CompactView
	self.view = view
	print("base scene " + str(view))
	rerender()
