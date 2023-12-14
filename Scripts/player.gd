extends CharacterBody2D

func setName(text: String):
	$Label.text = text

func _enter_tree():
	# To avoid control other players charcter
	set_multiplayer_authority(str(name).to_int())
func _physics_process(_delta):
		
	if not is_multiplayer_authority(): return
	
	velocity = Input.get_vector("ui_left","ui_right","ui_up","ui_down") * 400
	move_and_slide()
