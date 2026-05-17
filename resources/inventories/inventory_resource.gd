## InventoryResource：背包资源
## 数据驱动设计：背包的配置（ID、容量、初始物品列表）存储在 .tres 中，
## 策划可以在编辑器中设置背包容量和初始物品，无需改代码。
class_name InventoryResource extends Resource

@export var inventory_id: InventoryData.Id                   # 背包 ID
@export var inventory_capacity: int = 28                     # 背包容量（槽位数量）
@export var inventory_items: Array[ItemSlotResource]         # 背包中的物品列表
