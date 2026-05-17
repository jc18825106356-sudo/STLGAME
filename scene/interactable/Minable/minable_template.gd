class_name Minable extends Interactable

@export var target_tools: Array[ItemData.Id] = []

@onready var health_component: HealthComponent = $HealthComponent
@onready var sprites: Node2D = $Sprites
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var hit_delay_timer: Timer = $HitDelayTimer
@onready var resource_spawners: Node2D = $ResourceSpawners

func _ready() -> void:
	EventSystem.data_save.connect(save_data)
	health_component.died.connect(_on_death)
	load_data()

func _on_death() -> void:
	_spawn_resources()
	sprites.visible = false
	collision_shape_2d.disabled = true
	monitorable = false

func _spawn_resources() -> void:
	for spawner: ResourceSpawner in resource_spawners.get_children():
		spawner.spawn()

func interactor(player: CharacterBody2D) -> void:
	super(player)
	if health_component.is_dead():
		return
	if player.equipped_item in target_tools or target_tools.size() == 0:
		EventSystem.start_interaction()
		var tool_resource: ToolResource = ItemData.get_item_resource(player.equipped_item)
		player.animated_sprite_2d.play(tool_resource.use_tool_animation)
		hit_delay_timer.start(tool_resource.hit_delay)
		await hit_delay_timer.timeout
		health_component.take_damage(tool_resource.damage)
		await player.animated_sprite_2d.animation_finished
		EventSystem.end_interaction()
		if health_component.is_dead():
			get_parent().remove_child.call_deferred(self)

func save_data() -> void:
	var save_path: StringName = "user://minable_" + str(name) + ".tres"
	var data_to_save: MinableSaveData = MinableSaveData.new()
	data_to_save.health = health_component.health
	ResourceSaver.save(data_to_save, save_path)

func load_data() -> void:
	var save_path: StringName = "user://minable_" + str(name) + ".tres"
	if not ResourceLoader.exists(save_path):
		return
	var data_to_load: MinableSaveData = ResourceLoader.load(save_path)
	health_component.health = data_to_load.health
	if data_to_load.health == 0:
		get_parent().remove_child.call_deferred(self)
