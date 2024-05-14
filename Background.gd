extends ColorRect
signal leave_detailed_view
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.is_action("leftclick"):
			#print("Left mouse button clicked at position:", event.position)
			leave_detailed_view.emit()
