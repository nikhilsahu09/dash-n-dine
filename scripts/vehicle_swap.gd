extends Node3D
var current_vehicle
func change_vehicle(path):
	if path=="res://vehicles/models/kart-oodi.glb":
		get_parent().get_node("bodyvisual").visible=true
		if current_vehicle:
			current_vehicle.queue_free()
		return
	print("Loading vehicle:",path)
	var old_vehicle=get_parent().get_node_or_null("bodyvisual")
	if old_vehicle:
		old_vehicle.visible=false
		print("Hidden old kart")
	if current_vehicle:
		current_vehicle.queue_free()
	var scene=load(path)
	if scene:
		current_vehicle=scene.instantiate()
		add_child(current_vehicle)
		fix_materials(current_vehicle)
		current_vehicle.position=Vector3.ZERO
		current_vehicle.rotation=Vector3.ZERO
		print("Vehicle loaded successfully")
	else:
		print("FAILED TO LOAD VEHICLE")
func fix_materials(node):
	if node is MeshInstance3D:
		for i in range(node.mesh.get_surface_count()):
			var mat=node.mesh.surface_get_material(i)
			if mat:
				node.set_surface_override_material(i,mat)
	for child in node.get_children():
		fix_materials(child)
