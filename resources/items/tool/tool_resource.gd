## ToolResource：工具资源（继承自 ItemResource）
## 数据驱动设计：工具的攻击力、动画名、攻击间隔等属性在 .tres 中配置，
## 不同工具只需创建不同的 .tres 文件，代码完全复用。
class_name ToolResource extends ItemResource

@export var damage: int = 0                        # 工具伤害值（用于开采、战斗等）
@export var use_tool_animation: StringName         # 使用工具时播放的动画名称
@export var hit_delay: float = 0.7                 # 攻击间隔时间（秒）
