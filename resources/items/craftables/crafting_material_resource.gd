## CraftingMaterialResource：制作材料需求资源
## 数据驱动设计：每种材料需求（哪种物品+需要多少）存储在 .tres 中，
## 与 CraftingResource 配合使用，灵活配置配方。
class_name CraftingMaterialResource extends Resource

@export var item_id: ItemData.Id     # 所需材料的物品 ID
@export var amount: int = 1          # 所需数量
