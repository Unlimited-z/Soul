# Soul 项目开发规范

## 1. 自动布局规范

### 1.1 强制使用 SnapKit

**规则：** 项目中所有 UI 组件的自动布局必须使用 SnapKit 框架，禁止使用原生的 NSLayoutConstraint 或 Interface Builder。

**原因：**
- 代码更简洁易读
- 类型安全，减少运行时错误
- 更好的代码复用性
- 统一的代码风格

