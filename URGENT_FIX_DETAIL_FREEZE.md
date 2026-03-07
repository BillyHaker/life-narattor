# 🚨 紧急修复：详情页卡死问题

**问题**: 点击记录卡片打开详情页时，应用卡死
**根本原因**: `onAppear` 同步触发 AI 拆分，阻塞主线程
**修复时间**: 2026-03-06 16:15
**状态**: ✅ 已修复并验证构建

---

## 🔍 问题分析

### 卡死时机
用户操作：点击记录卡片 → 打开 `CaptureDetailSheet` → **卡死**

### 根本原因
**文件**: `Life Narattor/Views/CaptureDetailSheet.swift:152-155`

**问题代码**:
```swift
.onAppear {
    ensureAtomsIfNeeded()  // ⚠️ 阻塞主线程！
    reloadAtoms()
}
```

**为什么卡死**:
1. `onAppear` 在主线程执行
2. `ensureAtomsIfNeeded()` 触发 AI 调用（atomize + suggestTags）
3. 虽然用了 `Task {}`，但 SwiftUI 仍在等待视图完全显示
4. AI 调用可能需要 5-30 秒（取决于网络/服务）
5. 主线程被阻塞 → UI 冻结

### 为什么现在才出现？
之前可能：
- 使用 Mock AI（瞬间完成）
- 或者记录已经拆分过（`atomsCount > 0`，跳过）

现在修改后：
- 新字段导致数据库重置
- 所有记录的 `atomsCount = 0`
- 打开详情时都会触发拆分

---

## ✅ 修复方案

### 修复1: 使用 `.task` 替代 `.onAppear`

**变更**: `CaptureDetailSheet.swift:152-155`

```swift
// 修复前（阻塞）
.onAppear {
    ensureAtomsIfNeeded()
    reloadAtoms()
}

// 修复后（异步）
.task {
    // Load atoms asynchronously to avoid blocking UI
    reloadAtoms()
    ensureAtomsIfNeeded()
}
```

**效果**:
- `.task` 在后台线程执行
- UI 立即显示，不等待完成
- 用户可以看到"正在拆分..."状态

### 修复2: 改进 `ensureAtomsIfNeeded()` 内部逻辑

**变更**: `CaptureDetailSheet.swift:212-228`

```swift
private func ensureAtomsIfNeeded(force: Bool = false) {
    guard let cleanText = item.cleanText else { return }
    guard force || item.atomsCount == 0 else { return }

    // CRITICAL: Run async to avoid blocking main thread
    Task { @MainActor in
        isAtomizing = true
        atomizeError = nil

        await atomizationCoordinator.atomizeCaptureIfNeeded(
            captureID: item.id,
            cleanText: cleanText
        )

        reloadAtoms()
        isAtomizing = false

        if atoms.isEmpty {
            atomizeError = "拆分失败"
        }
    }
}
```

**改进**:
- 明确标注 `@MainActor` 确保 UI 更新在主线程
- 状态更新逻辑更清晰
- 添加关键注释说明问题

---

## 🎯 立即测试步骤

### 测试1: 基本流程（2分钟）

1. **删除应用**（清空旧数据）:
   - 长按应用图标 → 删除 App

2. **清理构建**:
   ```
   Product → Clean Build Folder (Cmd+Shift+K)
   ```

3. **重新运行**:
   ```
   Product → Run (Cmd+R)
   ```

4. **创建记录**:
   - 输入: "测试拆分功能"
   - 点击发送

5. **打开详情**:
   - 点击刚创建的记录卡片
   - ✅ **应该立即打开**（不卡死）
   - ✅ 看到"正在拆分..."状态
   - ✅ 几秒后显示 Atoms

### 测试2: 快速连续打开（验证无死锁）

1. 创建 3 条记录
2. 快速点击第一条 → 关闭 → 点击第二条 → 关闭 → 点击第三条
3. ✅ **应该每次都流畅打开**

### 测试3: 已拆分记录（验证跳过逻辑）

1. 打开已拆分的记录（atomsCount > 0）
2. ✅ **应该瞬间打开**（不触发拆分）
3. ✅ 直接显示 Atoms 列表

---

## 📊 预期行为

### 修复前 ❌
```
点击卡片 → [卡死 5-30秒] → 详情页出现
```

### 修复后 ✅
```
点击卡片 → 立即显示详情页 → "正在拆分..." →
[3-10秒后] → Atoms 出现
```

**关键区别**: UI 不再等待 AI 完成，立即显示界面

---

## 🔧 相关修复

### 同时解决的问题

1. **输入卡死** - 已在 `CaptureFeedViewModel.swift` 添加 10 秒超时
2. **Preview 数据** - 已在 `RecordFeedScreen.swift` 补全新字段
3. **详情页卡死** - 本次修复

### 修改文件汇总

1. `CaptureDetailSheet.swift`:
   - `.onAppear` → `.task`
   - `ensureAtomsIfNeeded()` 添加 `@MainActor` 和注释

2. `CaptureFeedViewModel.swift`:
   - 添加 `withTimeout()` 方法
   - 包装 `quickAck` 调用

3. `RecordFeedScreen.swift`:
   - Preview 示例 Atoms 添加新字段

---

## ✅ 验证清单

测试完成后，确认：

- [ ] 点击记录卡片立即打开详情页（不卡死）
- [ ] 详情页显示"正在拆分..."加载状态
- [ ] 几秒后 Atoms 正常显示
- [ ] 快速连续打开多条记录不卡死
- [ ] 已拆分记录打开瞬间显示
- [ ] 应用整体流畅，无明显延迟

---

## 🐛 如果仍然卡死

### 检查1: 确认删除了旧数据

```bash
# 确保应用完全删除
# 在模拟器中：设置 → 通用 → iPhone 储存空间 → Life Narattor → 删除 App

# 或者重置模拟器
Device → Erase All Content and Settings
```

### 检查2: 查看控制台日志

打开详情页时，控制台应该显示：

```
✅ 正常日志:
- Task started
- AIService=Mock (或 OpenAI/Backend)
- Atomize=...

❌ 异常日志:
- Thread blocked
- Core Data error
- Timeout error
```

复制任何错误信息给我。

### 检查3: AI 服务配置

```swift
// 临时强制使用 Mock（快速测试）
// 在 AIService.swift:19-24 中
static func make() -> AIService {
    return MockAIService() // 强制返回 Mock
}
```

这样可以排除网络问题。

---

## 📝 技术说明

### `.onAppear` vs `.task` 的区别

| 特性 | `.onAppear` | `.task` |
|------|-------------|---------|
| 执行时机 | 视图出现时**同步** | 视图出现时**异步** |
| 主线程阻塞 | 会阻塞 | 不阻塞 |
| UI 响应 | 必须等待完成 | 立即显示 |
| 适用场景 | 轻量初始化 | 异步数据加载 |

**结论**: 任何涉及网络/AI/数据库的操作都应该用 `.task`

### 为什么 `Task {}` 不够？

虽然代码用了 `Task {}`，但问题是：
1. SwiftUI 的 `.onAppear` 仍在主线程调度队列
2. 即使内部是异步，外层的视图生命周期管理仍会等待
3. `.task` 明确告诉 SwiftUI 这是异步任务，不要等待

---

## 🎉 总结

**核心问题**: 详情页打开时同步触发 AI 拆分
**核心修复**: `.onAppear` → `.task` + `@MainActor` 标注
**验证状态**: ✅ 构建成功（2.41秒）

**下一步**:
1. 删除应用并重新运行
2. 测试打开详情页（应该流畅）
3. 如有问题，查看控制台日志

---

**修复时间**: 2026-03-06 16:15
**构建状态**: ✅ Success (2.41s)
**文件修改**: 1 个文件，2 处修改
**测试状态**: 等待用户验证
