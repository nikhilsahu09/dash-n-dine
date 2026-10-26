extends Node
enum TimeOfDay {
	DAY,
	SUNSET,
	NIGHT
}
var current_time=TimeOfDay.DAY
var sun
var environment
var sky_material
var headlights=[]
func change_time(time):
	current_time=time
	match time:
		TimeOfDay.DAY:
			day()
		TimeOfDay.SUNSET:
			sunset()
		TimeOfDay.NIGHT:
			night()
	update_headlights()
func day():
	if sun:
		sun.rotation_degrees=Vector3(-50,0,0)
		sun.light_energy=1.2
	if sky_material:
		sky_material.sky_top_color=Color(0.2,0.5,1.0)
		sky_material.sky_horizon_color=Color(0.7,0.9,1.0)
		sky_material.ground_bottom_color=Color(0.1,0.15,0.1)
	if environment and environment.environment:
		environment.environment.ambient_light_energy=1.0
func sunset():
	if sun:
		sun.rotation_degrees=Vector3(-10,0,0)
		sun.light_energy=0.4
	if sky_material:
		sky_material.sky_top_color=Color(0.4,0.15,0.05)
		sky_material.sky_horizon_color=Color(1.0,0.5,0.2)
		sky_material.ground_bottom_color=Color(0.08,0.04,0.02)
	if environment and environment.environment:
		environment.environment.ambient_light_energy=0.6
func night():
	if sun:
		sun.rotation_degrees=Vector3(80,0,0)
		sun.light_energy=0.25
	if environment and environment.environment:
		environment.environment.ambient_light_energy=0.35
	if sky_material:
		sky_material.sky_top_color=Color(0.02,0.03,0.12)
		sky_material.sky_horizon_color=Color(0.08,0.08,0.2)
		sky_material.ground_bottom_color=Color(0.02,0.02,0.03)
func setup_world():
	var scene=get_tree().current_scene
	var car=scene.get_node_or_null("%Kart")
	if car:
		headlights=car.find_children("*","SpotLight3D",true)
	environment=scene.find_child("WorldEnvironment",true,false)
	sun=scene.find_child("Sun",true,false)
	if environment and environment.environment and environment.environment.sky:
		sky_material=environment.environment.sky.sky_material
	update_headlights()
func update_headlights():
	var should_turn_on=current_time==TimeOfDay.NIGHT
	if WeatherManager.current_weather==WeatherManager.Weather.FOG:
		should_turn_on=true
	for light in headlights:
		light.visible=should_turn_on
