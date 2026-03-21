import SwiftUI

struct AssistArchiveEditSheet: View {
    let payload: AssistArchivePayload
    let onSave: (AssistArchivePayload) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var context: String
    @State private var keyPointsText: String
    @State private var nextStepsText: String

    init(payload: AssistArchivePayload, onSave: @escaping (AssistArchivePayload) -> Void) {
        self.payload = payload
        self.onSave = onSave
        _title = State(initialValue: payload.card.title)
        _context = State(initialValue: payload.card.context)
        _keyPointsText = State(initialValue: payload.card.keyPoints.joined(separator: "\n"))
        _nextStepsText = State(initialValue: payload.card.nextSteps.joined(separator: "\n"))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("标题") {
                    TextField("标题", text: $title)
                }

                Section("背景") {
                    TextEditor(text: $context)
                        .frame(minHeight: 80)
                }

                Section("要点（最多 3 行）") {
                    TextEditor(text: $keyPointsText)
                        .frame(minHeight: 100)
                }

                Section("下一步（最多 3 行）") {
                    TextEditor(text: $nextStepsText)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("编辑卡片")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        let updated = buildPayload()
                        onSave(updated)
                        dismiss()
                    }
                }
            }
        }
    }

    private func buildPayload() -> AssistArchivePayload {
        let cleanedTitle = limitWords(title, maxWords: 12)
        let keyPoints = lines(from: keyPointsText, limit: 3)
        let nextSteps = lines(from: nextStepsText, limit: 3)

        let updatedCard = AssistArchiveCard(
            title: cleanedTitle,
            context: context.trimmingCharacters(in: .whitespacesAndNewlines),
            keyPoints: keyPoints,
            nextSteps: nextSteps,
            recordUnits: payload.card.recordUnits,
            tagSuggestions: payload.card.tagSuggestions,
            confidence: payload.card.confidence
        )

        return AssistArchivePayload(
            reply: payload.reply,
            card: updatedCard,
            turnPolicy: payload.turnPolicy
        )
    }

    private func lines(from text: String, limit: Int) -> [String] {
        let parts: [String] = text
            .split(whereSeparator: { $0 == "\n" || $0 == "\r" })
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if parts.count <= limit {
            return parts
        }
        return Array(parts[0..<limit])
    }

    private func limitWords(_ text: String, maxWords: Int) -> String {
        let words = text.split(whereSeparator: { $0 == " " || $0 == "\n" || $0 == "\r" })
        if words.count <= maxWords {
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return words.prefix(maxWords).joined(separator: " ")
    }
}
