extends Control



func _ready():
	Global.connect("countChanged", changeCount)
	NetworkManger.connect("server_disconnected", serverDisconnected)


func serverDisconnected():

	# Hide Main menu
	$Controls.visible = true
	# Show Lobby Menu
	$Lobby.visible = false
	#
	$LanServerVrowser.visible = true


# Buttons Pressed Functions
func _on_host_pressed():

	# Assign Data
	NetworkManger.playerData["name"] = $Controls/Name.text
	NetworkManger.playerData["color"] = $Controls/ColorPicker.color
	
	if NetworkManger.createServer() == true:
		# Hide Main menu
		$Controls.visible = false
		# Show Lobby Menu
		$Lobby.visible = true
		# Hide Lan Browser
		$LanServerVrowser.visible = false
		# Show Start Button
		$Lobby/Start.visible = true	
	NetworkManger.playerData["index"] = Global.playersLoaded 

func _on_join_pressed():

	# Assign Data
	NetworkManger.playerData["name"] = $Controls/Name.text
	NetworkManger.address = $Controls/IP.text
	NetworkManger.playerData["color"] = $Controls/ColorPicker.color

	if await NetworkManger.createClient() == true:
		# Hide Main menu
		$Controls.visible = false
		# Show Lobby Menu
		$Lobby.visible = true
		# Hide Server Browser
		$LanServerVrowser.visible = false
	NetworkManger.playerData["index"] = Global.playersLoaded 
	
func _on_data_pressed():
	NetworkManger.printPlayersData()

func _on_Exit_pressed():
	NetworkManger.disconnectFromTheServer()
	
	$Controls.visible = true
	$Lobby.visible = false
	$LanServerVrowser.visible = true
	NetworkManger.cleanUp()
	Global.playersLoaded = 0
	Global.players.clear()

func _on_start_pressed():
	NetworkManger.nextScene.rpc()
	
# My Custem Functions
func changeCount():
	$Lobby/PlayersCount.text = str(Global.playersLoaded)

