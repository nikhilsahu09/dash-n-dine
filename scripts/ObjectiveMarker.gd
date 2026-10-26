extends Node3D
@export var bob_height:=0.3
@export var bob_speed:=2.0
var start_y:float
func _ready():
	start_y=position.y
func _process(_delta):
	position.y=start_y+sin(Time.get_ticks_msec()*0.001*bob_speed)*bob_height
