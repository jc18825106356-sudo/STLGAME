## UIData：UI 界面数据注册表
## 集中管理所有 UI 界面的 ID 枚举。
## 数据驱动设计：UI 的打开/关闭通过 ID 路由，而非直接引用场景节点，
## 使 UI 系统与业务逻辑解耦。
class_name UIData

## UI 界面 ID 枚举：每个 UI 界面的唯一标识
enum Id {
	PlayerInventoryUI,    # 玩家背包 UI
	PlayerEquipmentUI,    # 玩家装备栏 UI
	TradeUI,              # 交易 UI（买卖界面）
	ChestUI,              # 宝箱 UI
	CraftingUI,           # 制作 UI
	DialogueUI,           # 对话 UI
}
