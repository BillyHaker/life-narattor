import CoreData
import SwiftUI

struct RecordFeedScreen: View {
    @State private var viewModel: CaptureFeedViewModel
    @State private var selectedCaptureID: UUID?
    @State private var showingAudioOverlay = false

    init(context: NSManagedObjectContext, aiService: AIService) {
        _viewModel = State(wrappedValue: CaptureFeedViewModel(context: context, aiService: aiService))
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                headerView

                if viewModel.captures.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            ForEach(DayPart.allCases) { part in
                                let items = viewModel.captures.filter { $0.dayPart == part }
                                if !items.isEmpty {
                                    Text(part.title)
                                        .font(.headline)
                                        .foregroundStyle(.secondary)

                                    ForEach(items) { item in
                                        CaptureCardView(item: item) {
                                            selectedCaptureID = item.id
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
            .padding(.top, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color(.systemGroupedBackground))
            .safeAreaInset(edge: .bottom) {
                CaptureInputBarView(
                    text: $viewModel.inputText,
                    mode: $viewModel.inputMode,
                    onSend: viewModel.addCaptureFromInput,
                    onRecord: { showingAudioOverlay = true }
                )
            }
            .onAppear {
                viewModel.loadCaptures()
            }
            .sheet(item: $selectedCaptureID) { captureID in
                if let item = viewModel.makeDetailItem(for: captureID) {
                    CaptureDetailSheet(item: item)
                }
            }
            .overlay {
                if showingAudioOverlay {
                    AudioRecorderOverlayView {
                        showingAudioOverlay = false
                    }
                }
            }
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("今天 · \(formattedDate(Date()))")
                .font(.title2.weight(.semibold))
            Text("随手记一句就好")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
    }

    private var emptyStateView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("还没有记录。随手记一句就好。")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
}

#Preview {
    let controller = PersistenceController(inMemory: true)
    let context = controller.container.viewContext
    SamplePreviewData.seedCaptures(in: context)
    return RecordFeedScreen(context: context, aiService: MockAIService())
}

private enum SamplePreviewData {
    static func seedCaptures(in context: NSManagedObjectContext) {
        let now = Date()
        let calendar = Calendar.current

        let samples: [(String, String, String, DayPart, Int, Int16, CaptureProcessingState)] = [
            ("早上开会做了进度对齐", "✅ 已记下", "确认：开会 + 进度", .morning, -2, 2, .atomsReady),
            ("午饭后散步十分钟", "✅ 已记下", "确认：散步 + 放松", .afternoon, -5, 0, .cleanReady)
        ]

        for sample in samples {
            let entity = CaptureEntity(context: context)
            entity.id = UUID()
            entity.createdAt = calendar.date(byAdding: .hour, value: sample.4, to: now) ?? now
            entity.rawText = sample.0
            entity.cleanText = sample.0
            entity.ackTitle = sample.1
            entity.ackDetail = sample.2
            entity.dayPart = sample.3.rawValue
            entity.mode = CaptureInputMode.log.rawValue
            entity.atomsCount = sample.5
            entity.processingState = sample.6.rawValue
        }

        let assistEntity = CaptureEntity(context: context)
        assistEntity.id = UUID()
        assistEntity.createdAt = calendar.date(byAdding: .hour, value: -9, to: now) ?? now
        assistEntity.rawText = "想把 fine / fan / find 的区别整理成练习点"
        assistEntity.cleanText = assistEntity.rawText
        assistEntity.dayPart = DayPart.evening.rawValue
        assistEntity.mode = CaptureInputMode.assist.rawValue
        assistEntity.atomsCount = 0
        assistEntity.processingState = CaptureProcessingState.cleanReady.rawValue

        let payload = AssistArchivePayload(
            reply: "我明白了，你想把发音区别整理成可练习的记录。",
            card: AssistArchiveCard(
                title: "fine / fan / find 发音区分",
                context: "容易混淆三个词的元音与结尾。",
                keyPoints: [
                    "fan 是 /æ/（像 cat 的元音）",
                    "fine 是 /aɪ/（有明显滑音）",
                    "find 是 /aɪ/ + 词尾 /d/"
                ],
                nextSteps: ["做 3 分钟最小对比练习：fan–fine–find"],
                tagSuggestions: [AssistTagSuggestion(tagType: "theme", name: "English pronunciation")],
                confidence: "medium"
            ),
            turnPolicy: AssistTurnPolicy(usedClarification: false, turnsRemaining: 1)
        )

        let artifact = ArtifactEntity(context: context)
        artifact.id = UUID()
        artifact.artifactType = "assist_archive_card"
        artifact.title = payload.card.title
        artifact.contentJSON = payload.encodedJSON() ?? "{}"
        artifact.sourceCaptureID = assistEntity.id
        artifact.createdAt = now
        artifact.updatedAt = now

        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }
}
