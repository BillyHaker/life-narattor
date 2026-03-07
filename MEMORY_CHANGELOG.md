# MEMORY_CHANGELOG
Current MEMORY_VERSION: 2026-03-07.1

## What changed in this version
- Introduced MEMORY_MANIFEST-based re-reading policy to minimize redundant reads.
- Added a standard handoff doc: Docs/00_Index/EXECUTION_BRIEF.md template.
- Added strict language/scope policy for Claude (no Japanese; docs-only by default).

## Files changed
- AGENTS.md
- CLAUDE.md
- MEMORY_MANIFEST.md
- MEMORY_CHANGELOG.md
- Docs/00_Index/EXECUTION_BRIEF.md

## Action required for agents
- Always read MEMORY_MANIFEST.md first.
- Re-read Must-read files only when MEMORY_VERSION changes.
