## ItemSlotUI：物品槽位 UI 组件
## 继承自 Button，显示物品图标和数量，支持拖拽交换物品。
## 拖拽逻辑：拖出时返回自身引用，放入时调用 InventorySystem 交换数据。
class_name ItemSlotUI extends Button

@export var icon_texture: TextureRect     # 物品图标节点
@export var amount_label: Label           # 物品数量文本节点
@export var can_drop: bool = true         # 是否允许拖拽

var _item_id: ItemData.Id                 # 当前槽位的物品 ID
var _inventory_id: InventoryData.Id       # 当前槽位所属的背包 ID
var _item_resource: ItemResource          # 当前物品的资源数据
var _amount: int                          # 当前物品数量

## 初始化槽位：设置物品 ID、数量、所属背包，并更新显示
func set_up(item_id: ItemData.Id, amount: int, inventory_id: InventoryData.Id) -> void:
	_inventory_id = inventory_id
	_item_id = item_id
	_amount = amount
	_item_resource = ItemData.get_item_resource(item_id)
	if item_id == ItemData.Id.NONE:
		# 空槽位：隐藏数量，清空图标
		amount_label.visible = false
		icon_texture.texture = null
	else:
		# 有物品：显示数量和图标
		amount_label.visible = true
		icon_texture.texture = _item_resource.item_icon
		amount_label.text = str(amount)

## 拖拽开始：创建半透明预览图，返回自身作为拖拽数据
func _get_drag_data(at_position: Vector2) -> Variant:
	if not can_drop:
		return null
	if _item_id != ItemData.Id.NONE:
		var drag_preview: TextureRect = TextureRect.new()
		drag_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		drag_preview.texture = icon_texture.texture
		drag_preview.custom_minimum_size = icon_texture.custom_minimum_size
		drag_preview.modulate = Color(1, 1, 1, 0.7)
		drag_preview.z_index = 99
		set_drag_preview(drag_preview)
		return self
	return null

## 判断是否可以接收拖拽数据（只接受 ItemSlotUI 类型）
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not can_drop:
		return false
	return data is ItemSlotUI

## 拖拽放入：调用 InventorySystem 交换两个槽位的物品
func _drop_data(at_position: Vector2, data: Variant) -> void:
	var old_slot: ItemSlotUI = data as ItemSlotUI
	var new_slot: ItemSlotUI = self
	InventorySystem.drag_inventory_item(old_slot.get_index(), old_slot._inventory_id, new_slot.get_index(), new_slot._inventory_id)
