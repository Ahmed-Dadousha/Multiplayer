extends Control

# Variables
var address: String 
var port: int
var playerData: Dictionary = {}
var players: Dictionary = {}
var server: ENetMultiplayerPeer 
var players_loaded: int = 0

# Constants
const MAX_CONNECTIONS = 20

# Signals
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected


# Server Functions
func playerConnected(id):
	print("Player " + str(id) + " Connected")
	players_loaded += 1
	# To check if it is null
	if $Controls/Name.text.strip_edges() == "":
		$Controls/Name.text = "Unknown"
		
	playerData["name"] = $Controls/Name.text

func playerDisconnected(id):
	# Remove the player data if disconnected
	players.erase(id)
	players_loaded -= 1
	print("Player " + str(id) + " Disconnected")
	
# Client Functions
func serverConnected():
	players_loaded += 1
	print("Server Connected!")
	# To check if it is null
	if $Controls/Name.text.strip_edges() == "":
		$Controls/Name.text = "Unknown"
		
	playerData["name"] = $Controls/Name.text
	
	# add player data to players array
	players[multiplayer.get_unique_id()] = playerData

func serverDisconnected():
	print("Server Disconnected!")
	
	
# Called From Clients 
@rpc("any_peer", "call_local") 
func startGame():
	var scene = preload("res://Scenes/player.tscn").instantiate()
	#scene.name = st
	get_tree().root.add_child(scene)
	self.hide()

# Data Transfer Is Slow But Safe
#@rpc("any_peer", "reliable")
#func register_player(new_player_info):
	#pass

# Buttons Pressed Signals
func _on_host_pressed():
	multiplayerFunc()
	
	server = ENetMultiplayerPeer.new()
	port = int($Controls/Port.text.strip_edges())
	
	if port == 0:
		port = 8910
		
	var err = server.create_server(port, MAX_CONNECTIONS)
	
	# If there an error exit
	if err:
		print("Can not host!")
		return
		
	multiplayer.multiplayer_peer = server
	print("Creating Server Successfully!! Waiting for Players........")
	
	# To check if it is null
	if $Controls/Name.text.strip_edges() == "":
		$Controls/Name.text = "Unknown"
		
	playerData["name"] = $Controls/Name.text
	
	# add player data to players array
	players[1] = playerData
	
	
	players_loaded += 1

func _on_join_pressed():
	multiplayerFunc()
	server = ENetMultiplayerPeer.new()
	port = int($Controls/Port.text.strip_edges())
	address = $Controls/IP.text.strip_edges()
	
	if port == 0:
		port = 8910
	if address == "":
		address = "127.0.0.1"
	
	server.create_client(address, port)
	multiplayer.multiplayer_peer = server
	
func _on_start_game_pressed():
	# The game will not start on the host
	if !multiplayer.is_server():
		# The game will start on current peer only
		startGame.rpc_id(multiplayer.get_unique_id())
		#startGame.rpc()
	else:
		print("This is the server can not create player!")
func _on_disconnect_pressed():
	multiplayer.multiplayer_peer = null

func _on_print_data_pressed():
	for player in players:
		print(player)
	print(players_loaded)

# My Custem Functions
func multiplayerFunc():
	multiplayer.peer_connected.connect(playerConnected)
	multiplayer.peer_disconnected.connect(playerDisconnected)
	multiplayer.connected_to_server.connect(serverConnected)
	multiplayer.server_disconnected.connect(serverDisconnected)

