extends Node3D

const HOLE = preload("res://scenes/objects/hole.tscn")
const RAY_LENGTH = 1000
var min_x = -0.8
var min_z = -0.1
var max_x = 0.8
var max_z = 0.8
var dig_position = Vector3.ZERO

@onready var target: Area3D = $"../Target"
@onready var shovel_area: Area3D = $ShovelArea
@onready var metal_detector_lines: TextureRect = $"../CanvasLayer/MetalDetector/Lines"
@onready var treasure_popup: ColorRect = $"../CanvasLayer/TreasurePopup"
@onready var orpheus_chair: Sprite3D = $"../OrpheusChair"


func open_chest(chest, hole):
	var anim_player: AnimationPlayer = hole.find_child("AnimationPlayer", true, false)
	anim_player.play("chest_rise")
	await anim_player.animation_finished
	await get_tree().create_timer(1).timeout
	chest.visible = false
	treasure_popup.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	target.position = Vector3(randf_range(min_x, max_x), 0.078248, randf_range(min_z, max_z))
	await get_tree().physics_frame
	await get_tree().physics_frame
	for i in range(10): # if new target is overlapping a hole, move the target. retry 10 times
		var overlapping_hole = false
		for area in target.get_overlapping_areas():
			if area.name == "HoleArea":
				overlapping_hole = true
				target.position = Vector3(randf_range(min_x, max_x), 0.078248, randf_range(min_z, max_z))
				await get_tree().physics_frame
				print("Target moved")
				break
		if not overlapping_hole:
			print("Target stayed")
			break
	
	get_tree().paused = true


func create_hole():
	for area in shovel_area.get_overlapping_areas(): # check for small holes in the area
		if area.name == "HoleArea":
			
			var hole = area.get_parent()
			var holeMesh = hole.find_child("HoleMesh", true, false)
			var sandRingMesh = hole.find_child("SandRingMesh", true, false)
			var chest = hole.find_child("chest", true, false)
			
			if holeMesh.mesh.size != Vector2(0.25, 0.25):
				sandRingMesh.scale += Vector3(0.25, 0.25, 0.25)
				holeMesh.mesh.size += Vector2(0.05, 0.05)
				chest.position.y += 0.02
				if holeMesh.mesh.size == Vector2(0.25, 0.25) and chest.visible:
					open_chest(chest, hole) # open chest if in hole and has been dug 3 times
				return
			else:
				continue # continue the loop in case there is still a small hole in the area
	
	var newHole = HOLE.instantiate()
	newHole.position = Vector3(dig_position.x, 0, dig_position.z)
	get_parent().add_child(newHole)
	var target_overlapped = false
	for area in shovel_area.get_overlapping_areas():
		if area == target:
			newHole.get_node("chest").visible = true
			target_overlapped = true
	
	if not target_overlapped:
		orpheus_chair.texture = load("res://textures/OrpheusConfused.png")
		await get_tree().create_timer(1.5).timeout
		orpheus_chair.texture = load("res://textures/OrpheusMotivational.png")


func _ready() -> void:
	target.position = Vector3(randf_range(min_x, max_x), 0.078248, randf_range(min_z, max_z))


func _physics_process(delta):
	var space_state = get_world_3d().direct_space_state
	var cam = $"../Camera3D"
	var mouse_pos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mouse_pos)
	var end = origin + cam.project_ray_normal(mouse_pos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = false

	var result = space_state.intersect_ray(query)
	
	if result.has("position"):
		position = result.position.clamp(Vector3(min_x, -1, min_z), Vector3(max_x, 1, max_z))
		dig_position = position
		
		var distance_from_target = roundi(position.distance_to(target.position) * 10)
		
		if distance_from_target < 10:
			metal_detector_lines.texture = load("res://textures/metal-detector/" + str(distance_from_target) + ".png")
		else:
			metal_detector_lines.texture = load("res://textures/metal-detector/Off.png")
		
		if Input.is_action_just_pressed("mouse_click_left"):
			$AnimationPlayer.play("dig_anim")
			#if distance_from_target == 0:
				#target.position = Vector3(randf_range(min_x, max_x), 0.078248, randf_range(min_z, max_z))
	else:
		print("Mouse raycast didn't hit anything")
		return
