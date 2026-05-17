## GrowthStageResource：作物生长阶段资源
## 数据驱动设计：每个生长阶段的持续时间、外观、偏移都存储在 .tres 中，
## 策划可以精确控制作物每个阶段的表现。
class_name GrowthStageResource extends Resource

@export var growing_time: TimeResource              # 本阶段生长所需时间
@export var stage_sprite: Texture2D                 # 本阶段显示的精灵图
@export var sprite_offset: Vector2 = Vector2.ZERO   # 精灵偏移量（用于对齐田地）
