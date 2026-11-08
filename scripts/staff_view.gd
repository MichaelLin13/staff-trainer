class_name StaffView
extends Control
## 畫出五線譜、譜號與一個音符（含加線、符桿）
## 譜號與符頭使用 Bravura 音樂字型 (SMuFL 標準，1 em = 4 個線間距)

const MUSIC_FONT: Font = preload("res://fonts/Bravura.otf")

# SMuFL 字元
const GLYPH_G_CLEF := "\uE050"
const GLYPH_F_CLEF := "\uE062"
const GLYPH_WHOLE := "\uE0A2"
const GLYPH_HALF := "\uE0A3"
const GLYPH_BLACK := "\uE0A4"

# 符頭寬度（單位：線間距，來自 Bravura 字型資料）
const WIDTH_WHOLE := 1.688
const WIDTH_HALF := 1.18
const STEM_ATTACH_Y := 0.168
const STEM_THICKNESS := 0.12
const STEM_LENGTH := 3.5

# 五線譜最下面那條線的音高 (step)
# 高音譜第一線 = E4 = 4*7+2 = 30；低音譜第一線 = G2 = 2*7+4 = 18
const BOTTOM_LINE_STEP := {0: 30, 1: 18}

var clef := 0          # GameSettings.TREBLE / BASS
var step := 28         # 音高
var duration := 0      # GameSettings.WHOLE / HALF / QUARTER
var ink_color := Color.BLACK

# 畫面要容納的上下範圍（單位：半格，0 = 第一線，8 = 第五線）
var view_min_pos := -4
var view_max_pos := 12


## 依難度設定的音域調整畫面縮放，讓加線不會超出畫面
func set_view_range(min_step_pos: int, max_step_pos: int) -> void:
	view_min_pos = mini(min_step_pos - 2, -4)
	view_max_pos = maxi(max_step_pos + 2, 12)
	queue_redraw()


## 計算某譜號下某音高在譜上的位置（半格）
static func step_to_pos(c: int, s: int) -> int:
	return s - BOTTOM_LINE_STEP[c]


func show_note(new_clef: int, new_step: int, new_duration: int) -> void:
	clef = new_clef
	step = new_step
	duration = new_duration
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color.WHITE)

	# 線間距：依要容納的範圍決定大小，並讓範圍置中
	var span_spaces := (view_max_pos - view_min_pos) * 0.5 + 1.0
	var sp: float = minf(size.y / span_spaces, size.x / 10.0)
	var center_pos := (view_min_pos + view_max_pos) * 0.5
	var bottom_y := size.y * 0.5 + center_pos * sp * 0.5
	var left := sp * 0.6
	var right := size.x - sp * 0.6
	var font_size := int(round(sp * 4.0))

	# 五條線
	var line_w := maxf(1.0, sp * 0.13)
	for i in 5:
		var y := bottom_y - i * sp
		draw_line(Vector2(left, y), Vector2(right, y), ink_color, line_w)

	# 譜號（SMuFL：高音譜號基準點在第二線 G，低音譜號在第四線 F）
	var clef_x := left + sp * 0.5
	if clef == 0:
		draw_string(MUSIC_FONT, Vector2(clef_x, bottom_y - sp), GLYPH_G_CLEF,
			HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, ink_color)
	else:
		draw_string(MUSIC_FONT, Vector2(clef_x, bottom_y - 3.0 * sp), GLYPH_F_CLEF,
			HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, ink_color)

	# 音符位置：pos = 0 在第一線，每 +1 往上半格
	var pos: int = step - BOTTOM_LINE_STEP[clef]
	var note_y := bottom_y - pos * sp * 0.5
	var head_w := WIDTH_WHOLE if duration == 0 else WIDTH_HALF
	var center_x := lerpf(left, right, 0.62)
	var head_x := center_x - head_w * sp * 0.5

	# 加線
	var ledger_half := (head_w * 0.5 + 0.4) * sp
	var ledger_w := maxf(1.0, sp * 0.16)
	var k := -2
	while k >= pos:
		var ly := bottom_y - k * sp * 0.5
		draw_line(Vector2(center_x - ledger_half, ly), Vector2(center_x + ledger_half, ly), ink_color, ledger_w)
		k -= 2
	k = 10
	while k <= pos:
		var ly := bottom_y - k * sp * 0.5
		draw_line(Vector2(center_x - ledger_half, ly), Vector2(center_x + ledger_half, ly), ink_color, ledger_w)
		k += 2

	# 符頭
	var glyph := GLYPH_WHOLE
	if duration == 1:
		glyph = GLYPH_HALF
	elif duration == 2:
		glyph = GLYPH_BLACK
	draw_string(MUSIC_FONT, Vector2(head_x, note_y), glyph,
		HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, ink_color)

	# 符桿（全音符沒有）：第三線以下朝上，第三線（含）以上朝下；
	# 離很遠時符桿延伸到第三線
	if duration != 0:
		var stem_w := STEM_THICKNESS * sp
		var middle_y := bottom_y - 2.0 * sp
		if pos < 4:
			var sx := head_x + head_w * sp - stem_w * 0.5
			var y_end := minf(note_y - STEM_LENGTH * sp, middle_y)
			draw_line(Vector2(sx, note_y - STEM_ATTACH_Y * sp), Vector2(sx, y_end), ink_color, stem_w)
		else:
			var sx := head_x + stem_w * 0.5
			var y_end := maxf(note_y + STEM_LENGTH * sp, middle_y)
			draw_line(Vector2(sx, note_y + STEM_ATTACH_Y * sp), Vector2(sx, y_end), ink_color, stem_w)
