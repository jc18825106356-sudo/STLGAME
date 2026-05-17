## CraftingTable：制作台交互物体
## 继承自 Interactable，玩家交互时同时打开玩家背包和制作台 UI，
## 玩家可以在制作台中查看配方并制作物品。
extends Interactable

## 交互入口：打开玩家背包和制作台 UI
func interactor(player: CharacterBody2D) -> void:
	super(player)
	EventSystem.start_interaction()
	EventSystem.open_inventory_ui(UIData.Id.PlayerInventoryUI, InventoryData.Id.PlayerInventory)
	EventSystem.open_inventory_ui(UIData.Id.CraftingUI, InventoryData.Id.CraftingInventory)
