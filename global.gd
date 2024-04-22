extends Node

## Manage user data (deck, cardlist, currency)

var playerStateMachine = {
	"deck" = ["Footman", "Footman", "Archer", "Archer"],
	"cardList" = [],
}
func _ready():
	Global.playerStateMachine = self.playerStateMachine
