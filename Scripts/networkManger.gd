extends Control

#region Multiplayer Manager



# Variables
var address: String 
var port: int = 8910
var playerData: Dictionary = {"name" : "", "color": Color(0,0,0,0), "index": 0}
var server: ENetMultiplayerPeer 
var mainScene:String = "res://Scenes/multiplayer_scene.tscn"
var NextScene: String = "res://Scenes/game.tscn"
# Constants
const MAX_CONNECTIONS = 20

# Signals
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal connection_faild

var connected: bool = false


# Node Functions

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
	returnToMain()
	
func connectionFailed():
	print("Couldn't connect!")	
	multiplayer.multiplayer_peer = null

# RPC Functions
@rpc("any_peer", "call_local", "reliable")
func register_player(newPlayerData):
	var newPlayerId = multiplayer.get_remote_sender_id()
	Global.players[newPlayerId] = newPlayerData
	
@rpc("any_peer", "call_local")
func nextScene():
	# Change Scene to Gane Scene
	get_tree().change_scene_to_file(NextScene)

@rpc("any_peer", "call_local")
func removePlayer(id: int):
	get_node(str(id)).queue_free()
	
# Buttons Pressed Functions
func createServer() -> bool:
	multiplayerFunc()
	
	server = ENetMultiplayerPeer.new()
		
	var err = server.create_server(port, MAX_CONNECTIONS)


	# If there an error exist
	if err != OK:
		print("Can not host! " + str(err))
		return false
		
	multiplayer.multiplayer_peer = server
	print("Creating Server Successfully!! Waiting for Players........")
		
	checkName()
	checkColor()
	
	Global.playersLoaded += 1
	
	Global.players[1] = playerData
	
	
	# Broadcast room Data 
	setUpBroadCast(playerData["name"])
	
	return true
	
func createClient() -> bool:
	multiplayerFunc()
	

	
	server = ENetMultiplayerPeer.new()

	checkAddress()
	checkColor()
	checkName()
	
	# Start Listening
	runListener()
	await  get_tree().create_timer(2).timeout
	
	if address not in Global.avilableRooms:
		print(Global.avilableRooms)
		print("This IP Not Exist")
		disconnectFromTheServer()
		return false
		
	# Create the client
	server.create_client(address, port)
	multiplayer.multiplayer_peer = server
	

	

	return true

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


func checkAddress():
	# To check if it is null
	address = "127.0.0.1" if address.strip_edges() == "" else address

func checkName():
	playerData["name"] = "Unknown" if playerData["name"].strip_edges() == "" else playerData["name"]

func checkColor():
	playerData["color"] = Color(0,0,0,1) if playerData["color"] == Color(0,0,0,0)  else  playerData["color"]

func disconnectFromTheServer():
	multiplayer.multiplayer_peer = null
	multiplayer.peer_connected.disconnect(playerConnected)
	multiplayer.peer_disconnected.disconnect(playerDisconnected)
	multiplayer.connected_to_server.disconnect(serverConnected)
	multiplayer.server_disconnected.disconnect(serverDisconnected)
	multiplayer.connection_failed.disconnect(connectionFailed)

func returnToMain():
	get_tree().change_scene_to_file(mainScene)
#endregion Multiplayer Manager



#region Lan Server Browser
signal server_found
signal server_removed
signal avilable_rooms_changed

var RoomInfo = {"name": "name", "Count": 0}
var broadcaster : PacketPeerUDP
var listener : PacketPeerUDP
var listenPort: int = 8911
var broadcastPort: int = 8912
var run = false
var time: int = 0

@onready var broadCastTimer: Timer = Timer.new()
@onready var LinstenerTimer: Timer = Timer.new()
@export var broadcastAddress: String = "192.168.1.255"

func _ready():
	
	broadCastTimer.connect("timeout", _on_broad_cast_timer_timeout)
	LinstenerTimer.connect("timeout", _on_listener_timer_timeout)
	broadCastTimer.wait_time = 1
	LinstenerTimer.wait_time = 1
	
	call_deferred("add_child", broadCastTimer)
	call_deferred("add_child", LinstenerTimer)

# Broad cast room data to all devices on LAN
func setUpBroadCast(roomName):
	RoomInfo.name = roomName
	RoomInfo.Count = Global.players.size()
	
	
	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	broadcaster.set_dest_address(broadcastAddress, listenPort)
	var err = broadcaster.bind(broadcastPort)
	
	if err == OK:
		print("Bound to Broadcast Port " + str(listenPort) + " Successful!")
	else:
		print("Faild to bind to broadcast port!")
	
	broadCastTimer.start()

# Stop Broadcasting & Listening
func cleanUp():
	if listener:
		listener.close()
	broadCastTimer.stop()
	if broadcaster != null:
		broadcaster.close()

# Set up listener
func setUp():
	listener = PacketPeerUDP.new()
	var err = listener.bind(listenPort)
	if err == OK:
		print("Bound to listen port " + str(listenPort) + " Successful")
	else:
		print("Faild to bind to listen port!")	

#
func runListener():
	setUp()
	run = true
	LinstenerTimer.start()

# Brocast room data every one Second
func _on_broad_cast_timer_timeout():
	#print("Broadcasting Game!")
	RoomInfo.Count = Global.playersLoaded
	var data = JSON.stringify(RoomInfo)
	var packet = data.to_ascii_buffer()
	broadcaster.put_packet(packet)

func _on_listener_timer_timeout():
	# To run listener timer twice onle
	if time == 2:
		LinstenerTimer.stop()
		time = 0
		return 
	if run == true:
		if listener.get_available_packet_count() > 0:
			var serverIp = listener.get_packet_ip()
			#var serverPort = listener.get_packet_port()
			var bytes = listener.get_packet()	
			var _data = bytes.get_string_from_ascii()
			#var roomInfo = JSON.parse_string(data)
			
			#print("Server IP: " + serverIp + "; Port: " + str(serverPort) + "; RoomInfo: " + str(roomInfo) + ";")
			if serverIp != "":
				Global.addIP(serverIp)
		else:
			var serverIp = listener.get_packet_ip()
			Global.removeIP(serverIp)
	time += 1


#endregion Lan Server Browser
