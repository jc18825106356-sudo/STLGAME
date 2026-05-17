## Merchant：商人交互物体
## 继承自 Interactable，玩家交互时先显示对话，
## 根据玩家选择的对话选项决定打开买/卖界面或关闭。
extends Interactable

@export var inventory_id: InventoryData.Id          # 商人的背包 ID（决定商品列表）
@export var merchant_name: String                   # 商人名称（显示在对话 UI 中）
@export var dialogue_Lines: Array[String]           # 对话内容行
@export var dialogue_options: Array[String]         # 对话选项（如"买"、"卖"、"离开"）

## 交互入口：先显示对话，等待玩家选择后执行对应操作
func interactor(player: CharacterBody2D) -> void:
	super(player)
	EventSystem.start_interaction()
	EventSystem.open_dialogue_ui(UIData.Id.DialogueUI, merchant_name, dialogue_Lines, dialogue_options)
	# 等待玩家选择对话选项
	var option_idx: int = await EventSystem.dialogue_option_selected
	if option_idx == 0:
		# 选项0：买（打开商人背包，玩家可以购买商品）
		print("买")
		EventSystem.open_inventory_ui(UIData.Id.TradeUI, inventory_id)
	elif option_idx == 1:
		# 选项1：卖（打开玩家背包，玩家可以出售物品）
		print("卖")
		EventSystem.open_inventory_ui(UIData.Id.TradeUI, InventoryData.Id.PlayerInventory)
	else:
		# 其他选项：关闭交互
		print("关闭")
		EventSystem.end_interaction()
