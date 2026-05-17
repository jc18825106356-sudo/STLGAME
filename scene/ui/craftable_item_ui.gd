## CraftableItemUI：可制作物品的 UI 组件
## 在制作列表中显示物品图标和名称，鼠标悬停时通知 CraftingUI 显示配方。
class_name CraftableItemUI extends PanelContainer

@onready var item_icon: TextureRect = $MarginContainer/HBoxContainer/ItemIcon     # 物品图标
@onready var name_label: Label = $MarginContainer/HBoxContainer/NameLabel         # 物品名称

var _item_id: ItemData.Id     # 当前物品的 ID

## 初始化 UI：根据物品 ID 加载资源并显示图标和名称
func set_up(item_id: ItemData.Id):
	_item_id = item_id
	var item_resource: ItemResource = ItemData.get_item_resource(item_id)
	item_icon.texture = item_resource.item_icon
	name_label.text = item_resource.item_name
