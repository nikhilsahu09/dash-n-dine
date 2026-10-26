extends Sprite2D
@onready var car=get_node("/root/World/Kart")
func _process(_delta):
	if car:
		rotation=-car.rotation.y
