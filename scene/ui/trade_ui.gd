## TradeUI：交易 UI（继承自 InventoryUI）
## 用于买卖物品，支持购物车功能。
## 买模式：从商人背包购买物品到玩家背包，扣除金币。
## 卖模式：从玩家背包出售物品，获得金币。
extends InventoryUI

@onready var coin_label: Label = $MarginContainer/VBoxContainer/CoinLabel           # 金币显示
@onready var cost_label: Label = $MarginContainer/VBoxContainer/CostLabel           # 花费显示
@onready var buy_button: Button = $MarginContainer/VBoxContainer/BuyButton          # 买/卖按钮

var _cart: Dictionary[ItemData.Id, int] = {}     # 购物车：物品ID → 购买数量
var _cost: int = 0:                              # 当前购物车总花费
	set(value):
		_cost = value
		cost_label.text = "Cost: " + str(value)

func _ready() -> void:
	super()
	buy_button.pressed.connect(_on_buy_button_pressed)

## 刷新交易 UI：重置购物车，根据背包类型切换买/卖模式
func _update_inventory_ui(inventory_id: InventoryData.Id) -> void:
	super(inventory_id)
	coin_label.text = "Coin: " + str(InventorySystem.player_coins)
	(func(): _cost = 0).call_deferred()
	(func(): _cart.clear()).call_deferred()
	# 玩家背包=卖模式，商人背包=买模式
	buy_button.text = "Sell" if inventory_id == InventoryData.Id.PlayerInventory else "Buy"
	# 连接每个交易槽位的购物车信号
	for slot: TradeItemUI in _item_slots:
		slot.item_added_to_cart.connect(_on_item_added_to_cart)
		slot.item_removed_from_cart.connect(_on_item_removed_from_cart)

## 物品加入购物车：累计数量和花费
func _on_item_added_to_cart(item_id: ItemData.Id, amount: int) -> void:
	if _cart.has(item_id):
		_cart[item_id] += amount
	else:
		_cart[item_id] = amount
	_cost += ItemData.get_item_resource(item_id).cost * amount

## 物品移出购物车：减少数量和花费
func _on_item_removed_from_cart(item_id: ItemData.Id, amount: int) -> void:
	if _cart.has(item_id):
		amount = min(amount, _cart[item_id])
		_cart[item_id] = _cart[item_id] - amount
		if _cart[item_id] == 0:
			_cart.erase(item_id)
		_cost -= ItemData.get_item_resource(item_id).cost * amount

## 买/卖按钮点击：执行交易，扣除/增加金币，移动物品
func _on_buy_button_pressed() -> void:
	# 买模式：检查金币是否足够
	if _inventory_id != InventoryData.Id.PlayerInventory and _cost > InventorySystem.player_coins:
		return
	for item_id in _cart:
		# 从源背包移除物品
		InventorySystem.remove_item(item_id, _inventory_id, _cart[item_id])
		# 买模式：将物品添加到玩家背包
		if _inventory_id != InventoryData.Id.PlayerInventory:
			InventorySystem.add_item(item_id, InventoryData.Id.PlayerInventory, _cart[item_id])
	# 更新金币
	if _inventory_id != InventoryData.Id.PlayerInventory:
		InventorySystem.player_coins -= _cost
	else:
		InventorySystem.player_coins += _cost
	# 重置购物车
	_cart.clear()
	coin_label.text = "Coin: " + str(InventorySystem.player_coins)
	_cost = 0
