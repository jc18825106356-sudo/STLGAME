## ResourceSpawner：资源生成器
## 挂载在 Minable 的子节点上，当可开采物体被摧毁时，
## 调用 spawn() 在自身位置生成对应的拾取物品。
class_name ResourceSpawner extends Node2D

@export var spawn_item_id: ItemData.Id     # 生成的物品 ID（在 Inspector 中配置）
@export var spawn_count: int = 1           # 生成的物品数量

## 生成拾取物品：实例化拾取场景并放置到当前场景中
func spawn() -> void:
	var spawned_item: PickupTemplate = ItemData.get_item_pick_scene(spawn_item_id).instantiate()
	get_tree().current_scene.add_child(spawned_item)
	spawned_item.amount = spawn_count
	spawned_item.global_position = global_position
	spawned_item.player_spawn_animation()
