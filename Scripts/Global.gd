extends Node
signal countChanged()

var players: Dictionary = {}

var playersLoaded: int = 0:
	set(value):
		playersLoaded = value
		countChanged.emit()
	
var avilableRooms: Array = []

func addIP(value):
	if value not in avilableRooms:
		avilableRooms.append(value)

func removeIP(value):
	avilableRooms.erase(value)
