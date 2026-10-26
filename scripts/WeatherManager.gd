extends Node
enum Weather {
	CLEAR,
	RAIN,
	FOG
}
var current_weather=Weather.CLEAR
var environment
var rain
var car
func _ready():
	print("WeatherManager ready")
func change_weather(weather):
	current_weather=weather
	if weather==Weather.CLEAR:
		clear_weather()
	elif weather==Weather.RAIN:
		rain_weather()
	elif weather==Weather.FOG:
		fog_weather()
	TimeManager.update_headlights()
func clear_weather():
	if rain:
		rain.emitting=false
	if environment and environment.environment:
		environment.environment.fog_enabled=false
func rain_weather():
	if rain:
		rain.emitting=true
	if environment and environment.environment:
		environment.environment.fog_enabled=false
func fog_weather():
	if rain:
		rain.emitting=false
	if environment and environment.environment:
		environment.environment.fog_enabled=true
		environment.environment.fog_density=0.015
func random_weather():
	change_weather(randi_range(0,2))
func _process(_delta):
	if rain and car:
		rain.global_position=car.global_position+Vector3(0,25,0)
func setup_world():
	environment=get_tree().current_scene.find_child("WorldEnvironment",true,false)
	rain=get_tree().current_scene.find_child("RainParticles",true,false)
	car=get_tree().current_scene.find_child("Kart",true,false)
	print("WEATHER SETUP")
	print(environment)
	print(rain)
