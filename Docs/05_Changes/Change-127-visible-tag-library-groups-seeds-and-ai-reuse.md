---
date: 2026-03-15
owner: Codex
scope: Tag System / AI Suggestions
status: Done
---

# Change Log

## What Changed
扩展了显性标签库的分组结构，预置了一批默认显性标签，并让 AI 标签建议优先复用标签库中的现有标签；只有在没有接近匹配时，才允许建议新显性标签。

## Files Changed
- `Life Narattor/Models/AtomItem.swift`
- `Life Narattor/Models/SearchModels.swift`
- `Life Narattor/Models/AtomizationModels.swift`
- `Life Narattor/AI/AIService.swift`
- `Life Narattor/Data/AtomizationCoordinator.swift`
- `Life Narattor/Data/PersistenceController.swift`
- `Life Narattor/Views/AddTagSheet.swift`
- `Life Narattor/Screens/TagManagerScreen.swift`
- `Life Narattor/Screens/ReviewByTagPickerScreen.swift`
- `server/server.js`

## User-Visible Impact
- 显性标签分组从 4 组扩展为 6 组：项目、习惯、主题、人物、目标、场景。
- 新安装或新初始化的数据库会自动带一批默认显性标签，便于后续复用。
- 标签管理和添加标签界面切换为菜单式分组选择，更适配较多标签分组。
- AI 标签建议会优先复用已有显性标签，减少重复或同义标签。

## Technical Summary
- 扩展 `TagType` 并同步更新搜索筛选映射。
- 新增一次性显性标签库播种逻辑，按缺失项补写默认标签。
- `loadTagLibrary()` 现在会加载 6 组显性标签并传给 AI。
- OpenAI 直连和 backend `/v1/tags` 路径都改成优先复用已有显性标签。
- `tagSuggestionSchema()` 对 `tag_type` 使用显式枚举限制，保证输出和本地模型一致。

## Verification Steps
1. 启动 app，进入标签管理页。
2. 确认标签类型中可见：项目、习惯、主题、人物、目标、场景。
3. 确认默认显性标签已播种到数据库中。
4. 触发一次 AI 标签建议，确认其优先复用已有标签，而不是总是新建。
5. 执行 `node --check '/Users/billyha/Desktop/Life Narattor/server/server.js'`。
6. 执行 Xcode build。

## Rollback Notes
- 如需回退到旧的 4 组标签，只需撤回 `TagType` 扩展与相关 UI 映射。
- 如需关闭默认标签库播种，可移除 `PersistenceController.swift` 中的播种调用和种子定义。
- 如需恢复 AI 自由创建标签，可撤回 `AIService.swift` 与 `server.js` 中的“优先复用已有标签”策略。
