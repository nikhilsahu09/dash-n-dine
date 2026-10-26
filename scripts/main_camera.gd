extends Camera3D
@export var target_path:NodePath
@export var height:=6.0
@export var distance:=10.0
@export var smooth_speed:=6.0
@export var look_height:=2.0
@export var normal_fov:=70.0
@export var boost_fov:=82.0
@export var fov_speed:=5.0
var target
var shake:=0.0
var sensitivity:=1.0
var shake_enabled:=true
func _ready():
	target=get_node(target_path)
	make_current()
func add_shake(amount:float):
	if !shake_enabled:
		return
	shake+=amount
func _process(delta):
	if target==null:
		return
	var back_dir=-target.global_transform.basis.z
	var desired_pos=target.global_position+back_dir*distance
	desired_pos.y+=height
	global_position=global_position.lerp(desired_pos,smooth_speed*sensitivity*delta)
	shake=lerp(shake,0.0,8.0*delta)
	if shake>0.0:
		var offset=Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1))*shake*0.12
		global_position+=offset
	var target_fov=normal_fov
	if target.is_boosting:
		target_fov=boost_fov
	fov=lerp(fov,target_fov,fov_speed*delta)
	look_at(target.global_position+Vector3(0,look_height,0),Vector3.UP)
