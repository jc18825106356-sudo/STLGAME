## CraftingResource：制作配方资源
## 数据驱动设计：制作配方（产物+所需材料列表）存储在 .tres 中，
## 添加新配方只需创建新 .tres 文件，无需修改制作系统代码。
class_name CraftingResource extends Resource

@export var craftable_item_id: ItemData.Id                    # 可制作的物品 ID
@export var requirements: Array[CraftingMaterialResource]     # 制作所需材料列表
