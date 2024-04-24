extends CanvasLayer


var mainMenu
@export var combatScene: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	print("loading main menu")
	print($CombatUI)
	#CombatUI.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
func _on_battle_button_pressed():
	print("loading")
	mainMenu = $"../MainMenuCanvas"
	hide()
	
	var combat = combatScene.instantiate()