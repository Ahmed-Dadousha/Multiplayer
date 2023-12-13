extends Control



#region New Code Region

## Server Data
#@export var Address = "127.0.0.1"
#const PORT = 4321
#var peer
#var scene: PackedScene = preload("res://Scenes/lobby.tscn")
#
#func _ready():
	#multiplayer.peer_connected.connect(playerConnected)
	#multiplayer.peer_disconnected.connect(playerDisconnected)
	#multiplayer.connected_to_server.connect(connectedToServer)
	#multiplayer.connection_failed.connect(connectionFaild)
#
#@rpc("any_peer","call_local")
#func startGame():
	## Create a new instance of the lobby scene
	#var lobby = scene.instantiate()
	## Add the new instance to the root node
	#get_tree().root.add_child(lobby)
	## Hide the current node
	#self.hide()
#
#@rpc("any_peer")
#func sendPlayerData(Name, id):
	#if !Global.Players.has(id):
		#Global.Players[id] = {
			#"name": Name,
			#"id":id
		#}
		#
	#if multiplayer.is_server():
		#for i in Global.Players:
			#sendPlayerData(Global.Players[i].name, i)
## This called when start game button pressed
#func _on_start_game_pressed():
	## RPC is a type of function that run on all Peers
	#startGame.rpc()
#
## This called when host button pressed
#func _on_host_pressed():
	#peer = ENetMultiplayerPeer.new()
	## Create a server
	#var error = peer.create_server(PORT)
	#
	## Check if there is an error
	#if error:
		#print("Cannot host! " + str(error))
		#return
		#
	## Compress the data
	##peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	#
	#multiplayer.multiplayer_peer = peer
	#print("Waiting For Players")
	#sendPlayerData($VBoxContainer/LineEdit.text, multiplayer.get_unique_id())
	#
## This called when Join button pressed
#func _on_join_pressed():
	#peer = ENetMultiplayerPeer.new()
	## Create a client
	#peer.create_client(Address, PORT)
	##peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	#multiplayer.multiplayer_peer = peer
#
## This called on the server and all clients 
#func playerConnected(id):
	#print("Player Connected! " + str(id))
#
## This called on the server and all
#func playerDisconnected(id):
	#print("Player " + str(id))
#
## This called only from clients
#func connectedToServer():
	#print("Connected To Server!")
	#sendPlayerData.rpc_id(1, $VBoxContainer/LineEdit.text, multiplayer.get_unique_id())
#
## This called only from clients
#func connectionFaild():
	#print("Couldn't Connect!")


#endregion



#region New Code Region

## Peer = Server
#var peer = ENetMultiplayerPeer.new()
#
## Player Scene
#@export var player_scene: PackedScene
#func _on_host_pressed():
	## Create a server on port (7777)
	#peer.create_server(7777)
	## Assign The Server
	#multiplayer.multiplayer_peer = peer
	#
	## On any player connect to the server call add_player method
	#multiplayer.peer_connected.connect(add_player)
	#
	## add player for the host 
	#add_player()
#
#func _on_join_pressed():
	## Connect to the server with IP "127.0.0.1 or localhost, and PORT 7777"
	#peer.create_client("127.0.0.1",7777)
	## Assign The Server
	#multiplayer.multiplayer_peer = peer
	#
#func add_player(id = 1):
	## Create a new Instance of the player scene
	#var player = player_scene.instantiate()
	## Assign the player a name
	#player.name = str(id)
	## Add the player to the node tree
	#call_deferred("add_child", player)
	#
#func exit_game(id):
	## Disconnect the player from the server
	#multiplayer.peer_disconnected.connect(del_player)
	## Remove the player from node tree
	#del_player(id)
#
#func del_player(id):
	#rpc("_del_player", id)	
#
## Define the func as rpc
#@rpc("any_peer", "call_local") func _del_player(id):
	#get_node(str(id)).queue_free()
#
#func _on_exit_pressed():
	##exit_game(ID)
	#pass	


#endregion

