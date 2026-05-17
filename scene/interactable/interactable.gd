## Interactable：可交互物体基类
## 所有可交互物体（宝箱、矿石、商人等）的父类。
## 提供统一的交互入口 interactor()，子类重写此方法实现各自逻辑。
## 使用 Area2D 作为碰撞检测，玩家射线碰到时显示提示文本。
class_name Interactable extends Area2D

## 交互提示文本（在 Inspector 中配置，如"按E打开宝箱"）
@export var prompt: String = ""

## 触发交互的玩家引用（由 interactor() 设置）
var _player: CharacterBody2D

## 交互入口：玩家调用此方法触发交互
## 子类必须调用 super(player) 以保存玩家引用
func interactor(player: CharacterBody2D) -> void:
	_player = player
