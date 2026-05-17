## PlantableField：可种植田地
## 继承自 Interactable，管理田地的完整生命周期：
## 未开垦 → 已开垦 → 已浇水 → 生长中 → 成熟 → 已收获 → 循环
## 数据驱动设计：作物生长过程由 GrowthResource 配置，添加新作物无需改代码。
extends Interactable
class_name PlantableField

@onready var planted_sprite: Sprite2D = $PlantedSprite     # 种植物精灵
@onready var hit_delay_timer: Timer = $HitDelayTimer       # 工具使用间隔计时器

## 田地状态枚举：定义田地的所有可能状态
enum field_state_enum { Uncleared, Cleared, Watered, Growing, Ripe, Harvested }

@export var field_state: field_state_enum = field_state_enum.Uncleared   # 当前田地状态
@export var plantable_seeds: Array[ItemData.Id]     # 可以种植的种子列表
@export var clear_tools: Array[ItemData.Id]         # 清理田地所需的工具
@export var watering_tools: Array[ItemData.Id]      # 浇水所需的工具

## 各状态对应的交互提示文本
const PROMPT: Dictionary[field_state_enum, String] = {
	field_state_enum.Uncleared: "Clear Field",
	field_state_enum.Cleared: "Watering Field",
	field_state_enum.Watered: "Plant Field",
	field_state_enum.Growing: "Growing",
	field_state_enum.Ripe: "Ripe",
	field_state_enum.Harvested: "Clear Field",
}

## 各状态对应的瓦片图坐标（用于切换田地外观）
const TILES: Dictionary[field_state_enum, Vector2i] = {
	field_state_enum.Cleared: Vector2i.ZERO,
	field_state_enum.Watered: Vector2i(1, 0),
	field_state_enum.Growing: Vector2i(2, 0),
	field_state_enum.Ripe: Vector2i(2, 0),
	field_state_enum.Harvested: Vector2i(3, 0),
}

var _plantable_layer: TileMapLayer              # 田地瓦片图层引用
var _tile_position: Vector2i                    # 当前田地在瓦片图中的坐标
var _seed_id: ItemData.Id                       # 种下的种子 ID

var _growth_resource: GrowthResource            # 当前作物的生长配置资源
var _growth_stage: Array[GrowthStageResource]   # 生长阶段列表
var _growth_stage_idx: int = 0                  # 当前生长阶段索引
var _end_stage_time: TimeResource               # 当前阶段的结束时间

func _ready():
	TimeSystem.time_updated.connect(_on_time_updated)
	EventSystem.data_save.connect(save_data)
	prompt = "Clear Field"

## 初始化田地：设置瓦片图层和坐标，并加载存档数据
func set_up(plantable_Layer: TileMapLayer, tile_position: Vector2i) -> void:
	_plantable_layer = plantable_Layer
	_tile_position = tile_position
	load_data()

## 交互入口：根据当前状态执行不同操作
func interactor(player: CharacterBody2D):
	super(player)
	match field_state:
		field_state_enum.Uncleared:
			_on_interact_uncleared_state()
		field_state_enum.Cleared:
			_on_interact_cleared_state()
		field_state_enum.Watered:
			_on_interact_watered_state()
		field_state_enum.Ripe:
			_on_interact_ripe_state()
		field_state_enum.Harvested:
			_on_interact_harvested_state()

## 未开垦状态：使用清理工具开垦田地
func _on_interact_uncleared_state() -> void:
	try_use_tool(clear_tools, field_state_enum.Cleared)

## 已开垦状态：使用浇水工具浇水
func _on_interact_cleared_state() -> void:
	try_use_tool(watering_tools, field_state_enum.Watered)

## 已浇水状态：种下种子，初始化生长过程
func _on_interact_watered_state() -> void:
	if not _player.equipped_item in plantable_seeds:
		return
	_seed_id = _player.equipped_item
	# 从装备栏移除种子
	InventorySystem.remove_item(_player.equipped_item, InventoryData.Id.PlayerEquipment)
	# 加载生长配置
	_growth_resource = ItemData.get_growth_resource(_player.equipped_item)
	_growth_stage = _growth_resource.growth_stages
	_growth_stage_idx = 0
	# 显示第一阶段的精灵
	planted_sprite.texture = _growth_stage[_growth_stage_idx].stage_sprite
	planted_sprite.offset = _growth_stage[_growth_stage_idx].sprite_offset
	planted_sprite.visible = true
	# 计算第一阶段结束时间
	_end_stage_time = TimeSystem.get_time_after(_growth_stage[_growth_stage_idx].growing_time)
	change_state(field_state_enum.Growing)

## 成熟状态：收获作物，生成掉落物
func _on_interact_ripe_state() -> void:
	planted_sprite.visible = false
	var crop_pickup: PickupTemplate = ItemData.get_item_pick_scene(_growth_resource.crop_id).instantiate()
	get_tree().current_scene.add_child(crop_pickup)
	crop_pickup.global_position = global_position
	crop_pickup.amount = 1
	crop_pickup.player_spawn_animation()
	change_state(field_state_enum.Harvested)

## 已收获状态：使用清理工具重新开垦
func _on_interact_harvested_state() -> void:
	try_use_tool(clear_tools, field_state_enum.Cleared)

## 切换田地状态：更新提示文本和瓦片外观
func change_state(target_state: field_state_enum) -> void:
	prompt = PROMPT.get(target_state)
	if target_state == field_state_enum.Uncleared:
		return
	var source_id: int = 0
	var atlas_coords: Vector2i = TILES.get(target_state)
	_plantable_layer.set_cell(_tile_position, source_id, atlas_coords)
	field_state = target_state

## 尝试使用工具：检查装备的工具是否符合要求，符合则播放动画并切换状态
func try_use_tool(target_tool: Array[ItemData.Id], target_state: field_state_enum) -> void:
	if _player.equipped_item in target_tool or target_tool.is_empty():
		EventSystem.start_interaction()
		var tool_resource: ToolResource = ItemData.get_item_resource(_player.equipped_item)
		_player.animated_sprite_2d.play(tool_resource.use_tool_animation)
		hit_delay_timer.start(tool_resource.hit_delay)
		await hit_delay_timer.timeout
		change_state(target_state)
		await _player.animated_sprite_2d.animation_finished
		EventSystem.end_interaction()
	else:
		EventSystem.end_interaction()

## 时间更新回调：检查作物是否进入下一生长阶段
func _on_time_updated(time_resource: TimeResource) -> void:
	if not field_state == field_state_enum.Growing:
		return
	if TimeSystem.has_passed(_end_stage_time):
		_growth_stage_idx += 1
		planted_sprite.texture = _growth_stage[_growth_stage_idx].stage_sprite
		planted_sprite.offset = _growth_stage[_growth_stage_idx].sprite_offset
		# 到达最后一个阶段：作物成熟
		if _growth_stage_idx == _growth_stage.size() - 1:
			change_state(field_state_enum.Ripe)
			return
		# 还没到最后阶段：计算下一阶段结束时间
		_end_stage_time = TimeSystem.get_time_after(_growth_stage[_growth_stage_idx].growing_time)

## 保存田地数据到 user:// 目录
func save_data() -> void:
	var save_path: StringName = "user://planteable_field_" + str(name) + ".tres"
	var data_to_save: PlantableFieldSaveData = PlantableFieldSaveData.new()
	data_to_save.field_state = field_state
	data_to_save.growth_stage_idx = _growth_stage_idx
	data_to_save.seed_id = _seed_id
	data_to_save.end_stage_time = _end_stage_time
	ResourceSaver.save(data_to_save, save_path)

## 加载田地数据：恢复田地状态和作物外观
func load_data() -> void:
	var save_path: StringName = "user://planteable_field_" + str(name) + ".tres"
	if not ResourceLoader.exists(save_path):
		field_state = field_state_enum.Uncleared
		return
	var data_to_load: PlantableFieldSaveData = ResourceLoader.load(save_path)
	_seed_id = data_to_load.seed_id
	field_state = data_to_load.field_state
	_growth_stage_idx = data_to_load.growth_stage_idx
	_end_stage_time = data_to_load.end_stage_time
	change_state(field_state)
	# 如果田地处于生长或成熟状态，恢复作物精灵
	if field_state == field_state_enum.Growing or field_state == field_state_enum.Ripe:
		_growth_resource = ItemData.get_growth_resource(_seed_id)
		_growth_stage = _growth_resource.growth_stages
		planted_sprite.texture = _growth_stage[_growth_stage_idx].stage_sprite
		planted_sprite.offset = _growth_stage[_growth_stage_idx].sprite_offset
		planted_sprite.visible = true
