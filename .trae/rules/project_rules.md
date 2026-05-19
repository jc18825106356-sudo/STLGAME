# STLGAME 项目编码规范与设计原则

> 基于 Godot 4.6 官方文档 和《Game Development Patterns with Godot 4》(Henrique Campos) 的设计框架。
> 本文件始终生效，不占用对话上下文长度。

---

## 一、架构顶层设计

### 1.1 全局系统（Autoload）
项目使用三个全局单例管理核心系统，**禁止**在场景脚本中直接持有其他场景的引用：

| 系统 | 职责 |
|------|------|
| `EventSystem` | 全局事件总线，所有跨系统通信的唯一通道 |
| `InventorySystem` | 背包数据管理（增删改查、存档） |
| `TimeSystem` | 游戏内时间流逝管理 |

### 1.2 通信铁律：信号 > 直接引用
```
✅ 正确：EventSystem.interact_prompt_show.emit(text)
❌ 错误：$"../../CanvasLayer/Prompt".text = text
```
- 场景之间**永远不**通过 `$"../../"` 跨层级访问
- 数据变更统一由 Autoload 系统发射信号，UI 监听更新
- 新信号必须在 `EventSystem` 中声明，禁止在各场景中自定义跨系统信号

---

## 二、设计模式（来自《Game Development Patterns with Godot 4》）

### 2.1 状态机模式（State Machine）
项目使用 `components/state_machine.gd` 组件：
- 状态通过 `add_state(name, enter_callable, process_callable, exit_callable)` 注册
- 状态切换用 `transition_to()`，**不**直接修改 `_current_state`
- 每个状态的 enter/process/exit 逻辑放在宿主脚本中，不得写回 StateMachine
- 新敌人/新角色统一复用此 StateMachine 组件

### 2.2 组件模式（Component Pattern）→ 优先组合而非继承
```
✅ 正确：场景内嵌 HealthComponent + StateMachine 子节点
❌ 错误：为每种敌人建多层继承链
```
- 可复用功能封装为独立组件（component/ 目录），通过添加子节点组合
- 组件之间通信通过宿主场景桥接，避免组件间直接引用
- 新功能优先考虑做成组件，而非写入基类

### 2.3 观察者模式（Observer / Event Bus）
- `EventSystem` 即事件总线实现
- 新信号先声明后使用，信号名用 `snake_case`，携带必要参数
- 信号接收方统一在 `_ready()` 中 `connect`，在对应方法中处理
- 避免信号链（A 发射 → B 接收后立即发射 C），最多一层转发

### 2.4 单例模式（Singleton / Autoload）
- 全局系统通过 Project Settings → Autoload 注册
- 单例只存放**逻辑和状态**，不存放 UI 引用
- 单例中避免持有场景实例引用，使用 `signal` 反向通知

### 2.5 数据驱动设计（Data-Driven Design）
- 游戏配置数据使用 Godot `Resource`（`.tres`）存储，可在编辑器 Inspector 中配置
- 运行时数据和编辑器数据分离：
  - 物品模板 → `ItemResource.tres`
  - 背包存档 → 独立的存档文件
- 新增物品/配置时在编辑器中创建 `.tres`，不改代码

### 2.6 模板方法模式（Template Method / Base Class）
- `Interactable` 是所有可交互物体的基类，提供 `interactor(player)` 模板方法
- 子类 `extends Interactable`，重写 `interactor()`，首行调用 `super(player)`
- `Enemy/enemy_base.gd` 是所有敌人的基类，新敌人 `extends` 它

---

## 三、SOLID 原则

### 3.1 单一职责（SRP）
- 一个脚本只做一件事：`enemy_base.gd` 只管战斗行为，不管掉落（掉落由 `resource_spawner` 处理）
- UI 脚本只管显示和输入，不作数据逻辑判断
- 系统脚本（`*_system.gd`）只管数据处理，不接触 UI 节点

### 3.2 开闭原则（OCP）
- 新增敌人类型 = 新建 `.gd` 文件 `extends enemy_base`，不改原有代码
- 新增交互物体 = 新建脚本 `extends Interactable`，不改 Interactable 基类

### 3.3 依赖倒置（DIP）
- 高层模块（System）通过信号与低层模块（UI）通信，双方都依赖抽象（信号）
- 避免 `get_node()` 跨场景获取节点

---

## 四、Godot 4.6 编码约定

### 4.1 GDScript 规范
- 所有变量必须声明类型：`var speed: float = 100`，禁止无类型声明
- `@export` 变量用于 Inspector 可配置项
- `@onready` 变量用于场景内的子节点引用，统一在脚本顶部
- 信号回调用 `_on_` 前缀：`func _on_item_equipped(...)`
- 私有方法/变量用 `_` 前缀：`var _player: CharacterBody2D`

### 4.2 节点引用
```
✅ @onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
❌ get_node("AnimatedSprite2D") / $"../../Player"
```
- 只引用当前场景及子节点，禁止向上跨场景引用
- 用 `@onready` + `$NodeName` 或 `%UniqueName`

### 4.3 信号声明与使用
- 统一在 `.gd` 文件顶部用 `signal` 关键字声明
- 发射用 `.emit()`，连接用 `.connect()`
- 信号参数不超过 4 个，超过则封装为 Resource/Dictionary

### 4.4 物理与渲染
- 移动逻辑按需求分到 `_process(delta)` 或 `_physics_process(delta)`
- `move_and_slide()` 必须在 `_physics_process` 中调用
- 非物理计算（如 AI 判断、计时器）放在 `_process` 中

### 4.5 场景组织
```
scene/
├── game_scene.tscn        主场景
├── player.gd / player.tscn
├── interactable/          所有可交互物体
│   ├── interactable.gd    基类
│   ├── Enemy/            敌人系统（大写目录名）
│   ├── Minable/          可采集物
│   ├── Pickup/           可拾取物
│   ├── chest.gd          宝箱
│   ├── merchant.gd       商人
│   └── ...
├── ui/                   所有 UI 元素
└── ...
```
- 按功能模块分组，每个模块独立目录
- 基类脚本放在模块目录根层级

### 4.6 资源引用
- 除 `components/` 外，避免在其他脚本使用 `class_name`
- 资源路径使用 `uid://` 或 `res://`，不硬编码绝对路径

---

## 五、注释规范

- ✅ 可以适当注释，解释关键逻辑和设计意图（用户是 Godot 新手，注释有助于理解）
- 注释格式：`## 说明文字`，放在被说明的代码上方
- 注释写「为什么这样做」而非「代码在做什么」
- 方法和类上方用 `##` 单行注释说明用途
- 不要在每行都加注释，只注释关键节点

## 六、禁止事项

- ❌ 在 `@onready` 执行前访问子节点
- ❌ 在信号回调中写超过 15 行的逻辑（应拆分为独立方法）
- ❌ 使用 `yield`（Godot 4 已废弃），一律用 `await`
- ❌ 在 `_process` 中做每帧不必要的重计算（如 `distance_to` 高频调用应加间隔判断）
- ❌ 直接修改其他场景/系统的属性，必须通过信号或 Autoload 方法
- ❌ 在非 `_physics_process` 中调用 `move_and_slide()`
- ❌ 字符串路径获取节点（`get_node("path/to/node")`），用 `$` 语法糖

---

## 七、技术栈

- 引擎：Godot 4.6（Forward+ 渲染）
- 物理：Jolt Physics 3D
- 语言：GDScript
- 存档：自定义 Resource 序列化
