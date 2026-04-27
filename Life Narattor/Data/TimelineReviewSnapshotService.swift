import CoreData
import Foundation

@MainActor
struct TimelineReviewSnapshotService {
    private let context: NSManagedObjectContext
    private let artifactType = "timeline_review_snapshot_v1"

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func loadSnapshot(kind: TimelineReviewSnapshotKind) -> TimelineReviewSnapshotPayload? {
        guard let artifact = fetchArtifact(kind: kind) else { return nil }
        return decodeSnapshot(from: artifact)
    }

    func refreshIfNeeded(kind: TimelineReviewSnapshotKind, aiService: AIService, now: Date = Date()) async -> TimelineReviewSnapshotPayload? {
        let desiredRange = snapshotRange(for: kind, now: now)
        let freshness = currentFreshness(in: desiredRange)
        if let existing = loadSnapshot(kind: kind), isCurrent(existing, desiredRange: desiredRange, freshness: freshness) {
            return existing
        }
        return await refresh(kind: kind, aiService: aiService, now: now)
    }

    func isSnapshotCurrent(_ snapshot: TimelineReviewSnapshotPayload, now: Date = Date()) -> Bool {
        let desiredRange = snapshotRange(for: snapshot.kind, now: now)
        let freshness = currentFreshness(in: desiredRange)
        return isCurrent(snapshot, desiredRange: desiredRange, freshness: freshness)
    }

    func refresh(kind: TimelineReviewSnapshotKind, aiService: AIService, now: Date = Date()) async -> TimelineReviewSnapshotPayload? {
        let range = snapshotRange(for: kind, now: now)
        let descriptor = snapshotDescriptor(for: kind, range: range)
        let freshness = currentFreshness(in: range)
        let retrieval = ReviewRetrievalService(context: context)

        let payload: TimelineReviewSnapshotPayload
        if let reviewData = retrieval.makeRangeReviewData(periodName: descriptor.periodName, periodLabel: descriptor.periodLabel, range: range) {
            let aiSummary: String
            do {
                aiSummary = try await aiService.analyzeNarrativeMaterial(reviewData.material, periodName: descriptor.periodName, followupQuestion: nil)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            } catch {
                aiSummary = ""
            }

            payload = TimelineReviewSnapshotPayload(
                kind: kind,
                generatedAt: now,
                rangeStart: range.start,
                rangeEnd: range.end,
                summaryText: aiSummary.isEmpty ? reviewData.summaryText : aiSummary,
                activeDayCount: reviewData.activeDayCount,
                totalRecordCount: reviewData.totalRecordCount,
                overviewSignals: reviewData.overviewSignals,
                latestRecordAt: freshness.latestRecordAt,
                isEmpty: false
            )
        } else {
            payload = TimelineReviewSnapshotPayload(
                kind: kind,
                generatedAt: now,
                rangeStart: range.start,
                rangeEnd: range.end,
                summaryText: freshness.totalRecordCount > 0 ? descriptor.unresolvedText : descriptor.emptyText,
                activeDayCount: freshness.activeDayCount,
                totalRecordCount: freshness.totalRecordCount,
                overviewSignals: [],
                latestRecordAt: freshness.latestRecordAt,
                isEmpty: true
            )
        }

        persist(payload)
        return payload
    }

    private func isCurrent(
        _ snapshot: TimelineReviewSnapshotPayload,
        desiredRange: RetrievalTimeRange,
        freshness: TimelineSnapshotFreshness
    ) -> Bool {
        guard Calendar.current.isDate(snapshot.rangeStart, equalTo: desiredRange.start, toGranularity: .minute),
              Calendar.current.isDate(snapshot.rangeEnd, equalTo: desiredRange.end, toGranularity: .minute) else {
            return false
        }

        if snapshot.activeDayCount != freshness.activeDayCount || snapshot.totalRecordCount != freshness.totalRecordCount {
            return false
        }

        if snapshot.latestRecordAt != freshness.latestRecordAt {
            return false
        }

        if snapshot.isEmpty && freshness.totalRecordCount > 0 {
            return false
        }

        return true
    }

    private func persist(_ payload: TimelineReviewSnapshotPayload) {
        let existing = fetchArtifact(kind: payload.kind)
        let artifact = existing ?? ArtifactEntity(context: context)
        if existing == nil {
            artifact.id = UUID()
            artifact.createdAt = payload.generatedAt
            artifact.sourceCaptureID = payload.kind.artifactSourceID
            artifact.artifactType = artifactType
        }
        artifact.title = payload.kind.artifactKey
        artifact.contentJSON = encode(payload)
        artifact.status = payload.isEmpty ? "empty" : "done"
        artifact.updatedAt = payload.generatedAt
        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }

    private func fetchArtifact(kind: TimelineReviewSnapshotKind) -> ArtifactEntity? {
        let request = NSFetchRequest<ArtifactEntity>(entityName: "ArtifactEntity")
        request.fetchLimit = 1
        request.predicate = NSPredicate(
            format: "artifactType == %@ AND sourceCaptureID == %@",
            artifactType,
            kind.artifactSourceID as CVarArg
        )
        return (try? context.fetch(request))?.first
    }

    private func decodeSnapshot(from artifact: ArtifactEntity) -> TimelineReviewSnapshotPayload? {
        guard let data = artifact.contentJSON.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(TimelineReviewSnapshotPayload.self, from: data)
    }

    private func encode(_ payload: TimelineReviewSnapshotPayload) -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = (try? encoder.encode(payload)) ?? Data("{}".utf8)
        return String(data: data, encoding: .utf8) ?? "{}"
    }

    private func snapshotRange(for kind: TimelineReviewSnapshotKind, now: Date) -> RetrievalTimeRange {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: now)
        let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: todayStart) ?? todayStart
        let yesterdayEnd = todayStart.addingTimeInterval(-1)

        switch kind {
        case .yesterday:
            return RetrievalTimeRange(start: yesterdayStart, end: yesterdayEnd, label: kind.title)
        case .last7Days:
            let start = calendar.date(byAdding: .day, value: -7, to: todayStart) ?? yesterdayStart
            return RetrievalTimeRange(start: start, end: yesterdayEnd, label: kind.title)
        case .last30Days:
            let start = calendar.date(byAdding: .day, value: -30, to: todayStart) ?? yesterdayStart
            return RetrievalTimeRange(start: start, end: yesterdayEnd, label: kind.title)
        }
    }

    private func snapshotDescriptor(
        for kind: TimelineReviewSnapshotKind,
        range: RetrievalTimeRange
    ) -> (periodName: String, periodLabel: String, emptyText: String, unresolvedText: String) {
        switch kind {
        case .yesterday:
            return (
                "昨天",
                formattedYesterdayLabel(range.start),
                "昨天还没有足够的记录可以整理成一条故事线。",
                "昨天有记录，但还没整理出稳定故事线。"
            )
        case .last7Days:
            return (
                "过去7天",
                "过去 7 天",
                "过去 7 天还没有积累出足够清晰的脉络。",
                "过去 7 天有记录，但还没整理出稳定故事线。"
            )
        case .last30Days:
            return (
                "过去30天",
                "过去 30 天",
                "过去 30 天还没有积累出足够清晰的脉络。",
                "过去 30 天有记录，但还没整理出稳定故事线。"
            )
        }
    }

    private func formattedYesterdayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 · E"
        return formatter.string(from: date)
    }

    private func currentFreshness(in range: RetrievalTimeRange) -> TimelineSnapshotFreshness {
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(
            format: "createdAt >= %@ AND createdAt <= %@",
            range.start as CVarArg,
            range.end as CVarArg
        )
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let captures = ((try? context.fetch(request)) ?? [])
            .filter(\.isEligibleForReviewTimeline)

        let activeDayCount = Set(captures.map { Calendar.current.startOfDay(for: $0.createdAt) }).count
        let latestRecordAt = captures.first?.createdAt
        return TimelineSnapshotFreshness(
            activeDayCount: activeDayCount,
            totalRecordCount: captures.count,
            latestRecordAt: latestRecordAt
        )
    }
}

private struct TimelineSnapshotFreshness {
    let activeDayCount: Int
    let totalRecordCount: Int
    let latestRecordAt: Date?
}
