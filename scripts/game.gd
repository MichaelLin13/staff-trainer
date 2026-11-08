extends Control
## 出題畫面：隨機出題，答對 +1、答錯 -1，滿 10 分回首頁

const NOTE_NAMES := ["Do", "Re", "Mi", "Fa", "So", "La", "Si"]
const TARGET_SCORE := 10
const COLOR_CORRECT := Color("#4caf50")
const COLOR_WRONG := Color("#e05a5a")
const DELAY_CORRECT := 1.0
const DELAY_WRONG := 1.5
const DELAY_FINISH := 2.0

@onready var score_label: Label = %ScoreLabel
@onready var score_bar: ProgressBar = %ScoreBar
@onready var staff: StaffView = %StaffView
@onready var piano: PianoView = %PianoView
@onready var feedback_label: Label = %FeedbackLabel
@onready var back_button: Button = %BackButton
@onready var next_timer: Timer = %NextTimer
@onready var answer_buttons: Array[Button] = [%Answer1, %Answer2, %Answer3]

var score := 0
var _correct_index := -1
var _current_step := 0
var _last_key := ""
var _finished := false


func _ready() -> void:
	back_button.pressed.connect(_go_home)
	next_timer.timeout.connect(_on_next_timer_timeout)
	for i in answer_buttons.size():
		answer_buttons[i].pressed.connect(_on_answer_pressed.bind(i))
	score_bar.max_value = TARGET_SCORE
	_setup_staff_range()
	_update_score()
	_next_question()


func _setup_staff_range() -> void:
	var lo := 999
	var hi := -999
	for c in GameSettings.enabled_clefs():
		var r: Vector2i = GameSettings.step_range(c)
		lo = mini(lo, StaffView.step_to_pos(c, r.x))
		hi = maxi(hi, StaffView.step_to_pos(c, r.y))
	staff.set_view_range(lo, hi)


func _next_question() -> void:
	var clefs := GameSettings.enabled_clefs()
	var durs := GameSettings.enabled_durations()

	# 隨機出題（避免和上一題完全一樣）
	var clef := 0
	var step := 0
	var dur := 0
	var key := ""
	for attempt in 20:
		clef = clefs.pick_random()
		var r: Vector2i = GameSettings.step_range(clef)
		step = randi_range(r.x, r.y)
		dur = durs.pick_random()
		key = "%d_%d_%d" % [clef, step, dur]
		if key != _last_key:
			break
	_last_key = key
	staff.show_note(clef, step, dur)
	_current_step = step
	# 鍵盤提示：開啟時出題就標示，否則答題後才標示
	if GameSettings.show_key_hint:
		piano.set_marker(step)
	else:
		piano.clear_marker()

	# 選項：1 個正確 + 2 個干擾（音名或音符種類不同）
	var correct := [step % 7, dur]
	var candidates := []
	for n in 7:
		for d in durs:
			if not (n == correct[0] and d == correct[1]):
				candidates.append([n, d])
	candidates.shuffle()
	var options := [correct, candidates[0], candidates[1]]
	options.shuffle()

	for i in answer_buttons.size():
		var opt: Array = options[i]
		answer_buttons[i].text = "%s\n(%s)" % [NOTE_NAMES[opt[0]], GameSettings.DURATION_NAMES[opt[1]]]
		answer_buttons[i].disabled = false
		answer_buttons[i].remove_theme_stylebox_override("disabled")
		if opt == correct:
			_correct_index = i
	feedback_label.text = ""


func _on_answer_pressed(index: int) -> void:
	if _finished or not next_timer.is_stopped():
		return
	for b in answer_buttons:
		b.disabled = true
	_tint(answer_buttons[_correct_index], COLOR_CORRECT)
	piano.set_marker(_current_step)

	var delay := DELAY_CORRECT
	if index == _correct_index:
		score += 1
		_show_feedback("答對了！ +1", COLOR_CORRECT)
	else:
		score = maxi(0, score - 1)   # 分數最低為 0
		_tint(answer_buttons[index], COLOR_WRONG)
		_show_feedback("答錯了！ -1　正確答案：" + answer_buttons[_correct_index].text.replace("\n", " "), COLOR_WRONG)
		delay = DELAY_WRONG
	_update_score()

	if score >= TARGET_SCORE:
		_finished = true
		_show_feedback("恭喜完成！拿到 10 分！", COLOR_CORRECT)
		delay = DELAY_FINISH
	next_timer.start(delay)


func _on_next_timer_timeout() -> void:
	if _finished:
		_go_home()
	else:
		_next_question()


func _update_score() -> void:
	score_label.text = "分數：%d / %d" % [score, TARGET_SCORE]
	score_bar.value = score


func _show_feedback(text: String, color: Color) -> void:
	feedback_label.text = text
	feedback_label.add_theme_color_override("font_color", color)


func _tint(button: Button, color: Color) -> void:
	var sb := button.get_theme_stylebox("disabled").duplicate() as StyleBoxFlat
	if sb == null:
		sb = StyleBoxFlat.new()
	sb.bg_color = color
	button.add_theme_stylebox_override("disabled", sb)


func _go_home() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
