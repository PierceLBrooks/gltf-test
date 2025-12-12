extends Node3D

func find(parent: Node, type):
	for child in parent.get_children():
		print(str(child))
		if is_instance_of(child, type):
			return child
		var grandchild = find(child, type)
		if grandchild != null:
			return grandchild
	return null

func _ready():
	var player: AnimationPlayer = find(self, AnimationPlayer)
	var animations = player.get_animation_list()
	for animation in animations:
		player.get_animation(animation).loop_mode = Animation.LOOP_PINGPONG
		player.play(animation)
		break
