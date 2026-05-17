## InventoryData：背包数据注册表
## 集中管理所有背包的 ID 枚举和资源路径映射。
## 数据驱动设计：背包配置（容量、初始物品等）存储在 .tres 资源文件中，
## 代码只通过 ID 查表获取，修改背包数据无需改代码。
class_name InventoryData

## 背包 ID 枚举：每个背包在游戏中的唯一标识
enum Id {
	PlayerInventory,       # 玩家主背包
	PlayerEquipment,       # 玩家装备栏
	Chest_01,              # 宝箱1
	Chest_02,              # 宝箱2
	Merchant_01,           # 商人1
	Merchant_02,           # 商人2
	CraftingInventory,     # 制作台背包
}

## 背包资源路径字典：将背包 ID 映射到对应的 .tres 资源文件路径
const INVENTORY_RESOURCE_PATHS: Dictionary[Id, String] = {
	Id.PlayerInventory: "res://resources/inventories/player_inventroy_resource.tres",
	Id.PlayerEquipment: "res://resources/inventories/player_equipment_resource.tres",
	Id.Chest_01: "res://resources/inventories/chest_01_resource.tres",
	Id.Chest_02: "res://resources/inventories/chest_02_resource.tres",
	Id.CraftingInventory: "res://resources/inventories/crafting_inventory_resource.tres",
	Id.Merchant_01: "res://resources/inventories/merchant_01_resource.tres",
}

## 根据背包 ID 获取背包资源（容量、物品列表等）
static func get_inventory_resource(inventory_id: Id) -> InventoryResource:
	if not INVENTORY_RESOURCE_PATHS.has(inventory_id):
		return null
	return load(INVENTORY_RESOURCE_PATHS.get(inventory_id))
