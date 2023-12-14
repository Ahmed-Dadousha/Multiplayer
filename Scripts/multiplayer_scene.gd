extends Control

# Variables
var address: String 
var port: int
var playerData: Dictionary = {}
var server: ENetMultiplayerPeer 

# Constants
const MAX_CONNECTIONS = 20

# Signals
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal connection_faild
var connected: bool = false


func _ready():
	Global.connect("countChanged", changeCount)
	
func _process(_delta):
	if connected == true:
		if multiplayer.multiplayer_peer == null:
			Global.players.clear()
			Global.playersLoaded = 0
			connected = false

# Server Functions
func playerConnected(id):
	print("Player " + str(id) + " Connected")
	Global.playersLoaded += 1
	checkName()
	register_player.rpc_id(id, playerData)	
	player_connected.emit(id, playerData)
	
func playerDisconnected(id):
	# Remove the player data if disconnected
	Global.players.erase(id)
	Global.playersLoaded -= 1
	print("Player " + str(id) + " Disconnected")
	player_disconnected.emit(id)
	
# Client Functions
func serverConnected():
	#Global.playersLoaded += 1
	print("Server Connected!")
	checkName()
	# add player data to players array
	Global.players[multiplayer.get_unique_id()] = playerData
	connected = true

func serverDisconnected():
	print("Server Disconnected!")
	multiplayer.multiplayer_peer = null
	Global.players.clear()
	Global.playersLoaded = 0
	server_disconnected.emit()
	
	# Hide Main menu
	$Controls.visible = true
	# Show Lobby Menu
	$Lobby.visible = false

func connectionFailed():
	print("Couldn't connect!")	
	multiplayer.multiplayer_peer = null

# Called On All Devieces
@rpc("any_peer", "call_local", "reliable")
func register_player(newPlayerData):
	var newPlayerId = multiplayer.get_remote_sender_id()
	Global.players[newPlayerId] = newPlayerData


# Buttons Pressed Functions
func _on_host_pressed():
	multiplayerFunc()
	
	server = ENetMultiplayerPeer.new()

	checkPort()
		
	var err = server.create_server(port, MAX_CONNECTIONS)


	# If there an error exist
	if err != OK:
		print("Can not host! " + str(err))
		return
		
	multiplayer.multiplayer_peer = server
	print("Creating Server Successfully!! Waiting for Players........")
		
	checkName()

	Global.players[1] = playerData
	
	# Hide Main menu
	$Controls.visible = false
	# Show Lobby Menu
	$Lobby.visible = true
	
	$LanServerVrowser.setUpBroadCast($Controls/Name.text)
	
func _on_join_pressed():
	multiplayerFunc()
	
	server = ENetMultiplayerPeer.new()

	checkAddress()
	checkPort()
	
	server.create_client(address, port)
	multiplayer.multiplayer_peer = server

	# Hide Main menu
	$Controls.visible = false
	# Show Lobby Menu
	$Lobby.visible = true

func _on_data_pressed():
	printPlayersData()

func _on_data_out_pressed():
	printPlayersData()

func _on_Exit_pressed():
	disconnectFromTheServer()
	$Controls.visible = true
	$Lobby.visible = false
	
	
# My Custem Functions
func printPlayersData():
	print("\nThere Is [" + str(Global.playersLoaded) + "] Players\n")
	
	for player in Global.players.keys():
		print(Global.players[player])
		
	print("\n")

func multiplayerFunc():
	multiplayer.peer_connected.connect(playerConnected)
	multiplayer.peer_disconnected.connect(playerDisconnected)
	multiplayer.connected_to_server.connect(serverConnected)
	multiplayer.server_disconnected.connect(serverDisconnected)
	multiplayer.connection_failed.connect(connectionFailed)
	
func checkPort():
	# To check if it is null
	port = int($Controls/Port.text.strip_edges())	
	if port == 0:
		port = 8910

func checkAddress():
	# To check if it is null
	address = $Controls/IP.text.strip_edges()
	if address == "":
		address = "127.0.0.1"

func checkName():
	# To check if it is null
	if $Controls/Name.text.strip_edges() == "":
		$Controls/Name.text = "Unknown"
	playerData["name"] = $Controls/Name.text

func disconnectFromTheServer():
	multiplayer.multiplayer_peer = null
	multiplayer.peer_connected.disconnect(playerConnected)
	multiplayer.peer_disconnected.disconnect(playerDisconnected)
	multiplayer.connected_to_server.disconnect(serverConnected)
	multiplayer.server_disconnected.disconnect(serverDisconnected)
	multiplayer.connection_failed.disconnect(connectionFailed)

func changeCount():
	$Lobby/PlayersCount.text = str(Global.playersLoaded)

