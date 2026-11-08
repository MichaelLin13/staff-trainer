extends Node
## Autoload「GameSettings」：保存難度設定，並寫入 user://settings.cfg

const SAVE_PATH := "user://settings.cfg"

# 譜號
const TREBLE := 0
const BASS := 1

# 音符種類
const WHOLE := 0
const HALF := 1
const QUARTER := 2
const DURATION_NAMES := ["全音符", "2分音符", "4分音符"]

const MAX_OCTAVES := 2

# 音高用「全音階步數」表示：step = 八度 * 7 + 音名(C=0 … B=6)
# 中央Do (C4) = 4 * 7 + 0 = 28
const MIDDLE_C_STEP := 28

var use_treble := true
var use_bass := false
var octaves := 0                       # 0 = 只在中央Do附近的一個八度
var durations := [true, true, true]    # [全音符, 2分音符, 4分音符]


func _ready() -> void:
	load_settings()


func enabled_clefs() -> Array:
	var result := []
	if use_treble:
		result.append(TREBLE)
	if use_bass:
		result.append(BASS)
	if result.is_empty():
		result.append(TREBLE)
	return result


func enabled_durations() -> Array:
	var result := []
	for i in durations.size():
		if durations[i]:
			result.append(i)
	if result.is_empty():
		result.append(WHOLE)
	return result


## 回傳這個譜號可出題的音域 (最低 step, 最高 step)
## 高音譜：C4(中央Do) ～ C(5+八度數)
## 低音譜：C(3-八度數) ～ C4(中央Do)
func step_range(clef: int) -> Vector2i:
	if clef == TREBLE:
		return Vector2i(MIDDLE_C_STEP, MIDDLE_C_STEP + 7 * (octaves + 1))
	return Vector2i(MIDDLE_C_STEP - 7 * (octaves + 1), MIDDLE_C_STEP)


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("difficulty", "use_treble", use_treble)
	cfg.set_value("difficulty", "use_bass", use_bass)
	cfg.set_value("difficulty", "octaves", octaves)
	cfg.set_value("difficulty", "durations", durations)
	cfg.save(SAVE_PATH)


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	use_treble = cfg.get_value("difficulty", "use_treble", true)
	use_bass = cfg.get_value("difficulty", "use_bass", false)
	octaves = clampi(cfg.get_value("difficulty", "octaves", 0), 0, MAX_OCTAVES)
	var d = cfg.get_value("difficulty", "durations", [true, true, true])
	if d is Array and d.size() == 3:
		durations = d.duplicate()
	if not use_treble and not use_bass:
		use_treble = true
