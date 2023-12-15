extends CanvasLayer


func animate():
	$".".visible = true
	$AnimationTree.play("fade")
	await  $AnimationTree.animation_finished
	$".".visible = false
func animateReverse():
	$".".visible = true
	$AnimationTree.play_backwards("fade")
	await  $AnimationTree.animation_finished
	$".".visible = false
