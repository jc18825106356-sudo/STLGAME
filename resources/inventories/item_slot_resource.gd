## ItemSlotResource：物品槽位资源
## 数据驱动设计：每个背包槽位的数据（放什么物品、放了多少）存储在 .tres 中，
## 是背包系统的最小数据单元。
class_name ItemSlotResource extends Resource

@export var item_id: ItemData.Id = ItemData.Id.NONE     # 槽位中的物品 ID（NONE=空槽位）
@export var item_amount: int = 0                         # 槽位中的物品数量
