## InventorySystem：背包管理系统（全局单例）
## 负责所有背包的加载、增删物品、拖拽交换、存档/读档。
## 数据驱动设计：背包数据存储在 InventoryResource（.tres）中，
## 代码只操作数据层，UI 通过信号监听数据变化来刷新显示。
extends Node

## 信号：背包数据加载完成
signal inventories_loaded()
## 信号：指定背包数据更新（UI 监听此信号刷新显示）
signal inventory_updated(inventory_id: InventoryData.Id)

## 所有背包数据的运行时缓存：键=背包ID，值=物品槽位数组
var _inventories: Dictionary[InventoryData.Id, Array]
## 玩家金币数量
var player_coins: int = 30

func _ready() -> void:
	EventSystem.data_save.connect(_on_data_save)

## 保存回调：遍历所有背包并逐一保存
func _on_data_save() -> void:
	for inventory_id in InventoryData.Id.values():
		save_inventory_data(inventory_id)

## 加载所有背包数据：从存档文件或默认资源中读取
func load_inventories():
	for inventory_id in InventoryData.Id.values():
		var inventory_resource: InventoryResource = load_inventory_data(inventory_id)
		if inventory_resource == null:
			continue
		var inventory_items: Array[ItemSlotResource] = inventory_resource.inventory_items
		# 如果物品数量不足容量，用空槽位补齐
		for i in range(inventory_resource.inventory_capacity - inventory_items.size()):
			inventory_items.append(ItemSlotResource.new())
		_inventories[inventory_id] = inventory_items
	inventories_loaded.emit()

## 获取指定背包的物品槽位数组
func get_inventory(inventory_id: InventoryData.Id) -> Array[ItemSlotResource]:
	if not _inventories.has(inventory_id):
		return []
	return _inventories[inventory_id]

## 往指定背包添加物品，遵守堆叠上限规则
## 返回值：放不下的剩余数量（0 表示全部放入）
func add_item(item_id: ItemData.Id, inventory_id: InventoryData.Id, amount: int = 1) -> int:
	var item_resource: ItemResource = ItemData.get_item_resource(item_id)
	if item_resource == null:
		print("Error: Could not find resource for item_id: ", item_id)
		return amount

	# 找出可用的格子：同类物品格子（可叠加）+ 空格子
	var slots_for_item: Array[ItemSlotResource] = get_valid_slots_for_item(item_id, inventory_id)
	for slot in slots_for_item:
		# 空格子先标记为当前物品
		if slot.item_id == ItemData.Id.NONE:
			slot.item_id = item_id
		# 计算当前格子还能放多少
		var remaining_capacity: int = item_resource.max_stack_amount - slot.item_amount
		if remaining_capacity >= amount:
			slot.item_amount += amount
			amount = 0
			break
		else:
			# 装不满就先装满当前格子，继续塞下一个
			amount -= remaining_capacity
			slot.item_amount = item_resource.max_stack_amount
	# 通知 UI 刷新
	inventory_updated.emit(inventory_id)
	print("Remaining:" + str(amount))
	return amount

## 从指定背包移除指定数量的物品
func remove_item(item_id: ItemData.Id, inventory_id: InventoryData.Id, amount: int = 1) -> void:
	var item_slots: Array[ItemSlotResource] = get_target_slots(item_id, inventory_id)
	for slot in item_slots:
		var remaining: int = amount - slot.item_amount
		if remaining >= 0:
			# 当前格子数量不够扣，清空格子继续扣下一个
			amount = remaining
			slot.item_amount = 0
			slot.item_id = ItemData.Id.NONE
		else:
			# 当前格子数量足够，直接扣除
			slot.item_amount -= amount
			break
	inventory_updated.emit(inventory_id)

## 获取指定背包中包含指定物品的所有槽位
func get_target_slots(item_id: ItemData.Id, inventory_id: InventoryData.Id) -> Array[ItemSlotResource]:
	return _inventories[inventory_id].filter(func(slot: ItemSlotResource): return slot.item_id == item_id)

## 获取指定背包中可以放入该物品的槽位（同类+空格）
func get_valid_slots_for_item(item_id: ItemData.Id, inventory_id: InventoryData.Id) -> Array[ItemSlotResource]:
	return _inventories[inventory_id].filter(func(slot: ItemSlotResource): return slot.item_id == item_id or slot.item_id == ItemData.Id.NONE)

## 拖拽交换物品：在两个背包的指定索引位置之间移动物品
func drag_inventory_item(origin_item_idx: int, origin_inventory_id: InventoryData.Id, target_item_idx: int, target_inventory_id: InventoryData.Id) -> void:
	# 同一位置不处理
	if origin_item_idx == target_item_idx and origin_inventory_id == target_inventory_id:
		return
	var origin_inventory: Array[ItemSlotResource] = _inventories[origin_inventory_id]
	var target_inventory: Array[ItemSlotResource] = _inventories[target_inventory_id]
	print(origin_inventory[origin_item_idx])
	print(target_inventory[target_item_idx])

	if origin_inventory[origin_item_idx].item_id == target_inventory[target_item_idx].item_id:
		# 同类物品：尝试堆叠
		var item_resource: ItemResource = ItemData.get_item_resource(origin_inventory[origin_item_idx].item_id)
		if item_resource == null:
			return
		if target_inventory[target_item_idx].item_amount < item_resource.max_stack_amount:
			var remaining: int = item_resource.max_stack_amount - target_inventory[target_item_idx].item_amount
			if origin_inventory[origin_item_idx].item_amount > remaining:
				# 来源格子数量超过目标剩余容量：先装满目标，来源扣除
				target_inventory[target_item_idx].item_amount = item_resource.max_stack_amount
				origin_inventory[origin_item_idx].item_amount -= remaining
			else:
				# 来源格子数量不超过目标剩余容量：全部移入目标
				target_inventory[target_item_idx].item_amount += origin_inventory[origin_item_idx].item_amount
				origin_inventory[origin_item_idx].item_amount = 0
				origin_inventory[origin_item_idx].item_id = ItemData.Id.NONE
	else:
		# 不同物品：直接交换两个格子的数据
		var tmp = origin_inventory[origin_item_idx]
		origin_inventory[origin_item_idx] = target_inventory[target_item_idx]
		target_inventory[target_item_idx] = tmp

	InventorySystem.inventory_updated.emit(origin_inventory_id)
	InventorySystem.inventory_updated.emit(target_inventory_id)

## 统计指定背包中某物品的总数量
func get_item_count(item_id: ItemData.Id, inventory_id: InventoryData.Id) -> int:
	var item_slots: Array[ItemSlotResource] = get_target_slots(item_id, inventory_id)
	var count = 0
	for slot in item_slots:
		count += slot.item_amount
	return count

## 保存指定背包数据到 user:// 目录
func save_inventory_data(inventory_id: InventoryData.Id) -> void:
	var inventory_resource: InventoryResource = InventoryData.get_inventory_resource(inventory_id)
	if inventory_resource == null:
		return
	inventory_resource.inventory_items = get_inventory(inventory_id)
	var save_path: StringName = "user://inventory_" + str(inventory_id) + ".tres"
	ResourceSaver.save(inventory_resource, save_path)
	print("Save data at: " + ProjectSettings.globalize_path(save_path))

## 加载指定背包数据：优先从存档读取，不存在则使用默认资源
func load_inventory_data(inventory_id: InventoryData.Id) -> InventoryResource:
	var load_path: StringName = "user://inventory_" + str(inventory_id) + ".tres"
	if not ResourceLoader.exists(load_path):
		return InventoryData.get_inventory_resource(inventory_id)
	return ResourceLoader.load(load_path)
