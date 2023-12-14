extends Control

signal server_found
signal server_removed

var RoomInfo = {"name": "name", "Count": 0}
var broadcaster : PacketPeerUDP
var listener : PacketPeerUDP
var listenPort: int = 8911
var broadcastPort: int = 8912
var run = false
@onready var broadCastTimer = $"../BroadCastTimer" as Timer
@export var broadcastAddress: String = "192.168.1.255"

func _process(_delta):
	if run == true:
		if listener.get_available_packet_count() > 0:
			var serverIp = listener.get_packet_ip()
			var serverPort = listener.get_packet_port()
			var bytes = listener.get_packet()	
			var data = bytes.get_string_from_ascii()
			var roomInfo = JSON.parse_string(data)
			
			print("Server IP: " + serverIp + "; Port: " + str(serverPort) + "; RoomInfo: " + str(roomInfo) + ";")

func setUpBroadCast(roomName):
	RoomInfo.name = roomName
	RoomInfo.Count = Global.players.size()
	
	
	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	broadcaster.set_dest_address(broadcastAddress, listenPort)
	var err = broadcaster.bind(broadcastPort)
	
	if err == OK:
		print("Bound to Broadcast Port " + str(broadcaster) + " Successful!")
	else:
		print("Faild to bind to broadcast port!")
	
	broadCastTimer.start()
	
func _on_broad_cast_timer_timeout():
	print("Broadcasting Game!")
	RoomInfo.Count = Global.playersLoaded
	var data = JSON.stringify(RoomInfo)
	var packet = data.to_ascii_buffer()
	broadcaster.put_packet(packet)

func _on_listen_pressed():
	setUp()
	run = true

func _on_stop_pressed():
	cleanUp()

func cleanUp():
	listener.close()
	broadCastTimer.stop()
	if broadcaster != null:
		broadcaster.close()

func setUp():
	listener = PacketPeerUDP.new()
	var err = listener.bind(listenPort)
	if err == OK:
		print("Bound to listen port " + str(listenPort) + " Successful")
	else:
		print("Faild to bind to listen port!")	

