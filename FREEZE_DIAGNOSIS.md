
---

**修复结果**: 已添加 10 秒超时保护

**修改文件**: `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- 添加 `withTimeout()` 方法
- 在 `updateQuickAck()` 中包装 AI 调用
- 添加错误日志输出

**构建状态**: ✅ 成功

---

## 📋 立即尝试的步骤

### 方案A: 删除应用数据重试（推荐）

1. **停止应用**（如果正在运行）

2. **删除应用**:
   ```
   # 在模拟器中：长按应用图标 → 删除 App
   # 或者在 Xcode:
   Window → Devices and Simulators → 选择模拟器 → 
   找到 Life Narattor → 点击 - 删除
   ```

3. **清理构建**:
   ```
   Xcode 菜单: Product → Clean Build Folder (Cmd+Shift+K)
   ```

4. **重新运行**:
   ```
   Product → Run (Cmd+R)
   ```

5. **测试输入**: 输入简单文字，点击发送

### 方案B: 查看控制台日志

如果删除后仍卡死，查看 Xcode 控制台：

1. **打开控制台**: View → Debug Area → Activate Console (Cmd+Shift+Y)

2. **重现卡死**: 输入文字 → 点击发送

3. **查找关键信息**:
   - `Core Data error`: 数据库迁移失败
   - `QuickAck failed`: AI 调用超时
   - `Unresolved error`: 致命错误
   - 任何红色错误信息

4. **复制错误信息**发给我，我可以进一步诊断

---

## 🔧 如果仍然卡死

### 检查项1: 是否有旧数据库文件

```bash
# 查找模拟器数据目录
~/Library/Developer/CoreSimulator/Devices/
# 在其中搜索 Life Narattor 相关的 .sqlite 文件
# 如果找到，删除它们
```

### 检查项2: AI 服务配置

当前使用的 AI 服务:
- 如果配置了 `OPENAI_API_KEY`: 使用 OpenAI（可能超时）
- 如果配置了 `LIFENARRATOR_AI_BASE`: 使用后端（可能无法连接）
- 否则: 使用 Mock 服务（应该很快）

**验证**: 在 Xcode 控制台查找 "AIService=" 日志

如果看到 `AIService=OpenAI` 或 `AIService=Backend`，但网络不通，就会卡住 10 秒（现在有超时了）。

**临时解决**: 在 DevTools 中启用 "Mock AI" 标志（如果有）

### 检查项3: 查看 CPU 占用

在卡死时：
1. Xcode → Debug → View Hierarchy (Cmd+F7)
2. 查看主线程是否阻塞
3. 点击 Debug Navigator (Cmd+7) 查看线程状态

---

## ✅ 预期正常流程

修复后，正常流程应该是：

1. **输入文字** → 点击发送
2. **立即清空输入框** ✓
3. **卡片出现在顶部** ✓（显示 "整理中..." 或类似状态）
4. **1-10秒后更新** ✓（显示 "✅ 已记下" + 确认文字）
5. **点击卡片** → 打开详情页，看到"拆分"标签

如果在步骤2就卡住，是 Core Data 问题。
如果在步骤3-4卡住，是 AI 调用问题（现在有10秒超时）。

---

## 📞 需要帮助？

如果尝试所有方案后仍卡死，请提供：

1. **Xcode 控制台的完整输出**（从点击发送开始）
2. **是在 Preview 还是模拟器测试？**
3. **卡死时是否能切换到其他 tab？**（判断是否完全冻结）
4. **设备型号**: iPhone 15 Pro / iPad / Mac Catalyst
5. **iOS 版本**: 17.x / 18.x

我会根据这些信息进一步分析。

---

**更新时间**: 2026-03-06 16:00
**状态**: 已添加超时保护 + Preview 数据修复
**下一步**: 删除应用重试，观察控制台
