## InteractPrompt：交互提示 UI
## 监听全局事件系统的提示信号，在界面上显示交互提示文本（如"按E打开"）。
extends Label

func _ready() -> void:
	EventSystem.interact_prompt_show.connect(_on_interact_prompt_shown)

## 提示信号回调：更新提示文本
func _on_interact_prompt_shown(prompt: String) -> void:
	text = prompt
	print(text)
