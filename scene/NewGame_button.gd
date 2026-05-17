extends Button

func _ready() -> void:
    pressed.connect(_on_clear_pressed)

func _on_clear_pressed() -> void:
    # 二次确认
    # 删除 user:// 下所有 .tres 存档文件
    var dir: DirAccess = DirAccess.open("user://")
    if dir:
        for file in dir.get_files():
            if file.ends_with(".tres"):
                dir.remove(file)
    # 重载当前场景回到初始状态
    get_tree().reload_current_scene()