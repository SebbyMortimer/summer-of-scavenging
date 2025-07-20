extends CanvasLayer


@onready var main_menu_audio: AudioStreamPlayer = $MainMenuContainer/MainMenuAudio


func _ready() -> void:
	main_menu_audio.play()


func _on_play_button_pressed() -> void:
	main_menu_audio.stop()
	$MainMenuContainer.visible = false
	$BackgroundAudio.play()
