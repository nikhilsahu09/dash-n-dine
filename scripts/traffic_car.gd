extends CharacterBody3D
@export var speed := 17.0
@export var turn_speed := 4.0
var points := []
var current_index := 0
func _ready():
	velocity = Vector3.ZERO
	rotation = Vector3.ZERO
	var parent = get_tree().current_scene.get_node("TrafficPath")
	if parent == null:
		print("❌ TrafficPath not found")
		return
	for child in parent.get_children():
		points.append(child)
	print("Loaded points:", points.size())
	set_physics_process(true)
	current_index = randi() % points.size()
	speed = randf_range(15.0, 20.0)
func _physics_process(delta):
	if points.size() == 0:
		return
	var target = points[current_index].global_position
	var dir = target - global_position
	dir.y = 0
	if dir.length() < 1.5:
		current_index = (current_index + 1) % points.size()
		return
	dir = dir.normalized()
	var target_angle = atan2(dir.x, dir.z)
	rotation.y = lerp_angle(rotation.y, target_angle, turn_speed * delta)
	var forward = global_transform.basis.z
	velocity = forward * speed
	move_and_slide()
