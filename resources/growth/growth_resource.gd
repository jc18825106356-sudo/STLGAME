## GrowthResource：作物生长配置资源
## 数据驱动设计：作物的完整生长过程（种子→成熟）存储在 .tres 中，
## 添加新作物只需创建新的 .tres 文件，种植系统代码无需修改。
class_name GrowthResource extends Resource

@export var seed_id: ItemData.Id                          # 种子物品 ID
@export var crop_id: ItemData.Id                          # 成熟作物物品 ID
@export var growth_stages: Array[GrowthStageResource]     # 生长阶段列表（按顺序排列）
