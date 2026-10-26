extends Sprite3D
@onready var game = $"../GameManager"
@onready var player = get_node("/root/World/Kart")
@onready var pickup = $"../PickupPoint"
@onready var dropoff = $"../DeliveryZone"
func _process(_delta):
	if player == null or game == null:
		return
	global_position = player.global_position + Vector3(0, 3, 0)
	var target = pickup
	if game.has_package:
		target = dropoff
	if target != null:
		look_at(target.global_position, Vector3.UP)
