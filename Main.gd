extends Node2D


var mainMenu

var combat_scene
var combat_ui
# Called when the node enters the scene tree for the first time.
func _ready():
	$MainMenuCanvas.show()
	#back_button.connect("backToMainMenu", "_on_combat_ui_back_to_main_menu")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	


func _on_main_menu_canvas_start_battle():
	$MainMenuCanvas.hide()
	
	#var combatScene = load("res://combat_ui.tscn")
	#var combat = combatScene.instantiate()
	#combat.show()
	#add_child(combat)
	start_battle()

func start_battle():
	combat_scene = load("res://combat_ui.tscn")
	combat_ui = combat_scene.instantiate()
	add_child(combat_ui) 
	print(combat_ui)
	combat_ui.backToMainMenu.connect(_on_combat_ui_back_to_main_menu)
	#Connect a signal from a node within the instantiated scene
	var back_button = combat_ui.get_node("BackButton")
	
	combat_ui.start()
	
func _on_combat_ui_back_to_main_menu():
	print("back to main menu")
	remove_child(combat_ui)
	combat_ui.queue_free()
	combat_ui = combat_scene.instantiate()
	add_child(combat_ui)
	
	$MainMenuCanvas.show()
