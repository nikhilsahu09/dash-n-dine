extends Node
var achievement_queue=[]
var showing_achievement=false
func check_achievements():
	var data=SaveManager.player_data
	var a=data["achievements"]
	if data["total_deliveries"]>=1 and !a["first_delivery"]:
		a["first_delivery"]=true
		show_achievement(" First Slice","Complete your first delivery")
	if data["total_deliveries"]>=10 and !a["ten_deliveries"]:
		a["ten_deliveries"]=true
		show_achievement(" Delivery Rookie","Complete 10 deliveries")
	if data["total_deliveries"]>=100 and !a["hundred_deliveries"]:
		a["hundred_deliveries"]=true
		show_achievement(" Delivery Expert","Complete 100 deliveries")
	if data["total_coins_earned"]>=5000 and !a["coin_collector"]:
		a["coin_collector"]=true
		show_achievement(" Coin Collector","Earn 5,000 coins")
	if data["total_coins_earned"]>=25000 and !a["rich_driver"]:
		a["rich_driver"]=true
		show_achievement(" Delivery Tycoon","Earn 25,000 coins")
	if data["best_combo"]>=10 and !a["combo_master"]:
		a["combo_master"]=true
		show_achievement(" Combo Master","Reach a 10x combo")
	if data["longest_delivery"]>=500 and !a["long_haul"]:
		a["long_haul"]=true
		show_achievement(" Long Haul","Complete a 500m delivery")
	if data["total_distance"]>=10000 and !a["marathon_driver"]:
		a["marathon_driver"]=true
		show_achievement(" Road Warrior","Drive 10,000m total")
	SaveManager.save_game()
func show_achievement(name,description):
	achievement_queue.append({"name":name,"description":description})
	if !showing_achievement:
		display_next_achievement()
func display_next_achievement():
	if achievement_queue.is_empty():
		showing_achievement=false
		return
	showing_achievement=true
	var achievement=achievement_queue.pop_front()
	var popup=get_tree().current_scene.find_child("AchievementPopup",true,false)
	if popup==null:
		showing_achievement=false
		return
	popup.text=" ACHIEVEMENT UNLOCKED!\n\n"+achievement["name"]+"\n"+achievement["description"]
	popup.visible=true
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(popup):
		popup.visible=false
	await get_tree().create_timer(0.5).timeout
	display_next_achievement()
