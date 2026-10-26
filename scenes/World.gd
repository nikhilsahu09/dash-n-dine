extends Node3D
func _ready():
	TimeManager.setup_world()
	WeatherManager.setup_world()
	var saved_weather = SaveManager.player_data.get("weather", WeatherManager.Weather.CLEAR)
	WeatherManager.change_weather(saved_weather)
	var saved_time = SaveManager.player_data.get("time_of_day", TimeManager.TimeOfDay.DAY)
	TimeManager.change_time(saved_time)
