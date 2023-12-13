extends Control

#func _ready():
	#if multiplayer.is_server():
		#print_once_per_client.rpc()

@rpc
func print_once_per_client():
	print("I will be printed to the console once per each connected client.")


func _on_join_pressed():
	# Create client.
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("127.0.0.1", 8910)
	multiplayer.multiplayer_peer = peer
	print("This is client")


func _on_host_pressed():
	# Create server.
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(8910, 5)
	multiplayer.multiplayer_peer = peer
	print("This is server")
	


func _on_message_pressed():
	if multiplayer.is_server():
		print_once_per_client.rpc()
