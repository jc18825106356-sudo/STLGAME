## EquipmentUI：装备栏 UI（继承自 InventoryUI）
## 点击物品槽位时触发装备事件，将物品装备到玩家身上。
extends InventoryUI

## 点击槽位时装备物品
func _on_item_slot_selected(item_id: ItemData.Id) -> void:
	EventSystem.equip_item(item_id)
