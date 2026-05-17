## DialogueUI：对话 UI
## 支持逐字显示对话文本、多行对话翻页、对话选项选择。
## 通过 EventSystem 与对话发起者（如商人）通信。
extends Control

@onready var speaker_name_label: Label = $PanelContainer/MarginContainer/VBoxContainer/SpeakerNameLabel         # 说话者名称
@onready var dialogue_label: Label = $PanelContainer/MarginContainer/VBoxContainer/DialogueLabel                 # 对话内容
@onready var continue_button: Button = $PanelContainer/MarginContainer/VBoxContainer/ContinueButton             # 继续按钮
@onready var option_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/OptionsContainer   # 选项容器

const DISPLAY_SPEED: float = 10     # 逐字显示速度（字符/秒）

@export var ui_id: UIData.Id = UIData.Id.DialogueUI     # 对话 UI 的 ID

var _speaker_name: String              # 当前说话者名称
var _lines: Array[String]              # 对话内容行列表
var _current_line_idx: int = 0         # 当前显示的对话行索引
var _display_timer: float = 0.0        # 逐字显示计时器

func _ready() -> void:
	EventSystem.dialogue_ui_opened.connect(_on_dialogue_ui_opened)
	continue_button.pressed.connect(on_continue_button_pressed)
	visible = false

## 对话 UI 打开事件回调：显示对话行，等待完成后显示选项
func _on_dialogue_ui_opened(id: UIData.Id, speaker_name: String, lines: Array[String], options: Array[String]) -> void:
	if id != ui_id:
		return
	visible = true
	display_lines(speaker_name, lines)
	await EventSystem.dialogue_finished
	if options.size() > 0:
		display_options(options)
		await EventSystem.dialogue_option_selected
	visible = false

## 继续按钮点击：跳过逐字显示或翻到下一行
func on_continue_button_pressed() -> void:
	if dialogue_label.visible_characters < dialogue_label.get_total_character_count():
		# 还没显示完：直接显示全部文字
		dialogue_label.visible_characters = dialogue_label.get_total_character_count()
	else:
		# 已显示完：翻到下一行
		_current_line_idx += 1
		if _current_line_idx < _lines.size():
			display_line(_speaker_name, _lines[_current_line_idx])
		else:
			# 所有行显示完：结束对话
			EventSystem.finish_dialogue()

## 逐字显示单行对话
func display_line(speaker_name: String, line: String) -> void:
	speaker_name_label.text = speaker_name
	dialogue_label.text = line
	continue_button.visible = true
	dialogue_label.visible_characters = 0
	_display_timer = 0
	while dialogue_label.visible_characters < dialogue_label.get_total_character_count():
		_display_timer += get_process_delta_time()
		dialogue_label.visible_characters = int(DISPLAY_SPEED * _display_timer)
		await get_tree().process_frame

## 显示多行对话（从第一行开始）
func display_lines(speaker_name: String, lines: Array[String]) -> void:
	_speaker_name = speaker_name
	_lines = lines
	_current_line_idx = 0
	display_line(speaker_name, lines[_current_line_idx])

## 显示对话选项：动态创建选项按钮
func display_options(options: Array[String]) -> void:
	continue_button.visible = false
	option_container.visible = true
	for i in range(options.size()):
		var option_button: Button = Button.new()
		option_container.add_child(option_button)
		option_button.text = options[i]
		option_button.pressed.connect(_on_option_button_pressed.bind(i))

## 选项按钮点击：清理选项 UI，发射选择信号
func _on_option_button_pressed(option_idx: int) -> void:
	visible = false
	for child in option_container.get_children():
		child.queue_free()
	option_container.visible = false
	EventSystem.select_dialogue_option(option_idx)
