extends Control

# Variables
var address: String 
var port: int = 8910
var playerData: Dictionary = {"name" : "", "color": Color(0,0,0,0)}
var server: ENetMultiplayerPeer 

# Export Variables
@export var gameScene: PackedScene

# Constants
const MAX_CONNECTIONS = 20

# Signals
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal connection_faild
var connected: bool = false

# Node Functions

func _ready():
	Global.connect("countChanged", changeCount)

func _process(_delta):
	if connected == true:
		if multiplayer.multiplayer_peer == null:
			Global.players.clear()
			Global.playersLoaded = 0
			connected = false

# Multiplayer Functions

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
	Global.playersLoaded += 1
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
	#
	$LanServerVrowser.visible = true

func connectionFailed():
	print("Couldn't connect!")	
	multiplayer.multiplayer_peer = null


# RPC Functions
@rpc("any_peer", "call_local", "reliable")
func register_player(newPlayerData):
	var newPlayerId = multiplayer.get_remote_sender_id()
	Global.players[newPlayerId] = newPlayerData

@rpc("any_peer", "call_local")
func startGame():
	# Change Scene to Gane Scene
	get_tree().change_scene_to_packed(gameScene)

# Buttons Pressed Functions
func _on_host_pressed():
	multiplayerFunc()
	
	server = ENetMultiplayerPeer.new()
		
	var err = server.create_server(port, MAX_CONNECTIONS)


	# If there an error exist
	if err != OK:
		print("Can not host! " + str(err))
		return
		
	multiplayer.multiplayer_peer = server
	print("Creating Server Successfully!! Waiting for Players........")
		
	checkName()
	checkColor()
	
	Global.playersLoaded += 1
	
	Global.players[1] = playerData
	
	# Hide Main menu
	$Controls.visible = false
	# Show Lobby Menu
	$Lobby.visible = true
	# Hide Lan Browser
	$LanServerVrowser.visible = false
	# Broadcast room Data 
	$LanServerVrowser.setUpBroadCast($Controls/Name.text)
	# Show Start Button
	$Lobby/Start.visible = true
	
func _on_join_pressed():
	multiplayerFunc()
	
	server = ENetMultiplayerPeer.new()

	checkAddress()
	checkColor()
	checkName()
	
	$LanServerVrowser.runListener()
	await  get_tree().create_timer(2).timeout
	
	if address not in Global.avilableRooms:
		print(Global.avilableRooms)
		print("This IP Not Exist")
		disconnectFromTheServer()
		return	
		
	
	server.create_client(address, port)
	multiplayer.multiplayer_peer = server

	# Hide Main menu
	$Controls.visible = false
	# Show Lobby Menu
	$Lobby.visible = true
	#
	$LanServerVrowser.visible = false

func _on_data_pressed():
	printPlayersData()

func _on_Exit_pressed():
	disconnectFromTheServer()
	$Controls.visible = true
	$Lobby.visible = false
	$LanServerVrowser.visible = true
	$LanServerVrowser.cleanUp()

func _on_start_pressed():
	startGame.rpc()


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
	
	playerData["name"] = "Unknown" if $Controls/Name.text.strip_edges() == "" else $Controls/Name.text

func checkColor():
	#if $Controls/ColorPicker.color == Color(0,0,0,0):
	playerData["color"] = Color(0,0,0,1) if $Controls/ColorPicker.color == Color(0,0,0,0)  else  $Controls/ColorPicker.color

func disconnectFromTheServer():
	multiplayer.multiplayer_peer = null
	multiplayer.peer_connected.disconnect(playerConnected)
	multiplayer.peer_disconnected.disconnect(playerDisconnected)
	multiplayer.connected_to_server.disconnect(serverConnected)
	multiplayer.server_disconnected.disconnect(serverDisconnected)
	multiplayer.connection_failed.disconnect(connectionFailed)

func changeCount():
	$Lobby/PlayersCount.text = str(Global.playersLoaded)



