## PlantManager：种植管理器
## 在游戏启动时扫描瓦片图，找到所有标记为"可种植"的瓦片，
## 并在每个可种植瓦片位置实例化一个 PlantableField 场景。
extends Node

@export var plant_tilemap: TileMapLayer              # 可种植区域的瓦片图层
@export var Plantable_field_scene: PackedScene       # 可种植田地的场景预制体
@export var y_sort_root: Node2D                      # Y排序根节点（用于正确渲染遮挡关系）

func _ready():
	# 遍历瓦片图中所有已使用的格子
	for tile in plant_tilemap.get_used_cells():
		var plantable: bool = plant_tilemap.get_cell_tile_data(tile).get_custom_data("plantable")
		if plantable:
			# 在可种植位置实例化田地场景
			var plantable_field: PlantableField = Plantable_field_scene.instantiate()
			y_sort_root.add_child(plantable_field)
			plantable_field.global_position = plant_tilemap.to_global(plant_tilemap.map_to_local(tile))
			plantable_field.set_up(plant_tilemap, tile)
