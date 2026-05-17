## EventSystem：全局事件总线（信号中心）
## 采用发布-订阅模式，所有游戏系统通过此节点收发信号，实现解耦。
## 例如：玩家交互时发射信号，UI 监听信号并打开对应界面，
## 玩家脚本不需要知道 UI 的存在，UI 也不需要知道玩家的存在。
extends Node

## 信号：显示交互提示文本（如"按E打开宝箱"）
signal interact_prompt_show(prompt: String)
## 信号：打开背包 UI，携带 UI ID 和背包 ID
signal inventory_ui_opened(ui_id: UIData.Id, inventory_id: InventoryData.Id)
## 信号：装备物品，携带物品 ID
signal item_equipped(item_id: ItemData.Id)
## 信号：交互开始（冻结玩家移动）
signal interaction_started()
## 信号：交互结束（恢复玩家移动）
signal interaction_ended()
## 信号：打开对话 UI，携带 UI ID、说话者名称、对话行和选项
signal dialogue_ui_opened(ui_id: UIData.Id, speaker_name: String, Lines: Array[String])
## 信号：对话结束
signal dialogue_finished()
## 信号：选择了对话选项，携带选项索引
signal dialogue_option_selected(option_idx: int)
## 信号：保存数据
signal data_save()

## 显示交互提示，供 UI 接收并显示
func show_interact_prompt(prompt: String) -> void:
	interact_prompt_show.emit(prompt)

## 打开背包 UI，供交互物体调用
func open_inventory_ui(ui_id: UIData.Id, inventory_id: InventoryData.Id) -> void:
	inventory_ui_opened.emit(ui_id, inventory_id)

## 装备物品，供装备栏 UI 调用
func equip_item(item_id: ItemData.Id) -> void:
	item_equipped.emit(item_id)

## 开始交互，冻结玩家控制
func start_interaction() -> void:
	interaction_started.emit()

## 结束交互，恢复玩家控制
func end_interaction() -> void:
	interaction_ended.emit()

## 打开对话 UI
func open_dialogue_ui(ui_id: UIData.Id, speaker_name: String, Lines: Array[String], options: Array[String]) -> void:
	dialogue_ui_opened.emit(ui_id, speaker_name, Lines, options)

## 结束对话
func finish_dialogue() -> void:
	dialogue_finished.emit()

## 选择对话选项
func select_dialogue_option(option_idx: int) -> void:
	dialogue_option_selected.emit(option_idx)

## 触发全局保存
func save_data() -> void:
	data_save.emit()
