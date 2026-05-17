## SaveButton：保存按钮
## 点击时触发全局保存事件，所有注册了 data_save 信号的系统都会保存数据。
extends Button

func _ready() -> void:
	pressed.connect(_on_save_button_pressed)

## 按钮点击回调：触发全局保存
func _on_save_button_pressed() -> void:
	EventSystem.save_data()
