extends Node
@export var traffic_scene: PackedScene
@export var spawn_points: Array[NodePath]
@export var spawn_count := 5
func _ready():
	randomize()
	print("SPAWNER RUNNING")
	for i in range(spawn_count):
		call_deferred("spawn_car", i)
func spawn_car(i):
	print("SPAWNING CAR:", i)
	var spawn_node = get_node(spawn_points[randi() % spawn_points.size()])
	var car = traffic_scene.instantiate()
	get_tree().current_scene.add_child(car)
	car.global_position = spawn_node.global_position + Vector3(0, 1, 0)
	print("✔ Car added to scene:", car.name, "at", car.global_position)
