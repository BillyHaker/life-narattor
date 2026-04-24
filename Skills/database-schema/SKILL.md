---
name: database-schema
description: Provides the V1 local database schema (SQLite recommended) for Life Narrator: captures, transcripts, clean texts, atoms, tags, threads, narratives, comments, and job tracking. Use this skill when implementing persistence and queries.
metadata:
  product: life-narrator
  version: "0.1"
  storage: sqlite
---

# Database Schema (V1)

## Recommendation
Use SQLite with a migration system (e.g., GRDB). Keep derived artifacts versioned.

## Core tables (conceptual)
- captures
- transcripts (voice)
- clean_texts
- atoms
- tags
- atom_tags
- threads
- thread_items
- narratives
- narrative_sources
- ai_comments
- ai_jobs
- user_settings

## Key constraints
- Raw must be preserved and accessible.
- Clean/Atoms/Narratives are derived and re-computable → store `ruleset_version/style_version`.
- All narratives must have sources.

## Query examples (must support)
1) Load today’s feed: captures by created_at desc
2) Expand capture: fetch clean_text + atoms ordered by order_in_capture
3) Daily narrative: by scope_key YYYY-MM-DD
4) Project timeline: atoms joined by atom_tags where tag_type=project
5) Review: weekly/monthly narratives by scope_key
6) Search: keyword over captures.clean_text / atoms.content + tag filters

## Note
If your team chooses Core Data for V1, mirror these entities and relationships closely.

## Assist archive storage (recommended)

To support Assist mode’s **Archive Card** as a first-class asset, add an `artifacts` table (recommended).

### artifacts (recommended)
- id (UUID)
- artifact_type: "assist_archive_card" | "import_archive_card"
- title
- content_json (stores the structured card fields)
- source_capture_id (FK to captures)
- created_at
- updated_at

### artifact_sources (optional)
If you want fine-grained traceability:
- artifact_id
- source_type ("atom"|"capture")
- source_id
- quote_snippet (optional)

Mapping:
- Archive Card -> artifacts.content_json
- Key points / Next steps -> atoms (linked to the same capture_id), and tag them.
