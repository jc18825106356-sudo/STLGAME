## Chest：宝箱交互物体
## 继承自 Interactable，玩家交互时打开宝箱 UI 和玩家背包 UI，
## 同时切换宝箱的开关外观。交互结束时自动关闭外观。
extends Interactable

@onready var chest_Closed: Sprite2D = $ChestClosed     # 关闭状态的精灵
@onready var chest_Opened: Sprite2D = $ChestOpened     # 打开状态的精灵

## 宝箱对应的背包 ID（在 Inspector 中配置，决定宝箱内容）
@export var inventory_id: InventoryData.Id

func _ready() -> void:
	EventSystem.interaction_ended.connect(_close_chest)

## 切换为打开外观
func _open_chest() -> void:
	chest_Opened.visible = true
	chest_Closed.visible = false

## 切换为关闭外观
func _close_chest() -> void:
	print("关闭显示")
	chest_Opened.visible = false
	chest_Closed.visible = true

## 交互入口：打开玩家背包和宝箱背包 UI
func interactor(player: CharacterBody2D) -> void:
	super(player)
	EventSystem.start_interaction()
	EventSystem.open_inventory_ui(UIData.Id.PlayerInventoryUI, InventoryData.Id.PlayerInventory)
	EventSystem.open_inventory_ui(UIData.Id.ChestUI, inventory_id)
	_open_chest()
