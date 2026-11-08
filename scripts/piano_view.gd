class_name PianoView
extends Control
## 88 鍵鋼琴鍵盤（A0 ～ C8），可在某個白鍵上標示紅點
## 音高用與 GameSettings 相同的「全音階步數」：step = 八度 * 7 + 音名(C=0 … B=6)

const FIRST_STEP := 5        # A0 = 0 * 7 + 5
const WHITE_KEY_COUNT := 52  # A0 ～ C8
const BLACK_AFTER := [0, 1, 3, 4, 5]   # C、D、F、G、A 右邊有黑鍵

const COLOR_FRAME := Color(0.1, 0.1, 0.1)
const COLOR_WHITE := Color(1, 1, 1)
const COLOR_BLACK := Color(0.08, 0.08, 0.08)
const COLOR_LABEL := Color(0.25, 0.25, 0.25)
const COLOR_MARKER := Color(0.9, 0.05, 0.05)

var marker_step := -1        # -1 = 不標示


func set_marker(step: int) -> void:
	marker_step = step
	queue_redraw()


func clear_marker() -> void:
	set_marker(-1)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	var frame := maxf(2.0, size.x * 0.004)
	var inner := Rect2(Vector2(frame, frame), size - Vector2(frame, frame) * 2.0)
	var kw := inner.size.x / WHITE_KEY_COUNT
	var kh := inner.size.y
	var line_w := maxf(1.0, kw * 0.08)

	# 外框
	draw_rect(Rect2(Vector2.ZERO, size), COLOR_FRAME)
	draw_rect(inner, COLOR_WHITE)

	# 白鍵分隔線
	for i in range(1, WHITE_KEY_COUNT):
		var x := inner.position.x + i * kw
		draw_line(Vector2(x, inner.position.y), Vector2(x, inner.end.y), COLOR_FRAME, line_w)

	# 黑鍵
	var bw := kw * 0.6
	var bh := kh * 0.62
	for i in WHITE_KEY_COUNT - 1:
		var letter := (FIRST_STEP + i) % 7
		if letter in BLACK_AFTER:
			var cx := inner.position.x + (i + 1) * kw
			draw_rect(Rect2(cx - bw * 0.5, inner.position.y, bw, bh), COLOR_BLACK)

	# 標籤：A0 與每個 C
	var font := get_theme_default_font()
	var fs := int(clampf(kw * 0.85, 9.0, 22.0))
	for i in WHITE_KEY_COUNT:
		var s := FIRST_STEP + i
		var label := ""
		if i == 0:
			label = "A0"
		elif s % 7 == 0:
			label = "C%d" % (s / 7)
		if label != "":
			var x := inner.position.x + i * kw + kw * 0.12
			draw_string(font, Vector2(x, inner.end.y - kh * 0.06), label,
				HORIZONTAL_ALIGNMENT_LEFT, -1, fs, COLOR_LABEL)

	# 紅點
	var idx := marker_step - FIRST_STEP
	if marker_step >= 0 and idx >= 0 and idx < WHITE_KEY_COUNT:
		var center := Vector2(inner.position.x + (idx + 0.5) * kw, inner.position.y + kh * 0.78)
		var r := kw * 0.4
		draw_circle(center, r, COLOR_MARKER)
		draw_arc(center, r, 0.0, TAU, 24, Color(0.35, 0, 0), maxf(1.0, kw * 0.07), true)
