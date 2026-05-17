## MinableSaveData：可开采物体存档数据
## 数据驱动设计：存档数据也使用 Resource，可序列化为 .tres 文件持久化。
class_name MinableSaveData extends Resource

@export var health: int     # 可开采物体的剩余生命值
