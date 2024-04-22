extends CanvasLayer

var mainMenu
var combatUI = preload("res://combat_ui.tscn")


func _on_battle_button_pressed():
	
	mainMenu = $MainMenuCanvas
	mainMenu.free()
	get_tree().root.add_child(combatUI)
