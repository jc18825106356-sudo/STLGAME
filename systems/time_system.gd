## TimeSystem：游戏时间系统（全局单例）
## 管理游戏内的时间流逝，支持加速、时间比较、存档/读档。
## 数据驱动设计：时间数据使用 TimeResource（.tres）存储，
## 可在编辑器中配置初始时间，运行时动态计算。
extends Node

## 信号：时间更新，携带当前时间资源（UI 监听此信号刷新显示）
signal time_updated(time_resource: TimeResource)

## 时间常量
const SECONDS: int = 60    # 每分钟的秒数
const MINUTES: int = 60    # 每小时的分钟数
const HOURS: int = 24      # 每天的小时数

## 当前游戏时间（默认第0天9点0分0秒）
var current_time: TimeResource = TimeResource.new(0, 9, 0, 0)
## 每现实秒对应的游戏秒数（控制时间流速，值越大时间越快）
var ticks_per_second: int = 1200
## 累计的帧间隔时间，用于判断是否该推进一秒
var delta_time: float = 0.0

func _ready() -> void:
	EventSystem.data_save.connect(save_data)
	load_data()

## 推进一秒，并处理进位（秒→分→时→天）
func increase_by_second() -> void:
	current_time.seconds += 1
	if current_time.seconds >= SECONDS:
		current_time.seconds = 0
		current_time.minutes += 1
		if current_time.minutes >= MINUTES:
			current_time.minutes = 0
			current_time.hours += 1
			if current_time.hours >= HOURS:
				current_time.hours = 0
				current_time.days += 1

## 每帧检查是否该推进时间
func _process(delta: float) -> void:
	if delta_time >= float(1.0 / float(ticks_per_second)):
		increase_by_second()
		time_updated.emit(current_time)
		delta_time = 0
	else:
		delta_time += delta

## 计算从当前时间起经过指定时长后的时间点
func get_time_after(time_resource: TimeResource) -> TimeResource:
	var result: TimeResource = current_time.duplicate()
	result.seconds += time_resource.seconds
	if result.seconds >= SECONDS:
		result.seconds -= SECONDS
		result.minutes += 1
	result.minutes += time_resource.minutes
	if result.minutes >= MINUTES:
		result.minutes -= MINUTES
		result.hours += 1
	result.hours += time_resource.hours
	if result.hours >= HOURS:
		result.hours -= HOURS
		result.days += 1
	return result

## 判断当前时间是否已经超过了指定时间点
func has_passed(time_resource: TimeResource) -> bool:
	if current_time.days == time_resource.days:
		if current_time.hours == time_resource.hours:
			if current_time.minutes == time_resource.minutes:
				return current_time.seconds > time_resource.seconds
			else:
				return current_time.minutes > time_resource.minutes
		else:
			return current_time.hours > time_resource.hours
	else:
		return current_time.days > time_resource.days

## 保存当前时间到 user:// 目录
func save_data() -> void:
	var save_path: StringName = "user://time_data.tres"
	ResourceSaver.save(current_time, save_path)

## 加载时间数据：无存档则使用默认时间
func load_data() -> void:
	var save_path: StringName = "user://time_data.tres"
	if not ResourceLoader.exists(save_path):
		current_time = TimeResource.new(0, 9, 0, 0)
	else:
		current_time = ResourceLoader.load(save_path)
