extends Node
var settings={
	"music_volume":0.0,
	"sfx_volume":0.0,
	"screen_shake":true,
	"camera_sensitivity":1.0
}
var player_data={
	"highest_score":0,
	"pizza_coins":0,
	"time_of_day":0,
	"selected_vehicle":"Ambulance",
	"weather":0,
	"total_coins_earned":0,
	"total_deliveries":0,
	"total_distance":0,
	"longest_delivery":0,
	"best_combo":0,
	"achievements":{
		"first_delivery":false,
		"ten_deliveries":false,
		"hundred_deliveries":false,
		"coin_collector":false,
		"rich_driver":false,
		"combo_master":false,
		"speed_demon":false,
		"marathon_driver":false,
		"long_haul":false,
		"weather_warrior":false,
		"night_owl":false
	},
	"owned_vehicles":[
		"Ambulance",
		"Delivery",
		"Kart",
		"SUV",
		"Taxi",
		"Van"
	],
	"vehicle_upgrades":{},
	"vehicle_colors":{},
	"vehicle_customization":{}
}
const SAVE_PATH="user://player_save.save"
func save_game():
	var file=FileAccess.open(SAVE_PATH,FileAccess.WRITE)
	if file:
		file.store_var({
			"settings":settings,
			"player_data":player_data
		})
func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found. Using default data.")
		return
	var file=FileAccess.open(SAVE_PATH,FileAccess.READ)
	if file==null:
		print("ERROR: Could not open save file.")
		return
	var data=file.get_var()
	if data.has("settings"):
		for key in settings.keys():
			if data["settings"].has(key):
				settings[key]=data["settings"][key]
	if data.has("player_data"):
		var loaded=data["player_data"]
		for key in player_data.keys():
			if loaded.has(key):
				player_data[key]=loaded[key]
	if player_data.has("coins"):
		player_data["pizza_coins"]=player_data["coins"]
		player_data.erase("coins")
	if not player_data.has("pizza_coins"):
		player_data["pizza_coins"]=0
	if not player_data.has("owned_vehicles"):
		player_data["owned_vehicles"]=["Ambulance","Delivery","Kart","SUV","Taxi","Van"]
	print("SAVE LOADED")
func save_settings():
	save_game()
func load_settings():
	load_game()
func get_coins():
	return player_data["pizza_coins"]
func add_coins(amount):
	player_data["pizza_coins"]+=amount
	save_game()
func spend_coins(amount):
	if player_data["pizza_coins"]>=amount:
		player_data["pizza_coins"]-=amount
		save_game()
		return true
	return false
func is_vehicle_owned(vehicle_name):
	return vehicle_name in player_data["owned_vehicles"]
func unlock_vehicle(vehicle_name):
	if not is_vehicle_owned(vehicle_name):
		player_data["owned_vehicles"].append(vehicle_name)
		save_game()
func save_selected_vehicle(vehicle_name):
	player_data["selected_vehicle"]=vehicle_name
	save_game()
func set_selected_vehicle(vehicle_name):
	save_selected_vehicle(vehicle_name)
func get_selected_vehicle():
	return player_data.get("selected_vehicle","Ambulance")
func get_highest_score():
	return player_data["highest_score"]
func save_high_score(score):
	if score>player_data["highest_score"]:
		player_data["highest_score"]=score
		save_game()
func save_vehicle_color(vehicle_name,color):
	player_data["vehicle_colors"][vehicle_name]=color
	save_game()
func get_vehicle_color(vehicle_name):
	if player_data["vehicle_colors"].has(vehicle_name):
		return player_data["vehicle_colors"][vehicle_name]
	return Color.WHITE
func save_vehicle_customization(vehicle_name,data):
	player_data["vehicle_customization"][vehicle_name]=data
	save_game()
func get_vehicle_customization(vehicle_name):
	if player_data["vehicle_customization"].has(vehicle_name):
		return player_data["vehicle_customization"][vehicle_name]
	return {
		"wheel_bonus":{
			"speed":0,
			"boost_strength":0,
			"boost_regen":0,
			"handling":0,
			"braking":0
		},
		"upgrade_bonus":{
			"speed":0,
			"boost_strength":0,
			"boost_regen":0,
			"handling":0,
			"braking":0
		}
	}
func get_vehicle_upgrades(vehicle_name):
	if not player_data["vehicle_upgrades"].has(vehicle_name):
		player_data["vehicle_upgrades"][vehicle_name]={
			"engine":0,
			"turbo":0,
			"fuel":0,
			"handling":0,
			"brakes":0
		}
	return player_data["vehicle_upgrades"][vehicle_name]
func get_upgrade_level(vehicle_name,upgrade):
	var upgrades=get_vehicle_upgrades(vehicle_name)
	return upgrades.get(upgrade,0)
func upgrade_cost(level):
	match level:
		0:
			return 100
		1:
			return 250
		2:
			return 500
		3:
			return 900
		4:
			return 1500
		_:
			return 999999
func get_upgrade_cost(vehicle_name,upgrade):
	return upgrade_cost(get_upgrade_level(vehicle_name,upgrade))
func buy_upgrade(vehicle_name,upgrade):
	var current_level=get_upgrade_level(vehicle_name,upgrade)
	if current_level>=5:
		return false
	var cost=upgrade_cost(current_level)
	if spend_coins(cost):
		player_data["vehicle_upgrades"][vehicle_name][upgrade]+=1
		save_game()
		return true
	return false
func upgrade_vehicle(vehicle_name,upgrade):
	return buy_upgrade(vehicle_name,upgrade)
func add_delivery_stats(distance,combo,coins):
	player_data["total_deliveries"]+=1
	player_data["total_distance"]+=distance
	player_data["total_coins_earned"]+=coins
	if distance>player_data["longest_delivery"]:
		player_data["longest_delivery"]=distance
	if combo>player_data["best_combo"]:
		player_data["best_combo"]=combo
	save_game()
func reset_player_data():
	player_data={
		"highest_score":0,
		"pizza_coins":0,
		"time_of_day":0,
		"selected_vehicle":"Ambulance",
		"weather":0,
		"total_coins_earned":0,
		"total_deliveries":0,
		"total_distance":0,
		"longest_delivery":0,
		"best_combo":0,
		"achievements":{
			"first_delivery":false,
			"ten_deliveries":false,
			"hundred_deliveries":false,
			"coin_collector":false,
			"rich_driver":false,
			"combo_master":false,
			"speed_demon":false,
			"marathon_driver":false,
			"long_haul":false,
			"weather_warrior":false,
			"night_owl":false
		},
		"owned_vehicles":[
			"Ambulance",
			"Delivery",
			"Kart",
			"SUV",
			"Taxi",
			"Van"
		],
		"vehicle_upgrades":{},
		"vehicle_colors":{},
		"vehicle_customization":{}
	}
	save_game()
	print("PLAYER DATA RESET")
