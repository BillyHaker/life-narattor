# Knowledge Card Integration

This reference defines how an external study / reading / knowledge tool should feed cards into Life Narrator without creating a separate persistence model.

## Goal

External knowledge cards should:
- fit the same canonical record layer
- preserve their study-specific value
- remain renderable in a more "knowledge-like" visual style

They should not require a separate product architecture.

## Persistence target

Imported knowledge cards should be stored through the same first-class record path:
- `RecordEntity.kind = insight`
- `RecordRevisionEntity.payloadJSON = record_payload_v1`
- optional `RecordTagLinkEntity` rows for normalized retrieval

Do not store imported cards as standalone artifact blobs if the app has no legacy data constraint.

## Recommended imported kind

Use:

`kind = insight`

Only introduce a more specific subtype if there is a hard product need later.

## Canonical imported shape

```json
{
  "schemaVersion": "record_payload_v1",
  "kind": "insight",
  "title": "边际收益递减",
  "summary": "投入增加后，新增收益会逐渐下降。",
  "facets": {
    "claim": "收益不会无限线性增长。",
    "example": "学习 1 小时到 3 小时时提升明显，8 小时以后变缓。",
    "evidence": [
      "《书名》第 3 章",
      "作者案例 A"
    ],
    "source": "reading-tool://card/abc123"
  },
  "tags": ["economics", "learning", "mental-model"],
  "sourceCaptureID": null,
  "sourceThreadID": null,
  "externalSource": {
    "provider": "study-tool",
    "externalCardID": "abc123",
    "externalNotebookID": "nb-42"
  },
  "revision": {
    "revisionCount": 0,
    "supersedesRecordID": null
  }
}
```

## Imported style recommendation

Knowledge cards should render differently from daily logs.

Recommended visual order in detail view:
1. `title`
2. `summary`
3. `claim`
4. `example`
5. `evidence`
6. source metadata
7. tags / links

This reading style should feel like:
- compact
- reference-friendly
- linkable
- not diary-like

## Feed appearance

In list / feed view, imported knowledge cards should appear as:
- stronger title
- tighter summary
- visible source badge such as `读书卡` / `知识卡`

Avoid rendering them as chat-like or reflective prose by default.

## Import mapping rules

### From reading / study tool fields

Suggested mapping:
- external `topic` -> `title`
- external `takeaway` -> `summary`
- external `core idea` -> `facets.claim`
- external `example` -> `facets.example`
- external `quote` -> `facets.quote`
- external `reference/source` -> `facets.source`

### If source tool has richer structure

Keep it under:

`externalSource.rawFields`

Do not flatten every external field into the core schema unless the app will actually use it.

## Compatibility rules

To stay interoperable with assistant-generated records:
- keep the same top-level keys
- let `kind` and `facets` carry the specialization
- render different looks from the same canonical object

This allows:
- unified search
- unified review
- unified future self-model ingestion
- multiple UI styles without database fragmentation

## Future upgrade path

If the knowledge tool later requires:
- spaced repetition metadata
- mastery status
- deck/notebook structure

add them under:

`externalSource.studyMeta`

Do not pollute the core record schema with study-only workflow fields unless they become first-class app features.
