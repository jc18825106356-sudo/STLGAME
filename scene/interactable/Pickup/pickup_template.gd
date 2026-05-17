## PickupTemplate：可拾取物品模板
## 继承自 Interactable，玩家交互时将物品添加到背包中。
## 背包满了则保留剩余数量，全部拾取后自动销毁自身。
class_name PickupTemplate extends Interactable

@export var item_id: ItemData.Id     # 拾取的物品 ID（在 Inspector 中配置）
@export var amount: int = 1          # 拾取的物品数量

## 交互入口：尝试将物品添加到玩家背包
func interactor(player: CharacterBody2D) -> void:
	super(player)
	var remaining: int = InventorySystem.add_item(item_id, InventoryData.Id.PlayerInventory, amount)
	if remaining > 0:
		# 背包满了，保留未放入的数量
		amount = remaining
	else:
		# 全部放入背包，销毁自身
		queue_free()

## 生成时的弹出动画（向上弹起一小段距离）
func player_spawn_animation() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", global_position + Vector2.DOWN * 8, 0.2)
