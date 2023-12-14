extends Node
signal countChanged()

var players = {}

var playersLoaded: int = 0:
	set(value):
		playersLoaded = value
		countChanged.emit()
		
