## CraftingUI：制作 UI（继承自 InventoryUI）
## 左侧显示可制作物品列表，右侧显示选中物品的配方和制作按钮。
## 数据驱动设计：可制作物品列表从 ItemData.CRAFTING_RESOURCE_PATH 动态生成，
## 添加新配方只需创建 .tres 文件，无需修改 UI 代码。
extends InventoryUI

@onready var craft_description_label: Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/CraftDescriptionLabel     # 配方描述
@onready var craft_button: Button = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/CraftButton                         # 制作按钮
@onready var craftable_item_container: VBoxContainer = $PanelContainer/MarginContainer/HBoxContainer/CraftableItemScroll/CraftableItemContainer  # 可制作物品列表容器

@export var craftable_item_ui_scene: PackedScene      # 可制作物品 UI 的场景预制体

var _crafting_item_id: ItemData.Id                    # 当前选中的可制作物品 ID

func _ready() -> void:
	super()
	craft_button.pressed.connect(_on_craft_button_pressed)

## UI 打开回调：首次打开时生成可制作物品列表
func _on_inventory_ui_opened(ui_id: UIData.Id, inventory_id: InventoryData.Id) -> void:
	super(ui_id, inventory_id)
	if craftable_item_container.get_child_count() == 0:
		for id in ItemData.CRAFTING_RESOURCE_PATH.keys():
			var craftable_item_ui: CraftableItemUI = craftable_item_ui_scene.instantiate()
			craftable_item_container.add_child(craftable_item_ui)
			craftable_item_ui.set_up(id)
			craftable_item_ui.mouse_entered.connect(on_mouse_entered_craftable_item.bind(id))

## 鼠标悬停可制作物品时：显示配方描述（物品名称+所需材料）
func on_mouse_entered_craftable_item(item_id: ItemData.Id) -> void:
	_crafting_item_id = item_id
	var craftable_resource: CraftingResource = ItemData.get_crafting_resource(item_id)
	var item_resource: ItemResource = ItemData.get_item_resource(item_id)
	craft_description_label.text = item_resource.item_name + "\n"
	for requirement in craftable_resource.requirements:
		var requirement_resource: ItemResource = ItemData.get_item_resource(requirement.item_id)
		craft_description_label.text += requirement_resource.item_name + ": "
		craft_description_label.text += str(requirement.amount) + "\n"

## 制作按钮点击：检查材料是否足够，足够则消耗材料并产出物品
func _on_craft_button_pressed() -> void:
	var craftable_resource: CraftingResource = ItemData.get_crafting_resource(_crafting_item_id)
	if craftable_resource == null:
		return
	# 检查所有材料是否足够
	for requirement in craftable_resource.requirements:
		var item_count: int = InventorySystem.get_item_count(requirement.item_id, InventoryData.Id.CraftingInventory)
		if item_count < requirement.amount:
			return
	# 消耗材料
	for requirement in craftable_resource.requirements:
		InventorySystem.remove_item(requirement.item_id, InventoryData.Id.CraftingInventory, requirement.amount)
	# 产出物品到玩家背包
	InventorySystem.add_item(_crafting_item_id, InventoryData.Id.PlayerInventory, 1)
