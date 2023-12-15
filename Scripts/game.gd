extends Node2D

@export var playerScene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	
	NetworkManger.connect("player_disconnected", playerDisconnected)

	# Create Players 
	for player in Global.players.keys():
		var curretntPlayer = playerScene.instantiate() as CharacterBody2D
		curretntPlayer.name = str(player)
		curretntPlayer.modulate = Global.players[player]["color"]
		curretntPlayer.setName(Global.players[player]["name"])
		add_child(curretntPlayer)	
		
		for spawn in get_tree().get_nodes_in_group("pos"):
			if spawn.name == str(Global.players[player]["index"]):
				curretntPlayer.global_position = spawn.global_position
				
func playerDisconnected(id):
	get_node(str(id)).queue_free()

	

