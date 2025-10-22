# Soul 项目开发规范

## 1. 自动布局规范

### 1.1 强制使用 SnapKit

**规则：** 项目中所有 UI 组件的自动布局必须使用 SnapKit 框架，禁止使用原生的 NSLayoutConstraint 或 Interface Builder。

**原因：**
- 代码更简洁易读
- 类型安全，减少运行时错误
- 更好的代码复用性
- 统一的代码风格

## 2. 架构规范

### 2.1 强制使用 MVVM 架构

**规则：** 项目必须采用 MVVM（Model-View-ViewModel）架构模式，严格分离业务逻辑、数据处理和UI展示。

**架构层次：**
- **Model**: 数据模型和业务逻辑
- **View**: UI组件（UIViewController、UIView等）
- **ViewModel**: 视图逻辑和数据绑定

**实现要求：**
- View 不能直接访问 Model
- View 通过 ViewModel 获取数据和处理用户交互
- ViewModel 负责数据转换和业务逻辑处理
- 使用协议（Protocol）定义 ViewModel 接口

**命名规范：**
- ViewModel 类名以 `ViewModel` 结尾
- ViewModel 协议名以 `ViewModelProtocol` 结尾
- 示例：`ChatViewModel`、`ChatViewModelProtocol`

## 3. 数据绑定规范

### 3.1 强制使用 RxSwift

**规则：** 项目中所有数据绑定必须使用 RxSwift 框架，实现响应式编程。

**使用场景：**
- View 与 ViewModel 之间的数据绑定
- 网络请求和异步操作
- 用户交互事件处理
- 数据流管理

**核心组件使用：**
- 使用 `Observable` 进行数据流传递
- 使用 `BehaviorRelay` 管理状态
- 使用 `PublishRelay` 处理事件
- 使用 `Driver` 进行UI绑定（确保主线程执行）

**绑定规范：**
```swift
// ViewModel 输出
let items: Driver<[ItemModel]>
let isLoading: Driver<Bool>
let error: Driver<Error?>

// View 绑定
viewModel.items
    .drive(tableView.rx.items(cellIdentifier: "Cell"))
    .disposed(by: disposeBag)
```

### 3.2 DisposeBag 管理

**规则：** 每个使用 RxSwift 的类必须包含 `disposeBag` 属性，用于管理订阅生命周期。

**实现要求：**
- 在类中声明 `private let disposeBag = DisposeBag()`
- 所有订阅必须使用 `.disposed(by: disposeBag)`
- 避免内存泄漏和循环引用

## 4. 文件组织规范

### 4.1 文件夹结构

**规则：** 项目必须按照功能模块和架构层次组织文件夹结构。

**标准结构：**
```
Soul/
├── Application/
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
├── Modules/
│   ├── Chat/
│   │   ├── Models/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Services/
│   ├── Card/
│   │   ├── Models/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Services/
│   └── Community/
│       ├── Models/
│       ├── Views/
│       ├── ViewModels/
│       └── Services/
├── Common/
│   ├── Extensions/
│   ├── Utils/
│   ├── Constants/
│   └── Protocols/
├── Network/
│   ├── Services/
│   ├── Models/
│   └── Managers/
├── Resources/
│   ├── Assets.xcassets/
│   ├── Fonts/
│   └── Localizable.strings
└── Supporting Files/
    ├── Info.plist
    └── GoogleService-Info.plist
```

### 4.2 文件命名规范

**规则：** 文件名必须清晰表达其功能和架构层次。

**命名模式：**
- **Models**: `[ModuleName]Model.swift`
- **Views**: `[ModuleName]View.swift` 或 `[ModuleName]ViewController.swift`
- **ViewModels**: `[ModuleName]ViewModel.swift`
- **Services**: `[ModuleName]Service.swift`
- **Protocols**: `[ModuleName]Protocol.swift`

**示例：**
- `ChatModel.swift`
- `ChatViewController.swift`
- `ChatViewModel.swift`
- `ChatService.swift`
- `ChatViewModelProtocol.swift`

## 5. 代码组织规范

### 5.1 依赖管理

**规则：** ViewModel 和 Service 层可以直接持有所需的依赖对象。

**实现方式：**
- ViewModel 可以直接创建和持有 Service 实例
- Service 层可以直接持有其他 Service 或工具类
- 保持代码简洁，避免过度设计

**示例：**
```swift
class ChatService {
    func sendMessage(_ message: String) -> Observable<ChatMessage> {
        // 实现发送消息逻辑
    }
}

class ChatViewModel {
    private let chatService = ChatService()
    private let disposeBag = DisposeBag()
    
    // ViewModel 逻辑
}
```

### 5.2 协议使用

**规则：** 在需要的时候使用协议定义接口，保持代码灵活性。

**建议使用场景：**
- 需要多种实现的接口
- 数据源和委托模式
- 复杂的业务逻辑抽象

**好处：**
- 提高代码灵活性
- 便于扩展和维护
- 支持多态实现

## 6. 测试规范（可选）

### 6.1 单元测试

**规则：** 单元测试为可选项，建议在关键业务逻辑中使用。

**测试建议：**
- 可为核心 ViewModel 编写测试文件
- 可使用 RxTest 测试响应式代码
- 可 Mock 外部依赖进行隔离测试

**测试文件命名：**
- `[ClassName]Tests.swift`
- 示例：`ChatViewModelTests.swift`

### 6.2 测试组织

**测试文件结构（如果需要）：**
```
SoulTests/
├── ViewModels/
│   ├── ChatViewModelTests.swift
│   └── CardViewModelTests.swift
├── Services/
│   ├── ChatServiceTests.swift
│   └── NetworkServiceTests.swift
└── Mocks/
    ├── MockChatService.swift
    └── MockNetworkService.swift
```

## 7. 重构指导

### 7.1 渐进式重构

**原则：** 采用渐进式重构策略，避免大规模代码重写。

**重构步骤：**
1. **第一阶段**：引入 RxSwift 和 SnapKit 依赖
2. **第二阶段**：重构现有 ViewController，提取 ViewModel
3. **第三阶段**：重构网络层，使用 RxSwift
4. **第四阶段**：重构 UI 布局，使用 SnapKit

### 7.2 重构优先级

**高优先级模块：**
1. Chat 模块 - 核心功能
2. Network 层 - 基础设施
3. Card 模块 - 主要功能

**中优先级模块：**
1. Community 模块
2. Login 模块

**低优先级模块：**
1. 工具类和扩展
2. 自定义 UI 组件

### 7.3 重构检查清单

**每个模块重构完成后检查：**
- [ ] 是否遵循 MVVM 架构
- [ ] 是否使用 RxSwift 进行数据绑定
- [ ] 是否使用 SnapKit 进行布局
- [ ] 是否遵循命名规范
- [ ] 是否消除循环引用
- [ ] 代码结构是否清晰易懂

## 8. 依赖管理

### 8.1 必需依赖

**核心框架：**
```ruby
# Podfile
pod 'RxSwift'
pod 'RxCocoa'
pod 'SnapKit'
```

### 8.2 版本管理

**规则：** 使用固定版本号，避免自动更新导致的兼容性问题。

**推荐版本：**
- RxSwift: ~> 6.0
- SnapKit: ~> 5.0

