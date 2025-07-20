extends Node3D

const RAY_LENGTH = 1000


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


var recent_result = {}

func create_hole():
	var newHole = $"../Hole".duplicate()
	newHole.position = Vector3(recent_result.position.x, 0, recent_result.position.z)
	newHole.visible = true
	get_parent().add_child(newHole)


func _physics_process(delta):
	var space_state = get_world_3d().direct_space_state
	var cam = $"../Camera3D"
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	recent_result = result
	
	if result.has("position"):
		position = result.position
	else:
		print("Mouse raycast didn't hit anything")
		return
	
	if Input.is_action_just_pressed("mouse_click_left"):
		$AnimationPlayer.play("dig_anim")
