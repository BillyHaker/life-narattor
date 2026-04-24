# Codex Execution Brief — 2026-03-06 Iter-001

**Brief 版本**: 1.0
**制作者**: Claude（规范与设计负责人）
**状态**: ✅ 待执行
**前序 session**: `Docs/04_Sessions/2026-03-06_session-001.md`
**前序修复参考**: `COMPLIANCE_FIX_SUMMARY.md`、`THREADING_FIX_FINAL.md`

---

## 1. 本次迭代目标

### 🎯 Goal 1 — 实现"查看来源"UI（Source Highlight View）

**背景**：上个 session（2026-03-06 session-001）已完成数据层：`AtomEntity` 新增 `startChar`、`endChar`、`atomizeVersion` 字段，并在 `AtomTagStore.createAtoms()` 中写入偏移量。但 UI 层尚未实现"点击 Atom → 高亮对应原文"的交互。

**价值**：完成 `Skills/atomization/SKILL.md` 中"可溯源性（P6 Traceability）"要求的最后一公里，让用户从 Atom 能直接追溯到原文片段（spec 中称为"来源"链接）。

---

### 🎯 Goal 2 — 添加核心合规逻辑的单元测试

**背景**：上个 session 修复了 7 个合规问题，包括 `AIDebugRedactor` 隐私脱敏（P0 关键）、`markAsKey`、`deleteAtom` 等。目前测试覆盖率为 0，存在回归风险。

**价值**：为隐私脱敏和原子操作建立安全网，防止未来改动破坏合规性。

---

## 2. Definition of Done（验收标准）

### Goal 1 验收标准
来源：`Skills/atomization/SKILL.md` — Acceptance Criteria + Interactions 章节

- [ ] Atom 列表（拆分 tab）中，每个拥有有效 `startChar/endChar`（≥ 0 且 endChar > startChar）的 Atom，显示一个"来源"链接或按钮
- [ ] 点击"来源"后，以覆盖层（sheet 或 overlay）展示整理后（Clean）文本，并高亮 `cleanText[startChar..<endChar]` 范围
- [ ] 对于老数据（`startChar/endChar` 为 nil 或默认 -1），不显示"来源"入口，静默降级
- [ ] Bounds check：若偏移超出 `cleanText.count`，不崩溃，显示"来源数据不完整"提示
- [ ] 不修改 Raw 存储，不触发 AI 重新运算
- [ ] Session Log 和 Change Log 已按规范创建

### Goal 2 验收标准
来源：`Rules/TDD_GUIDE.md` + `Skills/acceptance-testing-min-bar/SKILL.md`

- [ ] `AIDebugRedactor.redact()` 覆盖 5 个 test case（见下方 Test Cases 表格）
- [ ] `AtomTagStore.markAsKey(atomID:)` 验证 `isKey` 持久化（写入后读回 == true）
- [ ] `AtomTagStore.deleteAtom(atomID:)` 验证原子和关联 `AtomTagEntity` 均被删除
- [ ] `Cmd+U` → 所有新测试 Build + Pass，无 flaky
- [ ] Session Log 和 Change Log 已按规范创建

---

## 3. 风险与不改动范围

### 🚫 绝对冻结区（Frozen Zones）— 不得碰

| 文件 / 模块 | 原因 |
|------------|------|
| `PersistenceController.swift` | CoreData schema 刚在上个 session 完成迁移，已稳定 |
| `AtomizationCoordinator.swift` | 线程模型刚完成修复（见 `THREADING_FIX_FINAL.md`），@MainActor 逻辑不得改动 |
| `AIService.swift` | AI 调用入口，本次迭代不涉及 |
| `AIDebugStore.swift` — redact() 方法本体 | Goal 2 只写测试，不改实现 |
| `*.xcodeproj` / `.xcworkspace` | Xcode 项目配置 |
| `Rules/`、`Skills/`、`Docs/` | 规范文档由设计负责人维护 |

### ⚠️ 已知风险与缓解

| 风险 | 说明 | 缓解方案 |
|------|------|----------|
| CoreData 线程安全 | `cleanText` 读取需要在 MainActor | 在 UI 层（SwiftUI View）访问，已在主线程；如在 Task 中访问，需 `MainActor.run {}` |
| 偏移越界 | `startChar`/`endChar` 可能因数据问题超出 `cleanText` 长度 | `clamp`：`let safeEnd = min(endChar, cleanText.count)` |
| Int16 溢出 | `startChar` 为 Int16，最大 32767 | 超长 clean text 时偏移可能截断；V1 可不处理，仅记录 |
| in-memory CoreData 初始化 | 单元测试需要 preview container | 使用 `PersistenceController.preview`（已有实现） |
| `AttributedString` 中文字符边界 | 中文字符索引与 Swift `String.Index` 需对齐 | 使用 `cleanText.index(cleanText.startIndex, offsetBy: startChar)` |

---

## 4. 影响文件（仅路径，Codex 执行时按需修改）

### Goal 1 — Source Highlight UI

```
Life Narattor/Views/CaptureDetailSheet.swift       # 主改动：Atoms tab 的 Atom Row，添加"来源"按钮 + 触发 state
Life Narattor/Views/AtomDetailSheet.swift          # 次改动（可选）：Traceability section（spec 已定义此位置）
```

### Goal 2 — Unit Tests

新建文件（推荐）：
```
Life NarattorTests/AIDebugRedactorTests.swift      # 新建：隐私脱敏单元测试
Life NarattorTests/AtomTagStoreTests.swift         # 新建：原子操作单元测试
```

或扩展现有文件：
```
Life NarattorTests/Life_NarattorTests.swift        # 扩展：添加上述测试 class
```

### 必须创建的文档文件

```
Docs/04_Sessions/2026-03-06_session-002.md         # Session Log（本次迭代）
Docs/05_Changes/Change-049-source-highlight-ui.md  # Change Log for Goal 1
Docs/05_Changes/Change-050-unit-tests-compliance.md # Change Log for Goal 2
```

---

## 5. 给 Codex 的指令

### 5.0 上下文加载顺序（按顺序读，不要跳过）

执行前必须按顺序读完以下文件：

1. `Rules/AI_RULES.md` — 基本规则
2. `Rules/DEV_LOG_RULES.md` — 文档规范（理解 Session Log / Change Log 要求）
3. `Skills/atomization/SKILL.md` — 重点阅读：
   - "Atoms tab" 组件说明
   - "来源" link 的描述（Traceability section）
   - Acceptance criteria
4. `Skills/capture-ui/SKILL.md` — 重点阅读：Atom list row 的 `…` 菜单结构
5. `Skills/privacy-redaction-standard/SKILL.md` — 了解 5 个 redaction patterns 和 test cases
6. `COMPLIANCE_FIX_SUMMARY.md` — 了解 startChar/endChar 数据层实现细节
7. `Life Narattor/Views/CaptureDetailSheet.swift` — 了解 Atoms tab 现有 UI 结构
8. `Life Narattor/DevTools/AIDebugStore.swift` — 了解 `AIDebugRedactor.redact()` 实现
9. `Life Narattor/Data/AtomTagStore.swift` — 了解 `markAsKey`、`deleteAtom` 方法签名

---

### 5.1 先建 Session Log（第一步，写任何代码前必做）

创建 `Docs/04_Sessions/2026-03-06_session-002.md`，使用 `Templates/SESSION_LOG_TEMPLATE.md` 模板，填入：
- **Goal**：本次迭代两个目标（来源高亮 UI + 单元测试）
- **Related Skills**：atomization, capture-ui, acceptance-testing-min-bar, privacy-redaction-standard
- **Plan**：Step 1–5 的简要说明
- 其他字段在执行过程中填写

---

### 5.2 Goal 1 — Implementation Steps

#### Step G1-1：读 CaptureDetailSheet.swift，找到 Atoms tab 的 Atom Row 渲染位置

找到 Atom 行的渲染代码（应有 `ForEach` 遍历 atoms），确认 `atom.startChar` 和 `atom.endChar` 已可访问（类型为 `Int16?` 或 `Int16`）。

#### Step G1-2：添加"来源"按钮的状态变量

在 `CaptureDetailSheet` 的 `@State` 中添加：
```swift
@State private var highlightedSourceRange: Range<Int>? = nil
@State private var showingSourceHighlight: Bool = false
```

#### Step G1-3：在 Atom Row 中条件渲染"来源"按钮

在每个 Atom Row（tag pills 之后，或 `…` 菜单下方）添加：

```swift
// 仅当有效偏移时显示
let sc = Int(atom.startChar)
let ec = Int(atom.endChar)
if atom.startChar >= 0, ec > sc {
    Button("来源") {
        highlightedSourceRange = sc..<ec
        showingSourceHighlight = true
    }
    .font(.caption)
    .foregroundColor(.secondary)
}
```

对于 `startChar` 为 nil 或 -1（老数据）的 Atom，不渲染此按钮。

#### Step G1-4：实现来源高亮覆盖层

使用 `.sheet` 或 `.popover` 展示 Clean 文本并高亮范围：

```swift
.sheet(isPresented: $showingSourceHighlight) {
    // 获取 cleanText
    if let cleanText = capture.cleanText,
       let range = highlightedSourceRange {
        let safeStart = min(range.lowerBound, cleanText.count)
        let safeEnd   = min(range.upperBound, cleanText.count)
        if safeEnd > safeStart {
            let highlighted = buildAttributedString(
                text: cleanText,
                highlightRange: safeStart..<safeEnd
            )
            ScrollView {
                Text(highlighted)
                    .padding()
            }
            .navigationTitle("整理后（来源）")
        } else {
            Text("来源数据不完整")
                .foregroundColor(.secondary)
                .padding()
        }
    }
}
```

`buildAttributedString` 使用 `AttributedString`，对 highlight 范围加黄色背景或粗体。注意用 `String.index(offsetBy:)` 进行正确的 Unicode 字符索引，避免中文字符边界问题。

#### Step G1-5：在整理后（Clean）tab 可选高亮

可选实现：在 Clean tab 查看时，若用户刚从"来源"进入，也高亮对应片段。这是 nice-to-have，如果时间允许再做。

---

### 5.3 Goal 2 — Implementation Steps

#### Step G2-1：新建 AIDebugRedactorTests.swift

```swift
import XCTest
@testable import Life_Narattor  // 或正确的 module 名

final class AIDebugRedactorTests: XCTestCase {

    func test_sk_prefix_is_redacted() {
        let input = "Authorization: sk-abc123XYZ456789abcdef"
        let result = AIDebugRedactor.redact(input)
        XCTAssertFalse(result.contains("sk-abc123"), "API key should be redacted")
        XCTAssertTrue(result.contains("***REDACTED***"))
    }

    func test_bearer_token_is_redacted() {
        let input = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xyz"
        let result = AIDebugRedactor.redact(input)
        XCTAssertFalse(result.contains("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"))
        XCTAssertTrue(result.contains("***REDACTED***"))
    }

    func test_api_key_in_json_is_redacted() {
        let input = #"{"api_key": "my-super-secret"}"#
        let result = AIDebugRedactor.redact(input)
        XCTAssertFalse(result.contains("my-super-secret"))
    }

    func test_email_is_redacted() {
        let input = "Contact: user@example.com for support"
        let result = AIDebugRedactor.redact(input)
        XCTAssertFalse(result.contains("user@example.com"))
        XCTAssertTrue(result.contains("***@***.***"))
    }

    func test_long_content_is_truncated() {
        let input = String(repeating: "A", count: 150)
        let result = AIDebugRedactor.redact(input)
        XCTAssertTrue(result.count <= 120, "Should be truncated")
        XCTAssertTrue(result.contains("TRUNCATED") || result.count <= 105)
    }
}
```

#### Step G2-2：新建 AtomTagStoreTests.swift

使用 in-memory CoreData 容器（`PersistenceController.preview`）：

```swift
import XCTest
import CoreData
@testable import Life_Narattor

final class AtomTagStoreTests: XCTestCase {

    var store: AtomTagStore!
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        // 使用 in-memory container
        let controller = PersistenceController(inMemory: true)
        context = controller.container.viewContext
        store = AtomTagStore(context: context)
    }

    // MARK: - markAsKey

    func test_markAsKey_sets_isKey_true() throws {
        // Setup: create a capture + atom
        let capture = CaptureEntity(context: context)
        capture.id = UUID()
        capture.rawText = "测试内容"
        capture.createdAt = Date()

        let atom = AtomEntity(context: context)
        atom.id = UUID()
        atom.capture = capture
        atom.content = "测试拆分"
        atom.atomType = "event"
        atom.isKey = false
        try context.save()

        // Act
        store.markAsKey(atomID: atom.id!)

        // Assert
        let fetched = try context.fetch(AtomEntity.fetchRequest()).first { $0.id == atom.id }
        XCTAssertEqual(fetched?.isKey, true)
    }

    // MARK: - deleteAtom

    func test_deleteAtom_removes_atom_and_its_tags() throws {
        // Setup
        let capture = CaptureEntity(context: context)
        capture.id = UUID()
        capture.rawText = "测试"
        capture.createdAt = Date()

        let atom = AtomEntity(context: context)
        atom.id = UUID()
        atom.capture = capture
        atom.content = "要删除的 Atom"
        atom.atomType = "event"

        let tag = AtomTagEntity(context: context)
        tag.id = UUID()
        tag.atom = atom
        tag.tagName = "test-tag"
        try context.save()

        let atomID = atom.id!

        // Act
        store.deleteAtom(atomID: atomID)

        // Assert: atom 不存在
        let atoms = try context.fetch(AtomEntity.fetchRequest())
        XCTAssertFalse(atoms.contains { $0.id == atomID }, "Atom should be deleted")

        // Assert: 关联 tag 不存在（级联删除）
        let tags = try context.fetch(AtomTagEntity.fetchRequest())
        XCTAssertFalse(tags.contains { $0.atom?.id == atomID }, "Tags should be cascade deleted")
    }
}
```

> **注意**：如果 `PersistenceController` 没有 `init(inMemory:)` 构造器，查看现有 preview 初始化方式并对齐。如 `AtomTagStore` 的初始化签名不同，按实际签名调整。

#### Step G2-3：确认 Test Target 引用

在 Xcode 中确认 `Life NarattorTests` target 包含新建的测试文件（如果用 Xcode 新建文件，会自动加入；如果手动创建，需要在 `project.pbxproj` 中添加引用——但修改 `.xcodeproj` 仅限于添加测试文件，不改业务逻辑）。

---

### 5.4 Verification Steps（验证步骤）

执行顺序：

1. **Build 验证**
   ```
   Xcode: Cmd+B
   预期: 0 errors（warnings 可接受，需记录）
   ```

2. **Unit Tests**
   ```
   Xcode: Cmd+U
   预期: 所有 AIDebugRedactorTests + AtomTagStoreTests Pass
   ```

3. **UI 手动测试 — Source Highlight**
   ```
   前置条件：需要 OpenAI API Key 配置（DevTools → Keychain）以获得真实 startChar/endChar

   步骤：
   a. Clean Build Folder (Cmd+Shift+K) → Run (Cmd+R)
   b. 创建 Capture："我今天开完会很烦，明天要整理一下思路"
   c. 等待 atomization 完成（3-10 秒，UI 显示"正在拆分…"再变为"已拆成 X 条"）
   d. 点击 Capture Card → 进入详情 → 切换到"拆分"tab
   e. ✅ 有 startChar/endChar 的 Atom 显示"来源"链接
   f. 点击"来源" → ✅ 弹出 Clean 文本，对应片段高亮
   g. 测试老 Atom（无偏移）：✅ 不显示"来源"，不报错
   h. 测试 UI 稳定性：快速开关 sheet，无崩溃
   ```

4. **隐私验证（顺带验证）**
   ```
   步骤：
   a. DevTools → AI Debug 标签
   b. 触发一次 atomization
   c. ✅ 请求 body 中 API key 显示为 "sk-***REDACTED***"
   d. ✅ 无原始 Bearer token
   ```

---

### 5.5 必须创建的日志文件

| 文件路径 | 使用模板 | 必须包含字段 |
|----------|----------|-------------|
| `Docs/04_Sessions/2026-03-06_session-002.md` | `Templates/SESSION_LOG_TEMPLATE.md` | goal, plan, work log（时间戳），decisions, changes（链接到 Change-049/050），verification，handover notes |
| `Docs/05_Changes/Change-049-source-highlight-ui.md` | `Templates/CHANGELOG_TEMPLATE.md` | summary, files changed（含行号区间），verification steps，rollback notes |
| `Docs/05_Changes/Change-050-unit-tests-compliance.md` | `Templates/CHANGELOG_TEMPLATE.md` | summary, test names 列表，test results，如何运行 |

> **格式要求**（来自 `Rules/DEV_LOG_RULES.md`）：
> - 每个文档必须含 metadata：date、owner（Codex）、scope（UI / Tests）、related skills、status
> - Change Log 必须含 verification steps 和 rollback notes
> - Session Log 必须含 handover notes（下一步是什么、哪些文件重要）

---

## 6. 关键决策约束（勿改）

| 约束 | 说明 |
|------|------|
| `startChar`/`endChar` 是 Int16 | 最大 32767；超长文本的偏移可能截断，V1 可不处理 |
| CoreData 操作在 MainActor | `AtomTagStore` 所有写操作须在主线程；SwiftUI View 中默认满足 |
| 测试中禁止真实 API Key | 测试文件内只用假 key（如 `"sk-test1234567890abcdef"`），防止意外提交泄露 |
| 本次无需新 ADR | Goal 1/2 均为 additive UI + tests，无架构决策变更 |
| 保持 Log mode 默认 | capture-ui skill 要求每次 app 启动默认 Log 模式，不改此行为 |

---

## 7. 排期建议

| 步骤 | 估时 | 优先级 |
|------|------|--------|
| 读 context 文件（5.0 节） | 10 min | P0 |
| 建 Session Log | 5 min | P0 |
| Goal 1：Source Highlight UI | 45–60 min | P0 |
| Goal 2：Unit Tests | 30–45 min | P0 |
| 建 Change Log × 2 | 10 min | P0 |
| 更新 Session Log handover | 5 min | P0 |
| **Total** | **~2 小时** | |

---

## 8. 超出本次范围（勿在此次迭代中做）

以下为已知 backlog，**不在本次 Brief 范围内**，Codex 遇到时跳过：

- 语音转写真实实现（占位现状，需单独 Brief）
- AI Prompts 添加中文示例（需 AIService.swift 变更 + ADR）
- Fallback atomization 改进（emotion/action 检测）
- Soft delete（添加 `deletedAt` 字段）—— 涉及 CoreData schema，需单独迭代

---

*Brief 结束。如有疑问，参考 `ONBOARDING_GUIDE.md` 的完整参考内容。*
