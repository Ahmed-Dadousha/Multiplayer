extends Control

@onready var status_text = $Panel/VBoxContainer/Status
@onready var server_message_text = $Panel/VBoxContainer/MessageFromServer
var message_count_from_client = 0
const PORT: int = 8910
const ADDRESS: String = "127.0.0.1"
const CLIENTS_MAX_SIZE: int = 2

# UI
func _on_send_message_pressed():
	print("Sending message to server....")
	send_message_to_server.rpc("Hello from client: " + str(multiplayer.get_unique_id()))
	
func _on_server_pressed():
	print("Loading Server.....")
	start_server()

func _on_client_pressed():
	print("Loading Client.....")
	status_text.text = "Starting Client"
	start_client()



func start_server():
	
	# 
	multiplayer.peer_connected.connect(_on_client_connected)
	multiplayer.peer_disconnected.connect(_on_client_disconnected)
	
	
	# Create the server
	var server = ENetMultiplayerPeer.new()
	server.create_server(PORT,CLIENTS_MAX_SIZE)
	multiplayer.multiplayer_peer = server

func start_client():
	
	#
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.server_disconnected.connect(_disconnected_from_server)

	print("Creating client......")
	status_text.text = "Starting Client......"
	
	# Create client
	var client = ENetMultiplayerPeer.new()
	client.create_client(ADDRESS,PORT)
	multiplayer.multiplayer_peer = client
	
# Server Callback
func _on_client_connected(clientID):
	print("Clinet Connected: " + str(clientID)) 

func _on_client_disconnected(clientID):
	print("Clinet Disonnected: " + str(clientID)) 


# Client Callback
func _connected_to_server():
	print("Connected to Server...")
	status_text.text = "Connected to Server..."

func _disconnected_from_server():
	print("Disonnected to Server...")


# Only called from the clients but excuted on the server
@rpc("any_peer") func send_message_to_server(message: String):
	print("Message recived on server: " + message)
	message_count_from_client += 1
	send_message_to_client.rpc("Right back at ya! Client. Count: " + str(message_count_from_client))

# Only Called from server but excuted on the clients
@rpc("authority") func send_message_to_client(message: String):
	print("Message Recived in client: " + message)
	server_message_text.text = message

