extends Node
var vehicles=[
	{"name":"Ambulance","path":"res://vehicles/models/ambulance.glb","speed":75,"boost_strength":70,"boost_regen":55,"handling":65,"braking":70,"price":0,"owned":true,"description":"A dependable emergency vehicle with balanced performance.","wheel_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0},"upgrade_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0}},
	{"name":"Delivery","path":"res://vehicles/models/delivery.glb","speed":65,"boost_strength":60,"boost_regen":75,"handling":75,"braking":80,"price":0,"owned":true,"description":"A reliable starter vehicle built for everyday deliveries.","wheel_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0},"upgrade_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0}},
	{"name":"Firetruck","path":"res://vehicles/models/firetruck.glb","speed":45,"boost_strength":35,"boost_regen":90,"handling":40,"braking":60,"price":1500,"owned":false,"description":"A heavy vehicle with weak speed but incredible boost recovery.","wheel_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0},"upgrade_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0}},
	{"name":"Garbage Truck","path":"res://vehicles/models/garbagetruck.glb","speed":35,"boost_strength":25,"boost_regen":100,"handling":35,"braking":70,"price":2000,"owned":false,"description":"Extremely slow, but has the best boost regeneration.","wheel_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0},"upgrade_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0}},
	{"name":"Hatchback Sports","path":"res://vehicles/models/hatchback.glb","speed":90,"boost_strength":80,"boost_regen":50,"handling":85,"braking":75,"price":5000,"owned":false,"description":"A lightweight sports car focused on speed and cornering.","wheel_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0},"upgrade_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0}},
	{"name":"Kart","path":"res://vehicles/models/kart.glb","speed":60,"boost_strength":90,"boost_regen":95,"handling":95,"braking":80,"price":0,"owned":true,"description":"Tiny, fast, and extremely agile. The handling champion.","wheel_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0},"upgrade_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0}},
	{"name":"Police","path":"res://vehicles/models/police.glb","speed":95,"boost_strength":90,"boost_regen":55,"handling":85,"braking":80,"price":3500,"owned":false,"description":"A high-speed interceptor designed for chasing targets.","wheel_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0},"upgrade_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0}},
	{"name":"Race Future","path":"res://vehicles/models/racecar.glb","speed":100,"boost_strength":100,"boost_regen":40,"handling":90,"braking":85,"price":10000,"owned":false,"description":"The ultimate racing machine with maximum performance.","wheel_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0},"upgrade_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0}},
	{"name":"Sedan Sports","path":"res://vehicles/models/sedan.glb","speed":85,"boost_strength":80,"boost_regen":60,"handling":80,"braking":75,"price":6000,"owned":false,"description":"A balanced sports sedan with great all-around stats.","wheel_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0},"upgrade_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0}},
	{"name":"SUV","path":"res://vehicles/models/suv.glb","speed":70,"boost_strength":60,"boost_regen":80,"handling":65,"braking":80,"price":0,"owned":true,"description":"A strong and stable vehicle made for control.","wheel_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0},"upgrade_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0}},
	{"name":"Taxi","path":"res://vehicles/models/taxi.glb","speed":75,"boost_strength":65,"boost_regen":75,"handling":75,"braking":80,"price":0,"owned":true,"description":"A dependable city vehicle with balanced abilities.","wheel_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0},"upgrade_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0}},
	{"name":"Tractor","path":"res://vehicles/models/tractor.glb","speed":30,"boost_strength":20,"boost_regen":100,"handling":25,"braking":50,"price":1000,"owned":false,"description":"Very slow but nearly impossible to run out of boost.","wheel_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0},"upgrade_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0}},
	{"name":"Truck","path":"res://vehicles/models/truck.glb","speed":50,"boost_strength":40,"boost_regen":85,"handling":45,"braking":70,"price":2500,"owned":false,"description":"A powerful heavy vehicle with great stability.","wheel_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0},"upgrade_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0}},
	{"name":"Van","path":"res://vehicles/models/van.glb","speed":60,"boost_strength":55,"boost_regen":80,"handling":65,"braking":75,"price":0,"owned":true,"description":"A practical delivery van with balanced performance.","wheel_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0},"upgrade_bonus":{"speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0}}
]
var current_vehicle:=0
var upgrade_costs=[100,250,500,900,1500]
var wheel_types=[
	{"name":"Street","speed":0,"boost_strength":0,"boost_regen":0,"handling":0,"braking":0},
	{"name":"Racing","speed":5,"boost_strength":0,"boost_regen":0,"handling":10,"braking":5},
	{"name":"Offroad","speed":-5,"boost_strength":0,"boost_regen":0,"handling":5,"braking":10},
	{"name":"Turbo","speed":10,"boost_strength":10,"boost_regen":-5,"handling":-5,"braking":0}
]
var paint_colors=[
	{"name":"Red","color":Color(1,0,0)},
	{"name":"Blue","color":Color(0,0.4,1)},
	{"name":"Black","color":Color(0.05,0.05,0.05)},
	{"name":"Green","color":Color(0,1,0.2)},
	{"name":"Gold","color":Color(1,0.8,0)}
]
func _ready():
	load_from_save()
	load_selected_vehicle()
	print("SELECTED VEHICLE: ",get_current_vehicle()["name"])
	print("SELECTED PATH: ",get_current_vehicle()["path"])
	print("FINAL STATS: ",get_final_stats())
func get_current_vehicle():
	return vehicles[current_vehicle]
func next_vehicle():
	current_vehicle+=1
	if current_vehicle>=vehicles.size():
		current_vehicle=0
	SaveManager.set_selected_vehicle(vehicles[current_vehicle]["name"])
func previous_vehicle():
	current_vehicle-=1
	if current_vehicle<0:
		current_vehicle=vehicles.size()-1
	SaveManager.set_selected_vehicle(vehicles[current_vehicle]["name"])
func select_vehicle(index:int):
	if index<0 or index>=vehicles.size():
		return
	var vehicle=vehicles[index]
	if not vehicle["owned"]:
		return
	current_vehicle=index
	SaveManager.set_selected_vehicle(vehicle["name"])
func buy_vehicle(vehicle_name):
	for vehicle in vehicles:
		if vehicle["name"]!=vehicle_name:
			continue
		if vehicle["owned"]:
			print("Already owned: ",vehicle_name)
			return false
		var price=vehicle.get("price",0)
		if SaveManager.get_coins()<price:
			print("Not enough coins for ",vehicle_name)
			return false
		if SaveManager.spend_coins(price):
			vehicle["owned"]=true
			SaveManager.unlock_vehicle(vehicle_name)
			print("PURCHASED: ",vehicle_name)
			print("Price: ",price)
			return true
	return false
func unlock_vehicle(vehicle_name):
	for vehicle in vehicles:
		if vehicle["name"]==vehicle_name:
			vehicle["owned"]=true
			SaveManager.unlock_vehicle(vehicle_name)
			print("UNLOCKED VEHICLE: ",vehicle_name)
			return
func check_unlocks(score):
	return
func apply_wheel_bonus(wheel):
	var vehicle=get_current_vehicle()
	vehicle["wheel_bonus"]={
		"speed":wheel.get("speed",0),
		"boost_strength":wheel.get("boost_strength",0),
		"boost_regen":wheel.get("boost_regen",0),
		"handling":wheel.get("handling",0),
		"braking":wheel.get("braking",0)
	}
	save_current_customization()
func get_final_stats():
	var vehicle=get_current_vehicle()
	var stats={
		"speed":vehicle["speed"],
		"boost_strength":vehicle["boost_strength"],
		"boost_regen":vehicle["boost_regen"],
		"handling":vehicle["handling"],
		"braking":vehicle["braking"]
	}
	if vehicle.has("wheel_bonus"):
		for stat in vehicle["wheel_bonus"]:
			stats[stat]+=vehicle["wheel_bonus"][stat]
	var upgrades=SaveManager.get_vehicle_upgrades(vehicle["name"])
	stats["speed"]+=upgrades["engine"]*10
	stats["boost_strength"]+=upgrades["turbo"]*5
	stats["boost_regen"]+=upgrades["fuel"]*5
	stats["handling"]+=upgrades["handling"]*5
	stats["braking"]+=upgrades["brakes"]*5
	return stats
func get_owned_vehicles():
	var owned=[]
	for vehicle in vehicles:
		if vehicle["owned"]:
			owned.append(vehicle)
	return owned
func get_locked_vehicles():
	var locked=[]
	for vehicle in vehicles:
		if not vehicle["owned"]:
			locked.append(vehicle)
	return locked
func load_selected_vehicle():
	var saved_name=SaveManager.get_selected_vehicle()
	if saved_name=="":
		current_vehicle=0
		SaveManager.set_selected_vehicle(vehicles[current_vehicle]["name"])
		return
	for i in range(vehicles.size()):
		if vehicles[i]["name"]==saved_name:
			if vehicles[i]["owned"]:
				current_vehicle=i
				return
			break
	current_vehicle=0
	SaveManager.set_selected_vehicle(vehicles[current_vehicle]["name"])
func load_from_save():
	for vehicle in vehicles:
		vehicle["owned"]=SaveManager.is_vehicle_owned(vehicle["name"])
		var custom=SaveManager.get_vehicle_customization(vehicle["name"])
		if custom:
			if custom.has("wheel_bonus"):
				vehicle["wheel_bonus"]=custom["wheel_bonus"]
			if custom.has("upgrade_bonus"):
				vehicle["upgrade_bonus"]=custom["upgrade_bonus"]
func save_current_customization():
	var vehicle=get_current_vehicle()
	var data={"wheel_bonus":vehicle["wheel_bonus"],"upgrade_bonus":vehicle["upgrade_bonus"]}
	SaveManager.save_vehicle_customization(vehicle["name"],data)
