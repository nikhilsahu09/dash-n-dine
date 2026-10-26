extends CanvasLayer
const MONEY_POPUP=preload("res://scenes/MoneyPopup.tscn")
@onready var score_label=$UI/ScoreLabel
@onready var money_label=$UI/MoneyLabel
@onready var timer_label=$UI/TimerLabel
@onready var prompt_label=$UI/PromptLabel
@onready var turbo_bar=$UI/TurboBar
@onready var boost_label=$UI/BoostStateLabel
@onready var fade=$UI/Fade
@onready var countdown_label=$UI/CountdownLabel
@onready var game_over_panel=$UI/GameOverPanel
@onready var game_over_label=$UI/GameOverPanel/GameOverLabel
@onready var action_label=$UI/ActionLabel
@onready var speed_number=$UI/SpeedNumber
@onready var combo_label=$UI/ComboLabel
@onready var pickup_icon=$UI/Minimap/PickupIcon
@onready var dropoff_icon=$UI/Minimap/DropoffIcon
@onready var player_icon=$UI/Minimap/PlayerIcon
@onready var needle=$UI/Needle
@onready var pause_panel=$UI/PausePanel
@onready var settings_panel=$UI/SettingsPanel
@onready var music_slider=$UI/SettingsPanel/MusicSlider
@onready var sfx_slider=$UI/SettingsPanel/SFXSlider
@onready var screen_shake_toggle=$UI/SettingsPanel/ScreenShakeToggle
@onready var camera_slider=$UI/SettingsPanel/CameraSensitivitySlider
@onready var world_settings_panel=$UI/WorldSettingsPanel
@onready var gm=get_node("/root/World/GameManager")
@onready var car=get_node("/root/World/Kart")
@export var minimap_size:=350.0
@export var minimap_world_size_x:=310.0
@export var minimap_world_size_z:=300.0
@export var minimap_world_center:=Vector2(30,0)
@export var min_angle:=-35.0
@export var max_angle:=235.0
@export var max_mph:=120.0
var is_paused=false
func _ready():
	turbo_bar.min_value=0
	turbo_bar.max_value=car.boost_max
	action_label.text=""
	game_over_panel.visible=false
	fade.visible=false
	pause_panel.visible=false
	settings_panel.visible=false
	music_slider.value=SaveManager.settings["music_volume"]
	sfx_slider.value=SaveManager.settings["sfx_volume"]
	screen_shake_toggle.button_pressed=SaveManager.settings["screen_shake"]
	camera_slider.value=SaveManager.settings["camera_sensitivity"]
func _process(_delta):
	score_label.text="Score: "+str(gm.score)
	money_label.text=" "+str(SaveManager.get_coins())
	timer_label.text="Time: %.1f"%gm.time_left
	combo_label.text="Combo x"+str(gm.combo)
	speed_number.text=str(int(min(car.speed_mph,max_mph)))+" MPH"
	var speed_percent=clamp(car.speed_mph/max_mph,0.0,1.0)
	needle.rotation_degrees=lerp(min_angle,max_angle,speed_percent)
	turbo_bar.value=car.boost_charge
	if car.boost_charge<=0:
		boost_label.text="NO BOOST"
	elif car.boost_charge<30:
		boost_label.text="LOW BOOST"
	elif car.boost_charge<70:
		boost_label.text="MEDIUM BOOST"
	elif car.boost_charge<car.boost_max:
		boost_label.text="HIGH BOOST"
	else:
		boost_label.text="BOOST READY"
	update_prompt()
	update_countdown()
	update_game_over()
	update_minimap()
func update_prompt():
	prompt_label.text=""
	if gm.state!=gm.GameState.PLAYING:
		return
	var pickup_dist=car.global_position.distance_to(gm.pickup.global_position)
	var drop_dist=car.global_position.distance_to(gm.dropoff.global_position)
	if !gm.has_package and pickup_dist<4:
		prompt_label.text="Press E to PICK UP"
	elif gm.has_package and drop_dist<4:
		prompt_label.text="Press E to DELIVER"
func update_countdown():
	countdown_label.visible=gm.state==gm.GameState.COUNTDOWN
	if countdown_label.visible:
		countdown_label.text=str(int(ceil(gm.countdown)))
func update_game_over():
	game_over_panel.visible=gm.state==gm.GameState.GAME_OVER
	if !game_over_panel.visible:
		return
	game_over_label.text=" GAME OVER\n\n"+" Score: "+str(gm.score)+"\n Coins: +"+str(gm.coins_earned)+"\n Deliveries: "+str(gm.deliveries_completed)+"\n Best Combo: x"+str(gm.best_combo)+"\n Distance: "+str(int(gm.total_distance))+"m"
func update_minimap():
	if gm.pickup:
		pickup_icon.visible=!gm.has_package
		pickup_icon.position=world_to_minimap(gm.pickup.global_position)
	if gm.dropoff:
		dropoff_icon.visible=gm.has_package
		dropoff_icon.position=world_to_minimap(gm.dropoff.global_position)
	player_icon.position=world_to_minimap(car.global_position)
	player_icon.rotation=-car.rotation.y
func world_to_minimap(pos:Vector3)->Vector2:
	var p=Vector2(pos.x,pos.z)-minimap_world_center
	p.x*=minimap_size/minimap_world_size_x
	p.y*=minimap_size/minimap_world_size_z
	return p+Vector2(minimap_size/2,minimap_size/2)
func show_message(text:String):
	prompt_label.text=text
	await get_tree().create_timer(1.0).timeout
	prompt_label.text=""
func show_action(text:String):
	action_label.text=text
	action_label.modulate.a=1.0
	await get_tree().create_timer(0.8).timeout
	var tween=create_tween()
	tween.tween_property(action_label,"modulate:a",0.0,1.0)
func _input(event):
	if !event.is_action_pressed("ui_cancel"):
		return
	if world_settings_panel.visible:
		world_settings_panel.visible=false
		settings_panel.visible=true
	elif settings_panel.visible:
		settings_panel.visible=false
		pause_panel.visible=true
	else:
		toggle_pause()
func toggle_pause():
	is_paused=!is_paused
	if is_paused:
		get_tree().paused=true
		open_panel(pause_panel)
	else:
		close_panel(pause_panel)
		get_tree().paused=false
func _on_resume_button_pressed():
	toggle_pause()
func _on_play_again_button_pressed():
	await fade_to_black()
	get_tree().reload_current_scene()
func fade_to_black():
	fade.visible=true
	var tween=create_tween()
	tween.tween_property(fade,"modulate:a",1.0,1.0)
	await tween.finished
func _on_settings_button_pressed():
	pause_panel.visible=false
	open_panel(settings_panel)
func _on_settings_close_button_pressed():
	close_panel(settings_panel)
	open_panel(pause_panel)
func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),value)
	SaveManager.settings["music_volume"]=value
	SaveManager.save_settings()
func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),value)
	SaveManager.settings["sfx_volume"]=value
	SaveManager.save_settings()
func _on_screen_shake_toggle_toggled(value):
	var cam=get_tree().current_scene.get_node_or_null("MainCamera")
	if cam:
		cam.shake_enabled=value
	SaveManager.settings["screen_shake"]=value
	SaveManager.save_settings()
func _on_camera_sensitivity_slider_value_changed(value):
	var cam=get_tree().current_scene.get_node_or_null("MainCamera")
	if cam:
		cam.sensitivity=value
	SaveManager.settings["camera_sensitivity"]=value
	SaveManager.save_settings()
func _on_main_menu_button_pressed():
	get_tree().paused=false
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
func open_panel(panel):
	panel.visible=true
func close_panel(panel):
	panel.visible=false
func show_money_popup(amount,time_bonus):
	var popup=MONEY_POPUP.instantiate()
	$UI.add_child(popup)
	popup.position=Vector2(500,400)
	popup.get_node("Label").text=" +"+str(amount)+" Coins\n +"+str(time_bonus)+" Seconds"
	var tween=create_tween()
	tween.parallel().tween_property(popup,"position",popup.position+Vector2(0,-100),1.8)
	tween.parallel().tween_property(popup,"modulate:a",0.0,2.5)
	await tween.finished
	popup.queue_free()
func _on_world_settings_button_pressed():
	settings_panel.visible=false
	world_settings_panel.visible=true
func _on_rain_button_pressed():
	WeatherManager.change_weather(WeatherManager.Weather.RAIN)
	SaveManager.player_data["weather"]=WeatherManager.Weather.RAIN
	SaveManager.save_game()
func _on_fog_button_pressed():
	WeatherManager.change_weather(WeatherManager.Weather.FOG)
	SaveManager.player_data["weather"]=WeatherManager.Weather.FOG
	SaveManager.save_game()
func _on_clear_button_pressed():
	WeatherManager.change_weather(WeatherManager.Weather.CLEAR)
	SaveManager.player_data["weather"]=WeatherManager.Weather.CLEAR
	SaveManager.save_game()
func _on_random_weather_button_pressed():
	var weather=randi_range(0,2)
	WeatherManager.change_weather(weather)
	SaveManager.player_data["weather"]=weather
	SaveManager.save_game()
func _on_world_back_button_pressed():
	world_settings_panel.visible=false
	pause_panel.visible=true
func _on_back_to_main_menu_button_pressed():
	get_tree().paused=false
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
func _on_random_time_button_pressed():
	var time=randi_range(0,2)
	TimeManager.change_time(time)
	SaveManager.player_data["time_of_day"]=time
	SaveManager.save_game()
func _on_day_button_pressed():
	TimeManager.change_time(TimeManager.TimeOfDay.DAY)
	SaveManager.player_data["time_of_day"]=TimeManager.TimeOfDay.DAY
	SaveManager.save_game()
func _on_sunset_button_pressed():
	TimeManager.change_time(TimeManager.TimeOfDay.SUNSET)
	SaveManager.player_data["time_of_day"]=TimeManager.TimeOfDay.SUNSET
	SaveManager.save_game()
func _on_night_button_pressed():
	TimeManager.change_time(TimeManager.TimeOfDay.NIGHT)
	SaveManager.player_data["time_of_day"]=TimeManager.TimeOfDay.NIGHT
	SaveManager.save_game()
