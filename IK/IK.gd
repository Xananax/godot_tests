extends Node2D
var Solver = preload("/IK/analytical_2d_ik_solver.gd")
onready var Target = get_node("Arm/Target")
onready var Limb1 = get_node("Arm/Limb1")
onready var Limb2 = get_node("Arm/Limb2")
onready var EndPoint = get_node("Arm/EndPoint")
onready var Text = get_node("Label")

var limb1_length
var limb2_length
var limb1_angle
var limb2_angle

func _ready():
	limb1_length = Limb1.get_pos().distance_to(Limb2.get_pos())
	limb2_length = Limb2.get_pos().distance_to(EndPoint.get_pos())
	update_target(get_viewport().get_mouse_pos())
	set_process_input(true)
	set_process(true)
	
func _input(ev):
	if ev.type == InputEvent.MOUSE_MOTION:
		update_target(ev.pos)

func update_target(pos):
	Target.set_global_pos(pos)

func _process(delta):
	var valid_solution = Solver.set(Limb1,Limb2,limb1_length,limb2_length,Target.get_pos(),true)
	if valid_solution:
		Text.set_text("valid solution")
	else:
		Text.set_text("invalid solution")

