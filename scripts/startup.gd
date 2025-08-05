extends TextureRect


func _ready() -> void:
	modulate.a = 0.0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 3.0)
	$StartupAudio.play()
	await get_tree().create_timer(7).timeout
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 2.0)
	await tween.finished
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://scenes/main.tscn")
