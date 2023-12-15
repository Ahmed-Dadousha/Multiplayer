extends Control


# Start listening
func _on_listen_pressed():
	NetworkManger.runListener()
	
# Stop Listening
func _on_stop_pressed():
	NetworkManger.cleanUp()

