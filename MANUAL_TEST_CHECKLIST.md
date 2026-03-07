# Manual Testing Checklist - Atomization Compliance Fixes

**Version**: 1.0
**Date**: 2026-03-06
**Estimated Time**: 15 minutes

---

## ✅ Pre-Test Setup

- [ ] Project built successfully (Cmd+B)
- [ ] App launched on simulator/device (Cmd+R)
- [ ] No crash on launch (Core Data migration succeeded)

---

## Test 1: Basic Atomization Flow (3 min)

### Objective
Verify that captures are split into atoms correctly.

### Steps
1. Open the app → Navigate to "记录" (Record) tab
2. Create a new text capture: **"我今天开会很烦，明天要整理思路"**
3. Wait for processing (should see loading indicator)
4. Tap the capture card to open detail sheet

### Expected Results
- [ ] Sheet opens with 3 tabs: "整理后" / "原始" / "拆分"
- [ ] "拆分" tab shows 2-3 atoms
- [ ] Each atom shows:
  - Type icon + label (事件/感受/行动 etc.)
  - Content text matching parts of original
  - Three-dot menu (...)

### Screenshot Locations
📸 Take screenshot of:
- Capture card in feed
- Detail sheet with "拆分" tab active

---

## Test 2: Source Traceability (2 min)

### Objective
Verify startChar/endChar are stored (data layer check).

### Steps
1. In previous test's atom list, note one atom's content
2. Open Xcode → View → Debug Area → Show Debug Area
3. In console, run:
   ```lldb
   po (try? context.fetch(NSFetchRequest<AtomEntity>(entityName: "AtomEntity"))).first?.startChar
   po (try? context.fetch(NSFetchRequest<AtomEntity>(entityName: "AtomEntity"))).first?.endChar
   ```

### Expected Results
- [ ] startChar shows a number >= 0 (e.g., 2)
- [ ] endChar shows a number > startChar (e.g., 6)
- [ ] If -1, it means fallback was used (also valid, but note it)

### Notes
If using OpenAI: should have valid offsets
If using Mock/Fallback: startChar/endChar = -1 (expected)

---

## Test 3: "Mark as Key" Feature (2 min)

### Objective
Verify the "标记为重点" menu item works.

### Steps
1. Open any capture → "拆分" tab
2. Tap any atom's three-dot menu (...)
3. Select **"标记为重点"**
4. Wait for UI refresh

### Expected Results
- [ ] Menu closes (no crash)
- [ ] Atom remains in list (not deleted)
- [ ] (Optional) Check in database:
   ```lldb
   po (try? context.fetch(NSFetchRequest<AtomEntity>(entityName: "AtomEntity"))).first?.isKey
   ```
   Should show `true`

### Screenshot Locations
📸 Take screenshot of:
- Three-dot menu with "标记为重点" visible

---

## Test 4: "Delete Atom" Feature (2 min)

### Objective
Verify the "删除" menu item works.

### Steps
1. Open any capture with multiple atoms → "拆分" tab
2. Note the total atom count (e.g., 3 atoms)
3. Tap any atom's three-dot menu (...)
4. Select **"删除"** (red text at bottom)
5. Observe the list

### Expected Results
- [ ] Menu closes (no crash)
- [ ] Atom is removed from list immediately
- [ ] Remaining atoms still visible
- [ ] Count decreased (e.g., 2 atoms remaining)

### Screenshot Locations
📸 Take screenshot of:
- Before delete (3 atoms)
- After delete (2 atoms)

---

## Test 5: Tag Assignment (3 min)

### Objective
Verify that only first atom gets visible tag suggestion.

### Steps
1. Create a new capture mentioning a project: **"Life Narrator 项目进度很慢"**
2. Wait for atomization
3. Open detail → "拆分" tab
4. Check each atom for tag pills

### Expected Results
- [ ] **First atom only** shows a tag pill with "建议" suffix
- [ ] Tag name is relevant (e.g., "Life Narrator · 建议")
- [ ] Other atoms have no visible suggested tags
- [ ] Tapping the suggested tag confirms it (removes "建议")

### Screenshot Locations
📸 Take screenshot of:
- Atom list showing first atom with "建议" tag

---

## Test 6: Privacy Redaction (3 min)

### Objective
Verify API keys are redacted in debug logs.

### Steps
1. Navigate to DevTools (shake device or use hidden menu)
2. Find **"AI Debug"** or **"诊断"** section
3. Locate recent atomization request
4. Expand request body

### Expected Results
- [ ] API keys show as `sk-***REDACTED***`
- [ ] Bearer tokens show as `Bearer ***REDACTED***`
- [ ] Email addresses (if any) show as `***@***.***`
- [ ] User content truncated if >100 chars

### Screenshot Locations
📸 Take screenshot of:
- Debug log entry with redacted API key

### If DevTools Not Accessible
Skip this test or check in Xcode console for log messages containing "REDACTED"

---

## Summary Checklist

### Core Functionality
- [ ] Test 1: Atomization works (atoms created)
- [ ] Test 2: Offsets stored (startChar/endChar valid or -1)
- [ ] Test 3: "Mark as key" works (no crash, isKey set)
- [ ] Test 4: "Delete" works (atom removed)

### Compliance
- [ ] Test 5: Tag assignment correct (1 visible to first atom)
- [ ] Test 6: Privacy redaction works (keys masked)

### Build & Stability
- [ ] No crashes during any test
- [ ] UI responsive and smooth
- [ ] Core Data migration successful (no data loss)

---

## 🐛 If Issues Found

### Issue: Atoms not appearing
**Check**: Did atomization complete? Look for "拆分失败" message
**Fix**: Tap "重试" button

### Issue: Menu items not working
**Check**: Did callbacks connect? Verify CaptureDetailSheet.swift:198-208
**Fix**: Rebuild project (Cmd+Shift+K → Cmd+B)

### Issue: Privacy not redacted
**Check**: Is AIDebugStore.swift using new redact() method?
**Fix**: Verify AIDebugStore.swift:36-89 matches Change-001

### Issue: Build crash on launch
**Check**: Core Data migration error?
**Fix**: Uninstall app, clean build folder, reinstall

---

## 📋 Test Result Template

Copy this to your notes:

```
=== Atomization Compliance Test Results ===
Date: ______
Tester: ______
Device: Simulator / iPhone [model]
iOS Version: ______

Test 1 - Atomization: PASS / FAIL
Test 2 - Offsets: PASS / FAIL / SKIP
Test 3 - Mark as Key: PASS / FAIL
Test 4 - Delete: PASS / FAIL
Test 5 - Tags: PASS / FAIL
Test 6 - Privacy: PASS / FAIL / SKIP

Overall: PASS / FAIL
Issues: (list any problems)

Screenshots attached: [ ] Yes [ ] No
```

---

## Next Steps After Testing

### If All Pass ✅
1. Update Session Log: Mark "Manual Testing" as completed
2. Consider implementing "查看来源" UI button
3. Add unit tests for AIDebugRedactor

### If Any Fail ❌
1. Document the failure in Change-001
2. Check rollback notes in Change-001
3. File an issue or create a new session log

---

## Questions?

Refer to:
- **Implementation**: `Docs/05_Changes/Change-001-atomization-compliance-fixes.md`
- **Verification Steps**: Section "Verification Steps" in Change-001
- **Rollback**: Section "Rollback Notes" in Change-001
- **Session Log**: `Docs/04_Sessions/2026-03-06_session-001.md`
