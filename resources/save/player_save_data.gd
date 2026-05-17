## PlayerSaveData：玩家存档数据
## 数据驱动设计：存档数据使用 Resource，可序列化为 .tres 文件持久化。
class_name PlayerSaveData extends Resource

@export var player_global_position: Vector2     # 玩家在世界中的位置
@export var player_coins: int                    # 玩家持有的金币数量
