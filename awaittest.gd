extends Node2D

var main
func _ready():
	#print("testing")
	#var count = 0
	#for i in range(1000):
		#if randf() < 0.5:
			#count += 1
	#var a = [1,2,3,4]
	#var b = a.pop_front() + a.pop_front()
	#print(a)
	#print(b)
	#print("total count was " + str(count))
	
	var card = load("res://scenes/card.tscn").instantiate()
	
	add_child(card)
	card.load_card("Archer", 1, "combat")
	card.load_card("Footman", 1, "combat")
	var card2 = load("res://scenes/card.tscn").instantiate()
	card2.position.x = global_position.x + 160
	add_child(card2)
	card2.load_card("Footman", 1, "combat")
	main = card
func _on_button_pressed():
	$Button.disabled = true
	#var labels = $Labels.get_children()
	#for label in labels:
		#label.modulate = Color(1,0,0,1)
		#await get_tree().create_timer(1.0).timeout
	var form = ["compact", "combat", "detail"]
	var card = ["Archer", "Footman"]
	var i = randi_range(0,2)
	var j = randi_range(0,1)
		
	main.load_card(card[j], 1, form[i])
	
	$Button.disabled = false
