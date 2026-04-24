---
name: record-modeling
description: Defines the canonical record model for Life Narrator: source layer, structured record layer, rendered view layer, record kinds, facets, and migration guidance for assistant notes and external knowledge cards.
metadata:
  product: life-narrator
  version: "1.1"
  owner: product
  created: "2026-03-09"
  updated: "2026-03-09"
  changelog: "v1.1 明确正式 schema 方向：RecordEntity / RecordRevisionEntity / RecordTagLinkEntity；取消以 ArtifactEntity 作为长期主干的建议"
---

# Record Modeling

## When to use

Read this skill when work touches any of the following:
- assistant output persistence
- note / card schema design
- record rendering or record detail layouts
- importing cards from an external study or knowledge tool
- future schema migration away from ad-hoc JSON blobs

If the task is only about capture UI copy or prompt tuning, this skill is not required.

## Core decision

Life Narrator should use:

`source layer -> structured record layer -> rendered view layer`

Do not use free-form natural language as the source of truth.
Do not design the core schema around a single use case such as "problem analysis".
Do not keep `ArtifactEntity + contentJSON` as the long-term canonical storage path if there is no existing data to protect.

The structured record layer must stay topic-agnostic so it can hold:
- daily logs
- assistant-generated action notes
- study notes
- reading cards
- future self-model inputs

## Three-layer model

### 1) Source layer

Purpose:
- preserve what the user actually said or recorded
- preserve ingestion metadata

Recommended contents:
- `capture_id`
- `created_at`
- `raw_text`
- `input_type`
- `audio_path`
- `source_thread_id`
- minimal processing status fields

This layer is archival and traceable. It is not the main reading surface.

### 2) Structured record layer

Purpose:
- canonical storage for later retrieval, revision, rendering, review, and AI reuse

This layer is the source of truth for meaning.

If there is no production data yet, implement this layer as first-class Core Data entities now.

### Formal entity recommendation

#### `RecordEntity`

Represents one user-visible record.

Recommended fields:
- `id: UUID`
- `kind: String` (`log | action | insight | decision`)
- `title: String`
- `summary: String`
- `sourceCaptureID: UUID?`
- `sourceThreadID: UUID?`
- `currentRevisionID: UUID`
- `status: String` (`active | archived | deleted`)
- `createdAt: Date`
- `updatedAt: Date`

Rules:
- this table should stay small and query-friendly
- put stable list metadata here
- do not store the full semantic payload here

#### `RecordRevisionEntity`

Represents one version of a record's structured meaning.

Recommended fields:
- `id: UUID`
- `recordID: UUID`
- `revisionNumber: Int`
- `schemaVersion: String`
- `renderVersion: String`
- `payloadJSON: String`
- `renderedNoteText: String?`
- `createdBy: String` (`ai | user | import`)
- `createdAt: Date`

Rules:
- payloadJSON is the authoritative content version
- renderedNoteText is optional cached output
- changing note style should not require payload rewrite

#### `RecordTagLinkEntity`

Represents record-level tags independent of atomization.

Recommended fields:
- `id: UUID`
- `recordID: UUID`
- `tagID: UUID`
- `createdAt: Date`
- `isPrimary: Bool`
- `isSuggested: Bool`

Rules:
- do not rely only on `AtomTagEntity` for record retrieval
- imported knowledge cards and decision notes may not have atom-level tags

#### `CaptureEntity`

Keep as the source layer container.

Recommended scope:
- origin input
- ingestion status
- transcription state
- provenance

Do not make `CaptureEntity` the long-term container for final record semantics.

Canonical object shape:

```json
{
  "schemaVersion": "record_payload_v1",
  "kind": "log",
  "title": "fan / fine / fun 发音区分",
  "summary": "这组三词容易混，主要差别在元音轨迹和口型切换。",
  "facets": {
    "observation": "英文里 fan、fine、fun 分不太清。",
    "insight": "快读时口型切换不稳会把三个词压扁。",
    "action": "做 60 秒 fan-fun-fine 最小对比。",
    "success_criterion": "能稳定区分并读出三者差异。",
    "follow_up": "下次确认最容易塌的是哪个音。"
  },
  "tags": ["english-pronunciation", "speaking"],
  "sourceCaptureID": "cap_123",
  "sourceThreadID": "thread_456",
  "revision": {
    "revisionCount": 0,
    "supersedesRecordID": null
  }
}
```

### 3) Rendered view layer

Purpose:
- convert structured records into readable note surfaces

This layer is derived, not authoritative.

Rendered text may be cached for performance, but must be reproducible from the structured record layer.

Recommended render versions:
- `note_v1`
- `feed_v1`
- `structured_v1`

## Record kinds

Start with four kinds only:

### `log`
- general life note
- event / thought / feeling / observation
- reading style should feel natural and light

### `action`
- assistant-processed note with a clear next step
- suitable for skill-building, problem solving, execution tracking

### `insight`
- learning, reading, method, principle, takeaway
- optimized for reuse and linking

### `decision`
- tradeoff, option comparison, pending choice, risk framing

Do not add more kinds unless a new kind clearly needs a distinct reading or editing pattern.

## Facets

Facets are optional semantic slots.
No facet should be globally mandatory except what is explicitly listed below.

Required top-level fields:
- `schemaVersion`
- `kind`
- `title`
- `summary`

Optional facet slots:
- `observation`
- `insight`
- `action`
- `success_criterion`
- `follow_up`
- `question`
- `claim`
- `evidence`
- `example`
- `decision`
- `risk`
- `quote`
- `source`

Rules:
- only fill facets that are actually present
- do not backfill empty facets with generic filler
- do not force all record kinds into `problem/core_reason/action`

## Reading styles

The same structured record should support multiple render styles.

### Feed view
- one-line or two-line summary
- optimized for scanning
- uses: `title`, `summary`, tags, time

### Note view
- natural-language note
- optimized for direct reading
- generated from `summary + relevant facets`

### Structured view
- block-based detail layout
- optimized for editing, review, and AI reuse
- shows facets explicitly

Prefer `Note view` for default human reading and `Structured view` for edit / inspect surfaces.

## Rendering guidance

### `log`
- feed: title + short natural summary
- detail note: reads like a compact note, not a formal card
- structured blocks: observation / context / optional follow-up

### `action`
- feed: outcome-first summary
- detail note: current bottleneck -> action -> success criterion
- structured blocks: observation / insight / action / success_criterion / follow_up

### `insight`
- feed: stronger title, tighter summary, visible source badge if imported
- detail note: should feel like a knowledge card, not a diary entry
- structured blocks: claim / example / evidence / quote / source

### `decision`
- feed: decision target + current leaning
- detail note: what is being decided, why it is hard, what to compare next
- structured blocks: decision / risk / evidence / next comparison focus

## Current codebase impact

If implementing this schema in the current codebase:
- `CaptureEntity` remains
- `ArtifactEntity` should shrink back to truly auxiliary artifacts:
  - assist thread meta
  - assist thread message
  - debug or import metadata
  - legacy transition data only if needed

Do not use `ArtifactEntity` as the permanent main store for records if a dedicated record schema can still be introduced cheaply.

## Revision model

Do not mutate the historical meaning of a record in place without trace.

Rules:
- keep original `created_at`
- store revision count and revision lineage
- user edits should remain distinguishable from AI-generated structure
- rendered note text can change, but source and revision chain must remain traceable
- `RecordEntity.currentRevisionID` should always point to the latest accepted revision

## Upgrade strategy

Design for forward compatibility now:
- version the payload with `schemaVersion`
- version the renderer with `renderVersion`
- allow `facets` to grow without changing top-level meaning
- prefer additive schema changes over field renames

Recommended principle:
- top-level keys should stay stable
- new semantics should go into `facets` or optional metadata blocks first
- only promote a field to entity-level column if list queries or sorting truly depend on it

## Knowledge tool integration

When importing notes from an external study or reading tool:
- map them into the same structured record layer
- prefer `kind = insight`
- keep external source metadata and original card ID
- do not special-case "knowledge cards" as a totally separate database product

Read:
- [knowledge-card-integration.md](references/knowledge-card-integration.md)

## Implementation priority

If starting from zero data, implement in this order:
1. `RecordEntity`
2. `RecordRevisionEntity`
3. `RecordTagLinkEntity`
4. `writer_payload_v1`
5. renderers for `feed_v1 / note_v1 / structured_v1`

Do not postpone the dedicated record schema if there is no migration burden yet.

## Anti-patterns

Avoid these designs:
- storing only a chat-style paragraph as the final record
- forcing every record into a problem/solution template
- making rendered note text the source of truth
- mixing transient UI state into canonical record content
- adding many specialized record kinds too early
- treating `ArtifactEntity` as a permanent catch-all content store once a dedicated record schema is affordable

## Acceptance criteria

- Any assistant note can be stored without assuming it is a "problem analysis".
- Any external knowledge card can be mapped into the same canonical structure.
- The default reader surface can look natural without sacrificing structured storage.
- Schema evolution can happen by versioning revision payloads rather than rewriting raw captures.
- Record semantics, record revisions, and record tags are queryable without decoding unrelated artifact blobs first.
