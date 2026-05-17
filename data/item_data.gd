## ItemData：物品数据注册表
## 集中管理所有物品的 ID 枚举、资源路径映射和静态查询方法。
## 这是数据驱动设计的核心——通过 ID + 路径字典，代码不需要硬编码物品信息，
## 只需查表即可获取对应的资源文件。
class_name ItemData

## 物品 ID 枚举：每个物品在游戏中的唯一标识
enum Id {
	NONE,                                       # 空物品（空槽位占位符）
	Axe, PickAxe, Player, WateringCan,          # 工具类
	Beetroot, Cabbage, Carrot,                  # 农作物类
	BeetrootSeed, CabbageSeed, CarrotSeed,      # 种子类
	Log, Stone                                  # 材料类
}

## 物品资源路径字典：将物品 ID 映射到对应的 .tres 资源文件路径
## 通过 ID 查找路径，再 load() 加载资源，实现数据与逻辑分离
const ITEM_RESOURCE_PATH: Dictionary[Id, String] = {
	Id.Beetroot: "res://resources/items/crops/beetroot_resour.tres",
	Id.Cabbage: "res://resources/items/crops/cabbage_resource.tres",
	Id.Carrot: "res://resources/items/crops/carrot_resource.tres",
	Id.PickAxe: "res://resources/items/tool/pickaxe_resource.tres",
	Id.Axe: "res://resources/items/tool/axe_resource.tres",
	Id.WateringCan: "res://resources/items/tool/watering_resource.tres",
	Id.Log: "res://resources/items/log_resource.tres",
	Id.Stone: "res://resources/items/stone_resource.tres",
	Id.BeetrootSeed: "res://resources/items/seeds/beetroot_seed_resource.tres",
}

## 物品拾取场景路径字典：将物品 ID 映射到对应的拾取场景（掉落物）
const ITEM_PICK_SCENE_PATH: Dictionary[Id, String] = {
	Id.Log: "res://scene/interactable/Pickup/log_pickup.tscn",
	Id.Stone: "res://scene/interactable/Pickup/stone_pickup.tscn",
	Id.Beetroot: "res://scene/interactable/Pickup/beetroot_pickup.tscn",
}

## 制作配方资源路径字典：将可制作物品 ID 映射到制作配方资源
const CRAFTING_RESOURCE_PATH: Dictionary[Id, String] = {
	Id.Axe: "res://resources/items/craftables/craftable_axe_resource.tres",
	Id.PickAxe: "res://resources/items/craftables/craftable_pickaxe_resource.tres",
}

## 生长资源路径字典：将种子 ID 映射到作物生长配置资源
const GROWTH_RESOURCE_PATH: Dictionary[Id, String] = {
	Id.BeetrootSeed: "res://resources/growth/beetroot_growth_resource.tres",
}

## 根据物品 ID 获取物品资源（图标、名称、描述等）
static func get_item_resource(id: Id) -> ItemResource:
	if not ITEM_RESOURCE_PATH.has(id):
		return null
	var path = ITEM_RESOURCE_PATH.get(id)
	print("物品资源路径: " + path)
	return load(path)

## 根据物品 ID 获取拾取场景（掉落物预制体）
static func get_item_pick_scene(id: Id) -> PackedScene:
	if not ITEM_PICK_SCENE_PATH.has(id):
		return null
	return load(ITEM_PICK_SCENE_PATH.get(id))

## 根据物品 ID 获取制作配方资源
static func get_crafting_resource(id: Id) -> CraftingResource:
	if not CRAFTING_RESOURCE_PATH.has(id):
		return null
	return load(CRAFTING_RESOURCE_PATH.get(id))

## 根据种子 ID 获取作物生长配置资源
static func get_growth_resource(id: Id) -> GrowthResource:
	if not GROWTH_RESOURCE_PATH.has(id):
		return null
	return load(GROWTH_RESOURCE_PATH.get(id))