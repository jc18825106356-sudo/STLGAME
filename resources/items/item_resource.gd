## ItemResource：物品基础资源
## 数据驱动设计：所有物品的属性（名称、图标、价格等）都存储在 .tres 资源文件中，
## 策划可以在编辑器中直接修改，无需改代码。
## 子类 ToolResource、CraftingMaterialResource 等继承此类并扩展属性。
class_name ItemResource extends Resource

@export var id: ItemData.Id                        # 物品 ID（对应 ItemData.Id 枚举）
@export var item_name: String                      # 物品名称（显示用）
@export_multiline var item_description: String     # 物品描述（多行文本）
@export var item_icon: Texture2D                   # 物品图标
@export var max_stack_amount: int = 1              # 最大堆叠数量（1=不可堆叠）
@export var cost: int = 10                         # 购买/出售价格
