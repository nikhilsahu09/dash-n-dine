extends Node
var has_package:=false
var score:=0
var time_left:=20.0
var combo:=0
var highest_score:=0
enum GameState{COUNTDOWN,PLAYING,GAME_OVER}
var state:=GameState.COUNTDOWN
var countdown:=3.0
var pickup
var dropoff
var pizza_shops=[]
var houses=[]
var car
var hud
var vehicle_swap
var music
var game_over_panel
var current_order={}
var delivery_start:=Vector3.ZERO
var delivery_distance:=0.0
var deliveries_completed:=0
var best_combo:=0
var total_distance:=0.0
var coins_earned:=0
var orders=[
	{"name":"Pepperoni Pizza","reward":50,"time_bonus":2,"rarity":"Common"},
	{"name":"Cheese Pizza","reward":40,"time_bonus":2,"rarity":"Common"},
	{"name":"Veggie Pizza","reward":70,"time_bonus":3,"rarity":"Rare"},
	{"name":"BBQ Chicken Pizza","reward":90,"time_bonus":3,"rarity":"Rare"},
	{"name":"Supreme Pizza","reward":140,"time_bonus":4,"rarity":"Epic"},
	{"name":"Family Feast","reward":250,"time_bonus":5,"rarity":"Legendary"}
]
func _ready():
	SaveManager.load_game()
	highest_score=SaveManager.get_highest_score()
	await get_tree().process_frame
	var scene=get_tree().current_scene
	car=scene.get_node("Kart")
	hud=scene.get_node("HUD2")
	pickup=scene.get_node("PickupPoint")
	dropoff=scene.get_node("DeliveryZone")
	game_over_panel=hud.get_node("UI/GameOverPanel")
	vehicle_swap=car.get_node("VehicleSwap")
	vehicle_swap.change_vehicle(VehicleManager.get_current_vehicle()["path"])
	music=scene.get_node_or_null("GameMusic")
	var spawns=scene.get_node("DeliverySpawns")
	for s in spawns.get_node("PizzaShops").get_children():
		pizza_shops.append(s)
	for h in spawns.get_node("Houses").get_children():
		houses.append(h)
	start_countdown()
func _process(delta):
	if state==GameState.GAME_OVER:
		return
	if state==GameState.COUNTDOWN:
		countdown-=delta
		if countdown<=0:
			state=GameState.PLAYING
			start_round()
		return
	time_left-=delta
	if time_left<=0:
		time_left=0
		combo=0
		state=GameState.GAME_OVER
		stop_game_sounds()
func start_countdown():
	state=GameState.COUNTDOWN
	deliveries_completed=0
	best_combo=0
	total_distance=0
	coins_earned=0
	delivery_distance=0
	countdown=3.0
	score=0
	combo=0
	time_left=20.0
	has_package=false
	pickup.visible=false
	dropoff.visible=false
	if music and !music.playing:
		music.play()
func start_round():
	has_package=false
	delivery_distance=0
	randomize_positions()
	pickup.visible=true
	dropoff.visible=false
func pickup_package():
	if state!=GameState.PLAYING or has_package:
		return
	has_package=true
	generate_order()
	delivery_start=pickup.global_position
	pickup.visible=false
	randomize_dropoff()
	dropoff.visible=true
	_popup("PACKAGE PICKED UP!")
	hud.show_action("PACKAGE ACQUIRED")
	if car.honk:
		car.honk.play()
func deliver_package():
	if state!=GameState.PLAYING or !has_package:
		return
	has_package=false
	delivery_distance=delivery_start.distance_to(dropoff.global_position)
	var distance_bonus=get_distance_reward(delivery_distance)
	var speed_bonus=get_distance_time(delivery_distance)
	combo+=1
	deliveries_completed+=1
	best_combo=max(best_combo,combo)
	total_distance+=delivery_distance
	var combo_bonus=combo*10
	var total_money=current_order["reward"]+distance_bonus+combo_bonus
	score+=total_money
	time_left+=speed_bonus+current_order["time_bonus"]
	SaveManager.add_coins(total_money)
	SaveManager.add_delivery_stats(delivery_distance,combo,total_money)
	SaveManager.player_data["total_deliveries"]+=1
	SaveManager.player_data["total_coins_earned"]+=total_money
	SaveManager.player_data["total_distance"]+=delivery_distance
	if combo>SaveManager.player_data["best_combo"]:
		SaveManager.player_data["best_combo"]=combo
	if delivery_distance>SaveManager.player_data["longest_delivery"]:
		SaveManager.player_data["longest_delivery"]=delivery_distance
	AchievementManager.check_achievements()
	SaveManager.save_game()
	coins_earned+=total_money
	hud.show_money_popup(total_money,speed_bonus+current_order["time_bonus"])
	save_high_score()
	hud.show_action(" DELIVERY COMPLETE!\n +"+str(total_money)+" Coins\n "+str(int(delivery_distance))+"m\n +"+str(speed_bonus)+" sec")
	if car.honk:
		car.honk.play()
	start_round()
func get_distance_reward(distance):
	return clamp(int(distance/5),10,100)
func get_distance_time(distance):
	if distance<50:
		return 2
	if distance<100:
		return 3
	if distance<150:
		return 4
	return 5
func randomize_positions():
	if pizza_shops.is_empty():
		return
	var shop=pizza_shops[randi()%pizza_shops.size()]
	pickup.global_position=shop.global_position
func randomize_dropoff():
	if houses.is_empty():
		return
	var house=houses[randi()%houses.size()]
	dropoff.global_position=house.global_position
func generate_order():
	current_order=orders[randi()%orders.size()]
	hud.show_action(" "+current_order["name"]+"\n "+current_order["rarity"]+"\n Reward: "+str(current_order["reward"]))
func save_high_score():
	if score>highest_score:
		highest_score=score
		SaveManager.save_high_score(score)
func _popup(text):
	if hud:
		hud.show_message(text)
func _on_play_again_button_pressed():
	game_over_panel.visible=false
	start_countdown()
func stop_game_sounds():
	if car:
		if car.engine_sound:
			car.engine_sound.stop()
		if car.turbo_whoosh:
			car.turbo_whoosh.stop()
		if car.honk:
			car.honk.stop()
	if music:
		music.stop()
	var game_over_music=get_tree().current_scene.get_node_or_null("GameOverMusic")
	if game_over_music:
		game_over_music.play()
