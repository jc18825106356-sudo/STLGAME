## Player：玩家角色控制器
## 处理玩家输入（移动、交互、打开背包）、动画切换、朝向翻转、
## 交互检测（射线）和存档/读档。
class_name Player extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var interact_ray: RayCast2D = $AnimatedSprite2D/InteracRay
@onready var health_component: HealthComponent = $HealthComponent

@export var move_speed: float = 60

var equipped_item: ItemData.Id                     # 当前装备的物品 ID

var _direction: Vector2                            # 移动方向向量
var _interactable: Interactable                    # 当前射线检测到的可交互物体

func _ready() -> void:
	EventSystem.item_equipped.connect(_on_item_equipped)
	InventorySystem.inventories_loaded.connect(_on_inventories_loaded)
	EventSystem.interaction_started.connect(_on_interaction_started)
	EventSystem.interaction_ended.connect(_on_interaction_ended)
	EventSystem.data_save.connect(save_data)
	load_data()

## 每帧更新：处理移动、交互检测、动画、翻转
func _process(delta: float) -> void:
	_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = _direction * move_speed
	move_and_slide()
	_handle_interactable()
	_handle_animation()
	_handle_flip()

## 根据移动方向切换动画（静止=idle，移动=run）
func _handle_animation():
	if _direction == Vector2.ZERO:
		animated_sprite_2d.animation = "idle"
	else:
		animated_sprite_2d.animation = "run"

## 根据水平方向翻转角色（左=镜像，右=正常）
func _handle_flip():
	if _direction.x < 0:
		animated_sprite_2d.scale = Vector2(-1, 1)
	elif _direction.x > 0:
		animated_sprite_2d.scale = Vector2(1, 1)

## 处理未消耗的输入：打开背包、交互
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("open_inventory"):
		EventSystem.open_inventory_ui(UIData.Id.PlayerInventoryUI, InventoryData.Id.PlayerInventory)
	if event.is_action_pressed("interactable") and _interactable:
		_interactable.interactor(self)

## 用射线检测可交互对象并更新提示文本
func _handle_interactable():
	if interact_ray.is_colliding():
		var collision = interact_ray.get_collider()
		if collision is Interactable:
			_interactable = collision as Interactable
			EventSystem.show_interact_prompt(_interactable.prompt)
	else:
		_interactable = null
		EventSystem.show_interact_prompt("")

## 装备物品回调：更新当前装备的物品 ID
func _on_item_equipped(item_id: ItemData.Id) -> void:
	equipped_item = item_id

## 背包加载完成回调：打开装备栏 UI
func _on_inventories_loaded() -> void:
	EventSystem.open_inventory_ui(UIData.Id.PlayerEquipmentUI, InventoryData.Id.PlayerEquipment)

## 交互开始回调：冻结玩家移动和输入
func _on_interaction_started() -> void:
	_interactable = null
	animated_sprite_2d.play("idle")
	set_process(false)
	set_process_input(false)

## 交互结束回调：恢复玩家移动和输入
func _on_interaction_ended() -> void:
	print("interaction_ended")
	set_process(true)
	set_process_input(true)
	animated_sprite_2d.play("idle")

## 保存玩家数据到 user:// 目录
func save_data() -> void:
	var save_path: StringName = "user://PlayerSave.tres"
	var data_to_save: PlayerSaveData = PlayerSaveData.new()
	data_to_save.player_global_position = global_position
	data_to_save.player_coins = InventorySystem.player_coins
	ResourceSaver.save(data_to_save, save_path)

## 加载玩家数据：恢复位置和金币
func load_data() -> void:
	var save_path: StringName = "user://PlayerSave.tres"
	if not ResourceLoader.exists(save_path):
		return
	var data_to_load: PlayerSaveData = ResourceLoader.load(save_path)
	global_position = data_to_load.player_global_position
	InventorySystem.player_coins = data_to_load.player_coins
