## GameScene：游戏主场景控制器
## 负责初始化游戏系统（加载背包、连接时间系统），
## 并根据游戏时间调整环境光照颜色，模拟昼夜变化。
extends Node

@onready var sun: DirectionalLight2D = $Sun     # 太阳光源节点

@export var color_gradient: GradientTexture1D   # 昼夜颜色渐变（在 Inspector 中配置）

func _ready():
	TimeSystem.time_updated.connect(_on_time_updated)
	InventorySystem.load_inventories()

## 时间更新回调：根据当前时间在渐变中采样，调整太阳光颜色
func _on_time_updated(time_resource: TimeResource) -> void:
	var percentage: float = float(time_resource.hours * 60 + time_resource.minutes) / float(24 * 60)
	sun.color = color_gradient.gradient.sample(percentage)
