## TimeUI：时间显示 UI
## 监听时间系统更新信号，在界面上显示当前游戏时间。
extends Control

@onready var time_label: Label = $MarginContainer/PanelContainer/TimeLabel     # 时间文本标签

func _ready() -> void:
	TimeSystem.time_updated.connect(_on_time_updated)

## 时间更新回调：将时间资源转为字符串显示
func _on_time_updated(time_resource: TimeResource) -> void:
	time_label.text = str(time_resource)
