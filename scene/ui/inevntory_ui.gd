## InventoryUI：背包 UI 基类
## 所有背包相关 UI（玩家背包、宝箱、交易、制作等）的父类。
## 监听全局事件打开/关闭 UI，根据背包数据动态生成物品槽位，
## 支持鼠标悬停显示物品描述、拖拽交换物品、关闭按钮等。
class_name InventoryUI extends Control

@export var iu_id: UIData.Id                         # 本 UI 的 ID（用于匹配打开事件）
@export var item_slot_container: Container           # 物品槽位的容器节点
@export var item_slot_ui_scene: PackedScene          # 物品槽位 UI 的场景预制体
@export var description_label: Label                 # 物品描述文本标签
@export var close_Button: Button                     # 关闭按钮

var _inventory_id: InventoryData.Id                  # 当前绑定的背包 ID
var _item_slots: Array[ItemSlotUI] = []              # 当前 UI 中的物品槽位列表

func _ready() -> void:
	EventSystem.inventory_ui_opened.connect(_on_inventory_ui_opened)
	InventorySystem.inventory_updated.connect(_on_inventory_updated)
	if close_Button != null:
		close_Button.visible = false
		close_Button.pressed.connect(_on_close_button_pressed)
	visible = false

## 背包 UI 打开事件回调：匹配 ID 后刷新并显示 UI
func _on_inventory_ui_opened(Id: UIData.Id, inventory_id: InventoryData.Id) -> void:
	if Id != iu_id:
		return
	if close_Button != null:
		close_Button.visible = true
	_update_inventory_ui(inventory_id)
	visible = true

## 刷新背包 UI：清空旧槽位，根据背包数据重新生成
func _update_inventory_ui(inventory_id: InventoryData.Id) -> void:
	_inventory_id = inventory_id
	# 清空容器中的旧槽位节点
	for slot in item_slot_container.get_children():
		slot.queue_free()
	_item_slots.clear()
	# 遍历背包数据，为每个槽位创建 UI
	for item in InventorySystem.get_inventory(inventory_id):
		var item_slot_ui: ItemSlotUI = item_slot_ui_scene.instantiate()
		item_slot_container.add_child(item_slot_ui)
		item_slot_ui.set_up(item.item_id, item.item_amount, inventory_id)
		item_slot_ui.pressed.connect(_on_item_slot_selected.bind(item.item_id))
		item_slot_ui.mouse_entered.connect(_on_mouse_entered.bind(item.item_id))
		_item_slots.append(item_slot_ui)

## 槽位被点击时的回调（子类可重写，如装备栏点击装备物品）
func _on_item_slot_selected(item_id: ItemData.Id) -> void:
	pass

## 鼠标悬停槽位时更新描述文本
func _on_mouse_entered(item_id: ItemData.Id) -> void:
	if description_label == null:
		return
	if item_id == ItemData.Id.NONE:
		description_label.text = ""
		return
	var item_resource: ItemResource = ItemData.get_item_resource(item_id)
	if item_resource == null:
		description_label.text = "Unknown Item"
		return
	description_label.text = item_resource.item_name + "\n" + item_resource.item_description

## 关闭按钮回调：隐藏 UI 并结束交互
func _on_close_button_pressed() -> void:
	visible = false
	close_Button.visible = false
	EventSystem.end_interaction()

## 背包数据更新回调：如果当前 UI 正在显示该背包，则刷新
func _on_inventory_updated(inventory_id: InventoryData.Id) -> void:
	if not visible or _inventory_id != inventory_id:
		return
	_update_inventory_ui(inventory_id)
