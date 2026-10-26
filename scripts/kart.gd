extends CharacterBody3D
@export var acceleration:=8.0
@export var max_speed:=21.0
@export var boost_speed:=6.7
@export var turn_speed:=2.5
@export var friction:=5.0
@export var brake_power:=18.0
@export var boost_max:=100.0
@export var boost_recharge:=35.0
@export var boost_drain:=45.0
var boost_charge:=100.0
var is_boosting:=false
var current_speed:=0.0
var speed_mph:=0.0
var boost_speed_bonus:=0.0
@onready var gm=get_tree().current_scene.get_node("GameManager")
@onready var engine_sound=$EngineAudio
@onready var honk=$HonkSFX
@onready var turbo_whoosh=$TurboWhoosh
@onready var boost_flame=$BoostFlame2
@onready var camera=get_tree().current_scene.get_node("MainCamera")
func _ready():
	apply_garage_stats()
	if engine_sound:
		engine_sound.play()
func _physics_process(delta):
	if gm.state!=gm.GameState.PLAYING:
		velocity=Vector3.ZERO
		move_and_slide()
		return
	if Input.is_action_just_pressed("interact"):
		if !gm.has_package:
			var distance=global_position.distance_to(gm.pickup.global_position)
			if distance<10.0:
				gm.pickup_package()
		else:
			var distance=global_position.distance_to(gm.dropoff.global_position)
			if distance<10.0:
				gm.deliver_package()
	if Input.is_action_just_pressed("boost"):
		if boost_charge>=99 and !is_boosting:
			is_boosting=true
			if turbo_whoosh:
				turbo_whoosh.play()
	if is_boosting:
		if camera:
			camera.add_shake(0.15)
		boost_charge-=boost_drain*delta
		boost_speed_bonus=move_toward(boost_speed_bonus,boost_speed,10*delta)
		if boost_charge<=0:
			boost_charge=0
			is_boosting=false
	else:
		boost_charge+=boost_recharge*delta
		boost_speed_bonus=move_toward(boost_speed_bonus,0,5*delta)
	boost_charge=clamp(boost_charge,0,boost_max)
	if Input.is_action_pressed("ui_up"):
		current_speed=move_toward(current_speed,max_speed+boost_speed_bonus,acceleration*delta)
	elif Input.is_action_pressed("ui_down"):
		if current_speed>0:
			current_speed=move_toward(current_speed,0,brake_power*delta)
		else:
			current_speed=move_toward(current_speed,-max_speed*0.35,acceleration*delta)
	else:
		current_speed=move_toward(current_speed,0,friction*delta)
	if abs(current_speed)>0.5:
		if Input.is_action_pressed("ui_left"):
			rotation.y+=turn_speed*delta
		if Input.is_action_pressed("ui_right"):
			rotation.y-=turn_speed*delta
	velocity=transform.basis.z*current_speed
	move_and_slide()
	speed_mph=min(velocity.length()*5,120.0)
	if boost_flame:
		boost_flame.emitting=is_boosting
	update_engine_sound()
func update_engine_sound():
	if !engine_sound:
		return
	if abs(current_speed)<=0.5:
		engine_sound.stop()
		return
	if !engine_sound.playing:
		engine_sound.play()
	var ratio=abs(current_speed)/max_speed
	var pitch=0.8+ratio*0.7
	if is_boosting:
		pitch+=0.25
	engine_sound.pitch_scale=lerp(engine_sound.pitch_scale,pitch,0.1)
func apply_garage_stats():
	var stats=VehicleManager.get_final_stats()
	max_speed=stats["speed"]/4.0
	boost_speed=stats["boost_strength"]/8.0
	boost_recharge=stats["boost_regen"]
	turn_speed=stats["handling"]/30.0
	brake_power=stats["braking"]/4.0
