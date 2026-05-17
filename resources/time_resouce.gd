## TimeResource：时间数据资源
## 数据驱动设计：时间数据（天、时、分、秒）作为 Resource 存储，
## 可在编辑器中配置（如生长时间、任务时间等），也可序列化保存到存档。
class_name TimeResource extends Resource

@export_range(0, 59) var seconds: int = 0     # 秒（0-59）
@export_range(0, 59) var minutes: int = 0     # 分（0-59）
@export_range(0, 23) var hours: int = 0       # 时（0-23）
@export var days: int = 0                      # 天数（无上限）

## 构造函数：创建时间资源
func _init(d: int = 0, hr: int = 0, min: int = 0, sec: int = 0) -> void:
	days = d
	hours = clamp(hr, 0, 23)
	minutes = clamp(min, 0, 59)
	seconds = clamp(sec, 0, 59)

## 转为字符串显示（如 "1Day 09Hr 30Min "）
func _to_string() -> String:
	var result: String = ""
	result += str(days)
	result += "Day "
	result += str(hours) if hours >= 10 else "0" + str(hours)
	result += "Hr "
	result += str(minutes) if minutes >= 10 else "0" + str(minutes)
	result += "Min "
	return result
