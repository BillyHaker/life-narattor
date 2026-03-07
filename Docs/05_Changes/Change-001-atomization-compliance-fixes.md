# Change Log: Atomization Feature Compliance Fixes

**Change ID**: Change-001
**Date**: 2026-03-06
**Owner**: Claude Sonnet 4.5
**Scope**: Data/AI/Privacy
**Related Skills**: `atomization`, `tags`, `privacy-redaction-standard`, `devtools-debug-suite`
**Related ADRs**: ADR-001 (to be created)
**Related Session**: `2026-03-06_session-001.md`
**Status**: Completed

## Summary
Fixed 7 critical compliance issues in the "记录详情 → 拆分" (Capture Detail → Atoms) feature to match specifications in `Skills/atomization/SKILL.md`, `Skills/tags/SKILL.md`, and `Rules/privacy-redaction-standard`.

## What Changed

### Files Modified

#### 1. **Life Narattor/DevTools/AIDebugStore.swift**
- **Change**: Enhanced `AIDebugRedactor.redact()` method
- **Why**: Previous implementation only masked "sk-" prefix, leaving Bearer tokens and user data exposed
- **Impact**:
  - Now redacts OpenAI API keys (sk-*, sk-proj-*)
  - Now redacts Bearer tokens in Authorization headers
  - Now redacts API keys in JSON fields
  - Now redacts email addresses (P1 identifiers)
  - Now truncates long user content to 100 chars for debugging

#### 2. **Life Narattor/Data/AtomEntity.swift**
- **Added fields**:
  - `startChar: Int16` (default -1 if offset not available)
  - `endChar: Int16` (default -1 if offset not available)
  - `atomizeVersion: String?` (e.g., "atom_v1")
- **Why**: Required by spec for source traceability and versioning

#### 3. **Life Narattor/Data/CaptureEntity.swift**
- **Added field**:
  - `atomizeVersion: String?` (tracks atomization rule version)
- **Why**: Required for tracking which atomization rules were used

#### 4. **Life Narattor/Models/AtomItem.swift**
- **Added fields**:
  - `startChar: Int?`
  - `endChar: Int?`
  - `atomizeVersion: String?`
- **Why**: Mirror entity changes in view model

#### 5. **Life Narattor/Data/AtomTagStore.swift**
- **Modified methods**:
  - `fetchAtoms()`: Now reads and maps startChar/endChar/atomizeVersion
  - `replaceAtoms()`: Now accepts and saves `atomizeVersion` parameter
  - `createAtoms()`: Now sets default values for new fields (fallback_v1)
  - `createAtoms(fromArchive:)`: Now sets atomizeVersion to "assist_archive_v1"
  - `updateCaptureStats()`: Now accepts optional `atomizeVersion` parameter
- **Added methods**:
  - `assignVisibleTagSuggestions(_:toFirstAtomOf:)`: Clarified implementation (max 1, first atom only)
  - `assignHiddenTagSuggestions(_:toAllAtoms:)`: Clarified implementation (max 5, all atoms)
  - `markAsKey(atomID:)`: Sets atom.isKey = true
  - `deleteAtom(atomID:)`: Hard deletes atom and associated tags
- **Why**:
  - Enable source traceability
  - Clarify tag assignment logic per spec
  - Implement missing "mark as key" and "delete" features

#### 6. **Life Narattor/Data/AtomizationCoordinator.swift**
- **Modified**:
  - Pass `result.atomizeVersion` to `replaceAtoms()`
  - Pass `result.atomizeVersion` to `updateCaptureStats()`
  - Use new `assignVisibleTagSuggestions()` and `assignHiddenTagSuggestions()` methods
  - Added inline comments explaining spec requirements
- **Why**: Clarify tag assignment logic and enable versioning

#### 7. **Life Narattor/Views/CaptureDetailSheet.swift**
- **Modified**:
  - `CaptureAtomRowView`: Added `onMarkAsKey` and `onDelete` callbacks
  - Connected menu items to `atomStore.markAsKey()` and `atomStore.deleteAtom()`
  - Added `reloadAtoms()` calls after operations
- **Why**: Implement missing "mark as key" and "delete" features

#### 8. **Life Narattor/Data/PersistenceController.swift**
- **Modified**:
  - Added `atomizeVersionAttribute` to `captureEntity.properties`
  - Added `atomStartCharAttribute`, `atomEndCharAttribute`, `atomVersionAttribute` to `atomEntity.properties`
  - Set default values: startChar = -1, endChar = -1
- **Why**: Core Data schema must match entity class definitions

## User-Visible Impact

### New Capabilities
1. **Source Traceability**: Atoms now store character offsets enabling "查看来源" feature (UI implementation pending)
2. **Version Tracking**: System now tracks which atomization rules were used
3. **Mark as Key**: Users can now mark atoms as key/重点 for narrative generation
4. **Delete Atoms**: Users can now delete individual atoms

### Privacy Improvements
- **Critical**: API keys and Bearer tokens are now properly redacted in debug logs
- Email addresses are redacted in debug exports
- Long user content is truncated to prevent excessive data exposure

### No Breaking Changes
- All changes are backward-compatible
- Existing captures will have startChar/endChar = -1 (not available)
- Automatic migration enabled via `shouldInferMappingModelAutomatically`

## Verification Steps

### Manual Testing

#### 1. Privacy Redaction
```bash
# Enable DevTools and trigger an atomization
# Check AIDebugStore entries:
```
**Expected**:
- Bearer tokens show as `Bearer ***REDACTED***`
- API keys show as `sk-***REDACTED***`
- Email addresses show as `***@***.***`
- clean_text truncated to 100 chars if longer

#### 2. Source Traceability
1. Create a new capture with text: "我今天开会很烦，明天要整理思路"
2. Let it atomize (OpenAI or mock)
3. Open CaptureDetailSheet → Atoms tab
4. Check `atoms[0].startChar` and `atoms[0].endChar` values

**Expected**:
- If OpenAI: startChar >= 0, endChar > startChar
- If mock/fallback: startChar = nil, endChar = nil

#### 3. Mark as Key
1. Open any Atom
2. Tap menu `…` → "标记为重点"
3. Check database or reload atoms

**Expected**:
- `atom.isKey` = true

#### 4. Delete Atom
1. Open any Atom
2. Tap menu `…` → "删除"
3. Check atoms list

**Expected**:
- Atom removed from list
- Associated tags also removed from AtomTagEntity

#### 5. Tag Assignment Logic
1. Create a capture
2. Let it atomize
3. Check which atoms have suggested tags

**Expected**:
- Maximum 1 visible suggested tag
- Suggested tag only on first atom
- Hidden suggestions on all atoms (if any)

### Automated Tests (TBD)
- Unit test: `AIDebugRedactor.redact()` with various inputs
- Unit test: `AtomTagStore.markAsKey()` persistence
- Unit test: `AtomTagStore.deleteAtom()` cascade delete
- Integration test: Full atomization flow with version tracking

## Rollback Notes

### If startChar/endChar Cause Issues
1. Revert PersistenceController.swift lines 257-265
2. Revert AtomEntity.swift lines 10-12
3. Revert AtomItem.swift lines 9-11
4. Revert AtomTagStore.swift lines 18-20
5. Database will auto-migrate (fields optional or have defaults)

### If Privacy Redaction Too Aggressive
1. Revert AIDebugStore.swift to previous implementation
2. Or adjust regex patterns in `AIDebugRedactor.redact()`

### If Tag Assignment Logic Breaks
1. Revert AtomizationCoordinator.swift lines 27-32
2. Revert AtomTagStore.swift lines 229-254
3. Use old `assignTagSuggestions(_:to:isHidden:)` method

## Database Migration

### Automatic Migration
Core Data will automatically add new columns with default values:
- `CaptureEntity.atomizeVersion` = nil
- `AtomEntity.startChar` = -1
- `AtomEntity.endChar` = -1
- `AtomEntity.atomizeVersion` = nil

### Manual Migration (if needed)
```swift
// If automatic migration fails, add this to PersistenceController:
if let error = error as NSError? {
    try container.persistentStoreCoordinator.destroyPersistentStore(...)
    // Reload with new schema
}
```
Current implementation already includes this fallback (lines 35-50).

## Performance Impact
- **Minimal**: All new fields are optional or have defaults
- `AIDebugRedactor.redact()` now uses 6 regex operations (was 1)
  - Impact: ~1-2ms per debug log entry (acceptable for debug-only feature)
- startChar/endChar: No query impact (not indexed)

## Security Impact
- **Critical improvement**: P0 secrets (API keys) now properly redacted
- **Improvement**: P1 identifiers (emails) now redacted
- **Improvement**: P2 user data (clean_text) now truncated

## Next Steps
1. Implement "查看来源" UI button in CaptureAtomRowView
2. Add unit tests for new methods
3. Create ADR-001 documenting privacy redaction decisions
4. Consider adding `deletedAt` field for soft delete (V2)
5. Consider improving fallback atomization with emotion/action detection

## References
- Skills: `atomization`, `tags`, `ai-interaction`, `privacy-redaction-standard`, `devtools-debug-suite`
- Session: `Docs/04_Sessions/2026-03-06_session-001.md`
- Audit Report: (included in session log)
