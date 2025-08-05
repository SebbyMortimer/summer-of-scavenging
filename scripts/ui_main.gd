extends CanvasLayer


@onready var main_menu_audio: AudioStreamPlayer = $MainMenu/MainMenuAudio
@onready var gold_coins_label: Label = $GoldCoinsContainer/GoldCoinsLabel
@export var shovel_scene: PackedScene
var config: ConfigFile = ConfigFile.new()
var gold_coins: int = 0

# How many chests the player has received on the current round
var round_chests: int = 0


func set_up_data():
	var err = config.load("user://data.cfg")
	# If the file didn't load, ignore it.
	if err != OK:
		return
	
	gold_coins = config.get_value("data", "gold_coins")
	gold_coins_label.text = str(gold_coins)


func _ready() -> void:
	main_menu_audio.play()
	$MainMenu.visible = true
	$"../MainMenuCam".current = true
	
	set_up_data()


func _on_play_button_pressed() -> void:
	main_menu_audio.stop()
	$MainMenu.visible = false
	$MetalDetector.visible = true
	$GoldCoinsContainer.visible = true
	$Countdown.visible = true
	$"../Camera3D".current = true
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var shovel = shovel_scene.instantiate()
	shovel.rotation_degrees.z = 15
	get_parent().add_child(shovel)
	
	get_tree().paused = true
	
	$GameStart.visible = true
	$GameStart/CountAudio.play()
	await get_tree().create_timer(1).timeout
	$GameStart/Count.text = "2"
	await get_tree().create_timer(1).timeout
	$GameStart/Count.text = "1"
	await get_tree().create_timer(1).timeout
	$GameStart/Count.text = "Start!"
	await get_tree().create_timer(1).timeout
	$GameStart.visible = false
	$BackgroundAudio.play()
	$Countdown/Timer.start()
	
	get_tree().paused = false


func _on_treasure_button_pressed() -> void:
	$TreasurePopup.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false
	gold_coins += 100
	gold_coins_label.text = str(gold_coins)
	config.set_value("data", "gold_coins", gold_coins)
	config.save("user://data.cfg")
	round_chests += 1


func _process(delta: float) -> void:
	$Countdown.text = "0:%02d" % [$Countdown/Timer.time_left]


func _on_timer_timeout() -> void:
	$FinishedPopup/MarginContainer/VBoxContainer/Chests.text = "Chests: " + str(round_chests)
	$FinishedPopup/MarginContainer/VBoxContainer/Coins.text = "Coins: " + str(round_chests * 100)
	$FinishedPopup.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true


func _on_play_again_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
