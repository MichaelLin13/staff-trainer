extends Control
## 首頁：開始、難度設定

@onready var start_button: Button = %StartButton
@onready var settings_button: Button = %SettingsButton
@onready var summary_label: Label = %SummaryLabel


func _ready() -> void:
	start_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/game.tscn"))
	settings_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/settings.tscn"))
	summary_label.text = _summary()


func _summary() -> String:
	var clefs := []
	if GameSettings.use_treble:
		clefs.append("高音譜")
	if GameSettings.use_bass:
		clefs.append("低音譜")
	var durs := []
	for d in GameSettings.enabled_durations():
		durs.append(GameSettings.DURATION_NAMES[d])
	return "譜號：%s\n音域：%d 個八度\n音符：%s" % [
		"、".join(clefs), GameSettings.octaves, "、".join(durs)]
