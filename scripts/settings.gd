extends Control
## 難度設定：譜號、音域（八度數）、音符種類

@onready var treble_check: CheckBox = %TrebleCheck
@onready var bass_check: CheckBox = %BassCheck
@onready var octave_option: OptionButton = %OctaveOption
@onready var range_label: Label = %RangeLabel
@onready var duration_checks: Array[CheckBox] = [%WholeCheck, %HalfCheck, %QuarterCheck]
@onready var hint_label: Label = %HintLabel
@onready var back_button: Button = %BackButton


func _ready() -> void:
	# 讀入目前設定
	treble_check.button_pressed = GameSettings.use_treble
	bass_check.button_pressed = GameSettings.use_bass
	octave_option.clear()
	for i in GameSettings.MAX_OCTAVES + 1:
		octave_option.add_item("%d 個八度" % i, i)
	octave_option.select(GameSettings.octaves)
	for i in duration_checks.size():
		duration_checks[i].button_pressed = GameSettings.durations[i]

	treble_check.toggled.connect(_on_clef_toggled.bind(treble_check))
	bass_check.toggled.connect(_on_clef_toggled.bind(bass_check))
	octave_option.item_selected.connect(_on_octave_selected)
	for c in duration_checks:
		c.toggled.connect(_on_duration_toggled.bind(c))
	back_button.pressed.connect(_on_back_pressed)

	hint_label.text = ""
	_update_range_label()


func _on_clef_toggled(pressed: bool, source: CheckBox) -> void:
	if not pressed and not treble_check.button_pressed and not bass_check.button_pressed:
		source.set_pressed_no_signal(true)
		hint_label.text = "至少要選一種譜號"
		return
	hint_label.text = ""
	GameSettings.use_treble = treble_check.button_pressed
	GameSettings.use_bass = bass_check.button_pressed
	_update_range_label()


func _on_duration_toggled(pressed: bool, source: CheckBox) -> void:
	var any_on := false
	for c in duration_checks:
		any_on = any_on or c.button_pressed
	if not pressed and not any_on:
		source.set_pressed_no_signal(true)
		hint_label.text = "至少要選一種音符"
		return
	hint_label.text = ""
	for i in duration_checks.size():
		GameSettings.durations[i] = duration_checks[i].button_pressed


func _on_octave_selected(index: int) -> void:
	GameSettings.octaves = octave_option.get_item_id(index)
	_update_range_label()


func _update_range_label() -> void:
	var n := GameSettings.octaves
	var lines := []
	if GameSettings.use_treble:
		lines.append("高音譜：C4(中央Do) ～ C%d" % (5 + n))
	if GameSettings.use_bass:
		lines.append("低音譜：C%d ～ C4(中央Do)" % (3 - n))
	range_label.text = "\n".join(lines)


func _on_back_pressed() -> void:
	GameSettings.save_settings()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
