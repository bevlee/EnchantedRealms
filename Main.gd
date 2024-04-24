extends Node2D


var mainMenu
@export var combatScene: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	$MainMenuCanvas.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	


func _on_main_menu_canvas_start_battle():
	print("loading")
	$MainMenuCanvas.hide()
	
	#var combatScene = load("res://combat_ui.tscn")
	#var combat = combatScene.instantiate()
	#combat.show()
	#add_child(combat)
	$CombatUI.start()
