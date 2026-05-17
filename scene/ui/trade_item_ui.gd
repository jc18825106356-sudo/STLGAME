## TradeItemUI：交易物品槽位 UI（继承自 ItemSlotUI）
## 在基础物品槽位上增加了价格显示、购买数量增减按钮，
## 通过信号通知 TradeUI 购物车的变化。
class_name TradeItemUI extends ItemSlotUI

@onready var price_label: Label = $MarginContainer/HBoxContainer/PriceLabel                     # 价格标签
@onready var purchased_amount_label: Label = $MarginContainer/HBoxContainer/PurchasedAmountLabel # 已购数量标签
@onready var minus_button: Button = $MarginContainer/HBoxContainer/MinusButton                  # 减少按钮
@onready var add_button: Button = $MarginContainer/HBoxContainer/AddButton                      # 增加按钮

var _purchased_amount: int = 0     # 当前已购买的数量

## 信号：物品加入购物车
signal item_added_to_cart(item_id: ItemData.Id, amount: int)
## 信号：物品移出购物车
signal item_removed_from_cart(item_id: ItemData.Id, amount: int)

func _ready() -> void:
	minus_button.pressed.connect(_on_minus_button_pressed)
	add_button.pressed.connect(_on_add_button_pressed)

## 初始化交易槽位：显示价格，隐藏空槽位
func set_up(item_id: ItemData.Id, amount: int, inventory_id: InventoryData.Id) -> void:
	super(item_id, amount, inventory_id)
	_purchased_amount = 0
	if _item_id != ItemData.Id.NONE:
		price_label.text = "Cost: " + str(_item_resource.cost)
		amount_label.text = "x" + str(_amount)
		purchased_amount_label.text = str(_purchased_amount)
	else:
		visible = false

## 减少购买数量：退回一个物品到源背包
func _on_minus_button_pressed() -> void:
	if _purchased_amount <= 0:
		return
	_purchased_amount -= 1
	_amount += 1
	amount_label.text = "x" + str(_amount)
	purchased_amount_label.text = str(_purchased_amount)
	item_removed_from_cart.emit(_item_id, 1)

## 增加购买数量：从源背包取出一个物品
func _on_add_button_pressed() -> void:
	if _amount <= 0:
		return
	_purchased_amount += 1
	_amount -= 1
	amount_label.text = "x" + str(_amount)
	purchased_amount_label.text = str(_purchased_amount)
	item_added_to_cart.emit(_item_id, 1)
