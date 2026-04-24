---
name: ia-navigation
description: Defines Life Narrator V1 information architecture, primary tabs, secondary screens, and navigation rules (including empty/loading/error states). Use this when implementing navigation, routing, and page layouts.
metadata:
  product: life-narrator
  version: "0.1"
---

# IA Navigation

## Primary navigation (V1)
Bottom Tab Bar (4 tabs):
1. **Record** (Capture Feed)
2. **Timeline**
3. **Projects**
4. **Review**

No “Chat” tab. This product is record-first.

## Screen map

### 1) Record (Capture Feed)
- `RecordFeedScreen` (default)
- `CaptureDetailSheet` (expand a capture: Clean/Raw/Atoms)
- `AddTagSheet` (attach explicit tags)
- `AudioRecorderOverlay` (press/hold)
- `AudioPlaybackSheet` (optional)

### 2) Timeline
- `TimelineScreen` (range selector: Today / Week / Month / Custom)
- `DayDetailScreen` (daily narrative + AI comment styles + sources)
- `EditSelfNarrativeScreen` (edits only layer 1)
- `SourcesSheet` (“来自 9:12” mappings)

### 3) Projects
- `ProjectsListScreen`
- `ProjectDetailScreen` with subtabs:
  - `ProjectTimelineTab`
  - `ProjectReviewTab` (project narrative + AI comment)
  - (Optional later) `ProjectDecisionsTab` / `ProjectBlockersTab`
- `TagManagerScreen` (manage explicit tags; entry: top-right gear)

### 4) Review
- `ReviewHomeScreen` (Week / Month / By Project + Memory snippets)
- `WeeklyReviewScreen` (self narrative + AI comment)
- `MonthlyReviewScreen` (self narrative + AI comment)
- (Optional) `ReviewByProjectPicker`

### Shared
- `SearchScreen` (can be accessed from Review or as a top-right icon in Timeline/Review)
- `SettingsScreen` (comment style default, reminder time, tone)

## Navigation rules
- Record feed is the default entry after launch.
- Deep outputs always land in Day/Review/Project screens, never in Record feed as a “chat bubble”.

## State design (must implement)
### Empty states
- Record feed: “还没有记录。随手记一句就好。”
- Timeline: “今天还没有足够记录生成日记。”
- Projects: “还没有项目。创建一个项目标签，之后好整理回顾。”
- Review: “还没有可回顾内容。先记录几条，晚上回来看看。”

### Loading states
- Use small inline status under each capture:
  - “整理中…” → “已去停顿” → “已拆分为 3 条”
- For deep tasks: full-screen progress with cancel:
  - “在整理…” + subtle progress stages

### Error states
- AI job failed: show “整理失败，点此重试”
- Audio transcription failed: “转写失败，保留原音频”
