extends Node2D

@export var playerScene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
			# Create Players 
	for player in Global.players.keys():
		var curretntPlayer = playerScene.instantiate() as CharacterBody2D
		curretntPlayer.name = str(player)
		curretntPlayer.modulate = Global.players[player]["color"]
		curretntPlayer.setName(Global.players[player]["name"])
		add_child(curretntPlayer)	
	
		curretntPlayer.global_position = Vector2(randi_range(10, 1100), randi_range(10, 600))
				
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

