## PlantableFieldSaveData：可种植田地存档数据
## 数据驱动设计：存档数据使用 Resource，可序列化为 .tres 文件持久化。
class_name PlantableFieldSaveData extends Resource

@export var field_state: int                     # 田地状态（对应 field_state_enum 的整数值）
@export var seed_id: ItemData.Id                 # 种下的种子 ID
@export var growth_stage_idx: int                # 当前生长阶段索引
@export var end_stage_time: TimeResource         # 当前阶段结束时间
