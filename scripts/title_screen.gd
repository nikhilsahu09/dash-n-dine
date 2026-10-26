extends Control
@export var rotation_speed:=25.0
@onready var vehicle_holder=$CarPreview/SubViewport/PreviewWorld/VehicleHolder
@onready var high_score_label=$UI/HighScoreLabel
@onready var speed_bar=$UI/VehicleStats/SpeedContainer/SpeedBar
@onready var boost_strength_bar=$UI/VehicleStats/BoostContainer/BoostStrengthBar
@onready var boost_regen_bar=$UI/VehicleStats/RegenContainer/BoostRegenBar
@onready var handling_bar=$UI/VehicleStats/HandlingContainer/HandlingBar
@onready var braking_bar=$UI/VehicleStats/BrakingContainer/BrakingBar
@onready var vehicle_name_label=$UI/VehiclePanel/VehicleNameLabel
@onready var vehicle_description=$UI/VehiclePanel/VehicleDescription
@onready var lock_label=$UI/VehiclePanel/LockLabel
@onready var play_button=$UI/PlayButton
@onready var how_to_play_panel=$UI/HowToPlayPanel
@onready var settings_panel=$UI/SettingsPanel
@onready var credits_panel=$UI/CreditsPanel
@onready var stats_panel=$UI/StatsPanel
@onready var garage_panel=$UI/GaragePanel
@onready var upgrade_panel=$UI/UpgradePanel
@onready var music_slider=$UI/SettingsPanel/MusicSlider
@onready var sfx_slider=$UI/SettingsPanel/SFXSlider
@onready var vehicle_list=$UI/GaragePanel/GarageList/VehicleScroll/VehicleList
@onready var color_list=$UI/GaragePanel/ColorList
@onready var wheel_list=$UI/GaragePanel/WheelList
@onready var garage_coin_label=$UI/GaragePanel/GarageCoinLabel
@onready var coin_label=$UI/CoinLabel
@onready var not_enough_coins_panel=$UI/GaragePanel/NotEnoughCoinsPanel
@onready var upgrade_close_button=$UI/UpgradePanel/UpgradeCloseButton
@onready var upgrade_button=$UI/UpgradeButton
@onready var engine_level=$UI/UpgradePanel/EngineCard/EngineLevel
@onready var turbo_level=$UI/UpgradePanel/TurboCard/TurboLevel
@onready var regen_level=$UI/UpgradePanel/RegenCard/RegenLevel
@onready var handling_level=$UI/UpgradePanel/HandlingCard/HandlingLevel
@onready var brakes_level=$UI/UpgradePanel/BrakesCard/BrakesLevel
@onready var engine_buy=$UI/UpgradePanel/EngineCard/EngineBuy
@onready var turbo_buy=$UI/UpgradePanel/TurboCard/TurboBuy
@onready var regen_buy=$UI/UpgradePanel/RegenCard/RegenBuy
@onready var handling_buy=$UI/UpgradePanel/HandlingCard/HandlingBuy
@onready var brakes_buy=$UI/UpgradePanel/BrakesCard/BrakesBuy
@onready var achievements_label=$UI/StatsPanel/AchievementsLabel
@onready var stats_label=$UI/StatsPanel/StatsLabel
var current_car=null
var selected_vehicle_stats={}
var selected_vehicle_name=""
var coin_popup_tween:Tween
func _ready():
	#SaveManager.reset_player_data()
	upgrade_close_button.pressed.connect(close_upgrade_panel)
	upgrade_button.pressed.connect(open_upgrade_panel)
	engine_buy.pressed.connect(func(): buy_upgrade("engine"))
	turbo_buy.pressed.connect(func(): buy_upgrade("turbo"))
	regen_buy.pressed.connect(func(): buy_upgrade("fuel"))
	handling_buy.pressed.connect(func(): buy_upgrade("handling"))
	brakes_buy.pressed.connect(func(): buy_upgrade("brakes"))
	SaveManager.load_settings()
	VehicleManager.load_from_save()
	VehicleManager.load_selected_vehicle()
	cache_selected_vehicle_stats()
	apply_settings()
	garage_panel.visible=false
	upgrade_panel.visible=false
	stats_panel.visible=false
	how_to_play_panel.visible=false
	settings_panel.visible=false
	credits_panel.visible=false
	lock_label.visible=false
	not_enough_coins_panel.visible=false
	music_slider.value=SaveManager.settings["music_volume"]
	sfx_slider.value=SaveManager.settings["sfx_volume"]
	update_vehicle()
	update_upgrade_shop()
	update_coin_display()
	update_garage_coin_display()
func _process(delta):
	if vehicle_holder:
		vehicle_holder.rotation.y+=deg_to_rad(rotation_speed)*delta
func update_vehicle():
	var vehicle=VehicleManager.get_current_vehicle()
	update_coin_display()
	update_garage_coin_display()
	vehicle_name_label.text=vehicle.get("name","Unknown Vehicle")
	vehicle_description.text=vehicle.get("description","No description available.")
	if current_car:
		current_car.queue_free()
		current_car=null
	var vehicle_path=vehicle.get("path","")
	if vehicle_path!="":
		var vehicle_scene=load(vehicle_path)
		if vehicle_scene:
			current_car=vehicle_scene.instantiate()
			vehicle_holder.add_child(current_car)
			current_car.position=Vector3.ZERO
			current_car.rotation_degrees=Vector3(0,180,0)
			apply_vehicle_color()
	var owned=vehicle.get("owned",false)
	if owned:
		lock_label.visible=false
		play_button.visible=true
		play_button.disabled=false
	else:
		lock_label.visible=true
		lock_label.text=" LOCKED\n "+str(vehicle.get("price",0))+" Coins"
		play_button.visible=false
		play_button.disabled=true
	update_vehicle_stats()
	high_score_label.text="Highest Score: "+str(SaveManager.get_highest_score())
func _on_left_button_pressed():
	VehicleManager.previous_vehicle()
	update_vehicle()
func _on_right_button_pressed():
	VehicleManager.next_vehicle()
	update_vehicle()
func _on_play_button_pressed():
	var vehicle=VehicleManager.get_current_vehicle()
	if not vehicle.get("owned",false):
		return
	var title_music=$TitleMusic
	if title_music:
		title_music.stop()
	get_tree().change_scene_to_file("res://scenes/world.tscn")
func _on_garage_button_pressed():
	update_colors()
	update_garage()
	update_wheels()
	update_upgrade_shop()
	update_coin_display()
	update_garage_coin_display()
	not_enough_coins_panel.visible=false
	garage_panel.visible=true
	garage_panel.scale=Vector2(0.8,0.8)
	garage_panel.modulate.a=0.0
	var tween=create_tween()
	tween.parallel().tween_property(garage_panel,"scale",Vector2.ONE,0.25)
	tween.parallel().tween_property(garage_panel,"modulate:a",1.0,0.25)
func _on_settings_button_pressed():
	open_panel(settings_panel)
func _on_how_to_play_button_pressed():
	open_panel(how_to_play_panel)
func _on_credits_button_pressed():
	open_panel(credits_panel)
func _on_settings_back_button_pressed():
	close_panel(settings_panel)
func _on_credits_back_button_pressed():
	close_panel(credits_panel)
func _on_how_to_play_back_button_pressed():
	close_panel(how_to_play_panel)
func open_panel(panel):
	set_main_buttons_enabled(false)
	panel.visible=true
	panel.scale=Vector2(0.8,0.8)
	panel.modulate.a=0.0
	var tween=create_tween()
	tween.parallel().tween_property(panel,"scale",Vector2.ONE,0.25)
	tween.parallel().tween_property(panel,"modulate:a",1.0,0.25)
func close_panel(panel):
	var tween=create_tween()
	tween.parallel().tween_property(panel,"scale",Vector2(0.8,0.8),0.2)
	tween.parallel().tween_property(panel,"modulate:a",0.0,0.2)
	await tween.finished
	panel.visible=false
	set_main_buttons_enabled(true)
func _on_music_slider_value_changed(value):
	var music_bus=AudioServer.get_bus_index("Music")
	if value<=0:
		AudioServer.set_bus_volume_db(music_bus,-80.0)
	else:
		AudioServer.set_bus_volume_db(music_bus,linear_to_db(value/100.0))
	SaveManager.settings["music_volume"]=value
	SaveManager.save_settings()
func _on_sfx_slider_value_changed(value):
	var sfx_bus=AudioServer.get_bus_index("SFX")
	if value<=0:
		AudioServer.set_bus_volume_db(sfx_bus,-80.0)
	else:
		AudioServer.set_bus_volume_db(sfx_bus,linear_to_db(value/100.0))
	SaveManager.settings["sfx_volume"]=value
	SaveManager.save_settings()
func apply_settings():
	var music_bus=AudioServer.get_bus_index("Music")
	var sfx_bus=AudioServer.get_bus_index("SFX")
	var music_value=SaveManager.settings["music_volume"]
	var sfx_value=SaveManager.settings["sfx_volume"]
	if music_value<=0:
		AudioServer.set_bus_volume_db(music_bus,-80.0)
	else:
		AudioServer.set_bus_volume_db(music_bus,linear_to_db(music_value/100.0))
	if sfx_value<=0:
		AudioServer.set_bus_volume_db(sfx_bus,-80.0)
	else:
		AudioServer.set_bus_volume_db(sfx_bus,linear_to_db(sfx_value/100.0))
func animate_stat(bar:ProgressBar,value:float):
	var tween=create_tween()
	tween.tween_property(bar,"value",value,0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
func update_vehicle_stats():
	var vehicle=VehicleManager.get_current_vehicle()
	var stats={}
	var is_selected=vehicle["name"]==selected_vehicle_name
	if is_selected:
		stats=VehicleManager.get_final_stats()
	else:
		stats={
			"speed":vehicle.get("speed",0),
			"boost_strength":vehicle.get("boost_strength",0),
			"boost_regen":vehicle.get("boost_regen",0),
			"handling":vehicle.get("handling",0),
			"braking":vehicle.get("braking",0)
		}
	update_stat_bar(speed_bar,stats["speed"],selected_vehicle_stats["speed"],is_selected)
	update_stat_bar(boost_strength_bar,stats["boost_strength"],selected_vehicle_stats["boost_strength"],is_selected)
	update_stat_bar(boost_regen_bar,stats["boost_regen"],selected_vehicle_stats["boost_regen"],is_selected)
	update_stat_bar(handling_bar,stats["handling"],selected_vehicle_stats["handling"],is_selected)
	update_stat_bar(braking_bar,stats["braking"],selected_vehicle_stats["braking"],is_selected)
func update_stat_bar(bar:ProgressBar,value:float,selected_value:float,is_selected:bool):
	animate_stat(bar,value)
	if is_selected:
		set_bar_color(bar,Color(0.2,0.6,1.0))
	elif value>selected_value:
		set_bar_color(bar,Color(1.0,0.75,0.1))
	elif value<selected_value:
		set_bar_color(bar,Color(1.0,0.2,0.2))
	else:
		set_bar_color(bar,Color(0.2,0.6,1.0))
func set_bar_color(bar:ProgressBar,color:Color):
	var fill=bar.get_theme_stylebox("fill")
	if fill is StyleBoxFlat:
		var new_fill=fill.duplicate()
		new_fill.bg_color=color
		bar.add_theme_stylebox_override("fill",new_fill)
func cache_selected_vehicle_stats():
	var vehicle=VehicleManager.get_current_vehicle()
	selected_vehicle_name=vehicle["name"]
	var stats=VehicleManager.get_final_stats()
	selected_vehicle_stats={
		"speed":stats["speed"],
		"boost_strength":stats["boost_strength"],
		"boost_regen":stats["boost_regen"],
		"handling":stats["handling"],
		"braking":stats["braking"]
	}
func apply_vehicle_color():
	if current_car==null:
		return
	var vehicle_name=VehicleManager.get_current_vehicle()["name"]
	var color=SaveManager.get_vehicle_color(vehicle_name)

	for child in current_car.get_children():
		if child is MeshInstance3D:
			var material=child.get_active_material(0)
			if material:
				material=material.duplicate()
				material.albedo_color=color
				child.set_surface_override_material(0,material)
func update_garage():
	for child in vehicle_list.get_children():
		child.queue_free()
	for i in range(VehicleManager.vehicles.size()):
		var vehicle=VehicleManager.vehicles[i]
		var button=Button.new()
		button.custom_minimum_size=Vector2(350,90)
		button.add_theme_font_size_override("font_size",24)
		if vehicle["owned"]:
			button.text=vehicle["name"]
			button.pressed.connect(func(): select_vehicle(i))
		else:
			button.text=" "+vehicle["name"]+"\n "+str(vehicle.get("price",0))+" Coins"
			button.pressed.connect(func(): buy_vehicle_from_garage(i))
		vehicle_list.add_child(button)
func select_vehicle(index):
	if index<0 or index>=VehicleManager.vehicles.size():
		return
	var vehicle=VehicleManager.vehicles[index]
	if not vehicle.get("owned",false):
		return
	VehicleManager.select_vehicle(index)
	SaveManager.save_selected_vehicle(vehicle["name"])
	cache_selected_vehicle_stats()
	update_vehicle()
func buy_vehicle_from_garage(index):
	if index<0 or index>=VehicleManager.vehicles.size():
		return
	var vehicle=VehicleManager.vehicles[index]
	if vehicle["owned"]:
		select_vehicle(index)
		return
	var price=vehicle.get("price",0)
	if SaveManager.get_coins()<price:
		show_not_enough_coins()
		return
	if VehicleManager.buy_vehicle(vehicle["name"]):
		VehicleManager.select_vehicle(index)
		SaveManager.save_selected_vehicle(vehicle["name"])
		cache_selected_vehicle_stats()
		update_coin_display()
		update_garage_coin_display()
		update_garage()
		update_vehicle()
func update_colors():
	for child in color_list.get_children():
		child.queue_free()
	for color_data in VehicleManager.paint_colors:
		var button=Button.new()
		button.text=color_data["name"]
		button.custom_minimum_size=Vector2(250,50)
		button.pressed.connect(func(): change_vehicle_color(color_data["color"]))
		color_list.add_child(button)
func change_vehicle_color(color):
	var vehicle_name=VehicleManager.get_current_vehicle()["name"]
	SaveManager.save_vehicle_color(vehicle_name,color)
	apply_vehicle_color()
func update_wheels():
	for child in wheel_list.get_children():
		child.queue_free()
	for wheel in VehicleManager.wheel_types:
		var button=Button.new()
		button.text=wheel["name"]
		button.custom_minimum_size=Vector2(250,50)
		button.pressed.connect(func(): change_wheels(wheel["name"]))
		wheel_list.add_child(button)
func change_wheels(type):
	var selected_wheel=null
	for wheel in VehicleManager.wheel_types:
		if wheel["name"]==type:
			selected_wheel=wheel
			break
	if selected_wheel:
		VehicleManager.apply_wheel_bonus(selected_wheel)
		update_vehicle_stats()
	if current_car==null:
		return
	var wheel_nodes=[
		"wheel-back-left",
		"wheel-front-right",
		"wheel-front-left",
		"wheel-back-right"
	]
	for wheel_name in wheel_nodes:
		var wheel=current_car.get_node_or_null(wheel_name)
		if wheel==null:
			continue
		match type:
			"Street":
				wheel.scale=Vector3.ONE
				set_wheel_color(wheel,Color(0.15,0.15,0.15))
			"Racing":
				wheel.scale=Vector3(0.85,0.85,0.85)
				set_wheel_color(wheel,Color.BLACK)
			"Offroad":
				wheel.scale=Vector3(1.3,1.3,1.3)
				set_wheel_color(wheel,Color(0.2,0.1,0.05))
			"Turbo":
				wheel.scale=Vector3(1.1,1.1,1.1)
				set_wheel_color(wheel,Color(0,0.8,1))
func set_wheel_color(wheel,color:Color):
	var material=wheel.get_active_material(0)
	if material:
		material=material.duplicate()
		material.albedo_color=color
		wheel.set_surface_override_material(0,material)
func buy_upgrade(type):
	var vehicle=VehicleManager.get_current_vehicle()
	var coins_before=SaveManager.get_coins()
	var bought=SaveManager.buy_upgrade(vehicle["name"],type)
	if bought:
		cache_selected_vehicle_stats()
		update_vehicle_stats()
		update_upgrade_buttons()
		update_upgrade_shop()
		update_coin_display()
		update_garage_coin_display()
		not_enough_coins_panel.visible=false
		return
	var level=SaveManager.get_upgrade_level(vehicle["name"],type)
	if level>=5:
		return
	var cost=SaveManager.upgrade_cost(level)
	if coins_before<cost:
		show_not_enough_coins()
func update_upgrade_shop():
	var vehicle=VehicleManager.get_current_vehicle()
	var upgrades=SaveManager.get_vehicle_upgrades(vehicle["name"])
	engine_level.text="Lv. "+str(upgrades["engine"])
	turbo_level.text="Lv. "+str(upgrades["turbo"])
	regen_level.text="Lv. "+str(upgrades["fuel"])
	handling_level.text="Lv. "+str(upgrades["handling"])
	brakes_level.text="Lv. "+str(upgrades["brakes"])
	update_upgrade_buttons()
func update_upgrade_buttons():
	update_upgrade_card(engine_level,engine_buy,"engine")
	update_upgrade_card(turbo_level,turbo_buy,"turbo")
	update_upgrade_card(regen_level,regen_buy,"fuel")
	update_upgrade_card(handling_level,handling_buy,"handling")
	update_upgrade_card(brakes_level,brakes_buy,"brakes")
func update_upgrade_card(level_label,button,upgrade):
	var vehicle=VehicleManager.get_current_vehicle()
	var level=SaveManager.get_upgrade_level(vehicle["name"],upgrade)
	level_label.text="Level "+str(level)+"/5"
	if level>=5:
		button.text="MAXED"
		button.disabled=true
	else:
		button.text="BUY\n "+str(SaveManager.upgrade_cost(level))
		button.disabled=false
func open_upgrade_panel():
	set_main_buttons_enabled(false)
	upgrade_panel.visible=true
	upgrade_panel.scale=Vector2(0.8,0.8)
	upgrade_panel.modulate.a=0.0
	var tween=create_tween()
	tween.parallel().tween_property(upgrade_panel,"scale",Vector2.ONE,0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(upgrade_panel,"modulate:a",1.0,0.25)
	update_upgrade_buttons()
func close_upgrade_panel():
	var tween=create_tween()
	tween.parallel().tween_property(upgrade_panel,"scale",Vector2(0.8,0.8),0.2)
	tween.parallel().tween_property(upgrade_panel,"modulate:a",0.0,0.2)
	await tween.finished
	upgrade_panel.visible=false
	set_main_buttons_enabled(true)
func show_not_enough_coins():
	if coin_popup_tween and coin_popup_tween.is_valid():
		coin_popup_tween.kill()
	not_enough_coins_panel.visible=true
	not_enough_coins_panel.z_index=100
	not_enough_coins_panel.modulate.a=1.0
	coin_popup_tween=create_tween()
	coin_popup_tween.tween_interval(1.5)
	coin_popup_tween.tween_property(not_enough_coins_panel,"modulate:a",0.0,0.25)
	await coin_popup_tween.finished
	not_enough_coins_panel.visible=false
func update_coin_display():
	coin_label.text="Coins: "+str(SaveManager.get_coins())
func update_garage_coin_display():
	garage_coin_label.text=" Coins: "+str(SaveManager.get_coins())
func _on_back_button_pressed():
	var tween=create_tween()
	tween.parallel().tween_property(garage_panel,"scale",Vector2(0.8,0.8),0.2)
	tween.parallel().tween_property(garage_panel,"modulate:a",0.0,0.2)
	await tween.finished
	garage_panel.visible=false
	set_main_buttons_enabled(true)
func _on_stats_button_pressed():
	update_stats()
	update_achievements()
	set_main_buttons_enabled(false)
	stats_panel.visible=true
	stats_panel.scale=Vector2(0.8,0.8)
	stats_panel.modulate.a=0.0
	var tween=create_tween()
	tween.parallel().tween_property(stats_panel,"scale",Vector2.ONE,0.3)
	tween.parallel().tween_property(stats_panel,"modulate:a",1.0,0.3)
func _on_stats_back_button_pressed():
	var tween=create_tween()
	tween.parallel().tween_property(stats_panel,"scale",Vector2(0.8,0.8),0.2)
	tween.parallel().tween_property(stats_panel,"modulate:a",0.0,0.2)
	await tween.finished
	stats_panel.visible=false
	set_main_buttons_enabled(true)
func update_stats():
	var data=SaveManager.player_data
	stats_label.text=(
		"PLAYER STATS\n\n"+
		"Deliveries: "+str(int(data["total_deliveries"]))+"\n"+
		"Coins Earned: "+str(int(data["total_coins_earned"]))+"\n"+
		"Best Combo: "+str(int(data["best_combo"]))+"x\n"+
		"Longest Delivery: "+str(int(data["longest_delivery"]))+"m\n"+
		"🛣Total Distance: "+str(int(data["total_distance"]))+"m"
	)
func update_achievements():
	var data=SaveManager.player_data
	var a=data["achievements"]
	var deliveries=int(data["total_deliveries"])
	var coins=int(data["total_coins_earned"])
	var combo=int(data["best_combo"])
	var longest=int(data["longest_delivery"])
	var distance=int(data["total_distance"])
	var text="ACHIEVEMENTS\n\n"
	text+=("" if a["first_delivery"] else "")+"First Slice\n"
	text+="Complete your first delivery\n"
	text+="Progress: "+str(min(deliveries,1))+"/1\n\n"
	text+=("" if a["ten_deliveries"] else "")+"Delivery Rookie\n"
	text+="Complete 10 deliveries\n"
	text+="Progress: "+str(min(deliveries,10))+"/10\n\n"
	text+=("" if a["hundred_deliveries"] else "")+"Delivery Expert\n"
	text+="Complete 100 deliveries\n"
	text+="Progress: "+str(min(deliveries,100))+"/100\n\n"
	text+=("" if a["coin_collector"] else "")+"Coin Collector\n"
	text+="Earn 5,000 coins\n"
	text+="Progress: "+str(min(coins,5000))+"/5000\n\n"
	text+=("" if a["rich_driver"] else "")+"Delivery Tycoon\n"
	text+="Earn 25,000 coins\n"
	text+="Progress: "+str(min(coins,25000))+"/25000\n\n"
	text+=("" if a["combo_master"] else "")+"Combo Master\n"
	text+="Reach a 10x combo\n"
	text+="Progress: "+str(min(combo,10))+"/10\n\n"
	text+=("" if a["long_haul"] else "")+"Long Haul\n"
	text+="Complete a 500m delivery\n"
	text+="Progress: "+str(min(longest,500))+"/500m\n\n"
	text+=("" if a["marathon_driver"] else "")+"Road Warrior\n"
	text+="Drive 100 km total\n"
	text+="Progress: "+str(min(distance,100000))+"/100000m\n\n"
	achievements_label.text=text
func set_main_buttons_enabled(enabled:bool):
	$UI/CreditsButton.disabled=not enabled
	$UI/SettingsButton.disabled=not enabled
	$UI/HowToPlayButton.disabled=not enabled
	$UI/GarageButton.disabled=not enabled
	$UI/StatsButton.disabled=not enabled
	$UI/UpgradeButton.disabled=not enabled
