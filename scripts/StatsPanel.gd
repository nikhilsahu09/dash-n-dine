extends Panel
@onready var stats_label=$StatsLabel
@onready var achievements_label=$AchievementsLabel
func _ready():
	update_stats()
	update_achievements()
func update_stats():
	var data=SaveManager.player_data
	var deliveries=int(data.get("total_deliveries",0))
	var coins=int(data.get("total_coins_earned",0))
	var combo=int(data.get("best_combo",0))
	var longest=int(round(data.get("longest_delivery",0.0)))
	var distance=int(round(data.get("total_distance",0.0)))
	stats_label.text=" PLAYER STATS\n\n"+" Deliveries: "+str(deliveries)+"\n"+" Coins Earned: "+str(coins)+"\n"+" Best Combo: "+str(combo)+"x\n"+" Longest Delivery: "+str(longest)+"m\n"+" Total Distance: "+str(distance)+"m"
func update_achievements():
	var data=SaveManager.player_data
	var a=data["achievements"]
	var deliveries=int(data.get("total_deliveries",0))
	var coins=int(data.get("total_coins_earned",0))
	var combo=int(data.get("best_combo",0))
	var longest=int(data.get("longest_delivery",0))
	var distance=int(data.get("total_distance",0))
	var text="🏆 ACHIEVEMENTS\n\n"
	text+=achievement_text(a["first_delivery"],"First Slice","Complete your first delivery",deliveries,1,"")
	text+=achievement_text(a["ten_deliveries"],"Delivery Rookie","Complete 10 deliveries",deliveries,10,"")
	text+=achievement_text(a["hundred_deliveries"],"Delivery Expert","Complete 100 deliveries",deliveries,100,"")
	text+=achievement_text(a["coin_collector"],"Coin Collector","Earn 5,000 coins",coins,5000,"")
	text+=achievement_text(a["rich_driver"],"Delivery Tycoon","Earn 25,000 coins",coins,25000,"")
	text+=achievement_text(a["combo_master"],"Combo Master","Reach a 10x combo",combo,10,"")
	text+=achievement_text(a["long_haul"],"Long Haul","Complete a 500m delivery",longest,500,"m")
	text+=achievement_text(a["marathon_driver"],"Road Warrior","Drive 10,000m total",distance,10000,"m")
	achievements_label.text=text
func achievement_text(unlocked:bool,title:String,description:String,progress:int,goal:int,unit:String)->String:
	var icon="" if unlocked else ""
	return icon+" "+title+"\n"+description+"\nProgress: "+str(min(progress,goal))+"/"+str(goal)+unit+"\n\n"
