import SwiftUI

struct AssistArchiveCardView: View {
    let payload: AssistArchivePayload
    let status: AssistArchiveStatus
    let onSave: () -> Void
    let onEdit: (AssistArchivePayload) -> Void
    let onEnd: () -> Void

    @State private var showingEdit = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("回复")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(payload.reply)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text(payload.card.title)
                    .font(.headline)

                Text(payload.card.context)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if !payload.card.keyPoints.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("要点")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                        ForEach(payload.card.keyPoints, id: \.self) { point in
                            Text("• \(point)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if !payload.card.nextSteps.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("下一步")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                        ForEach(payload.card.nextSteps, id: \.self) { step in
                            Text("• \(step)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            actionRow
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .sheet(isPresented: $showingEdit) {
            AssistArchiveEditSheet(payload: payload) { updated in
                onEdit(updated)
            }
        }
    }

    private var actionRow: some View {
        HStack(spacing: 12) {
            switch status {
            case .draft:
                Button("保存为记录", action: onSave)
                    .buttonStyle(.borderedProminent)
                Button("编辑") { showingEdit = true }
                    .buttonStyle(.bordered)
                Button("结束", action: onEnd)
                    .buttonStyle(.bordered)
            case .saved:
                Text("已保存为记录")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("结束", action: onEnd)
                    .buttonStyle(.bordered)
            case .ended:
                EmptyView()
            }
        }
        .font(.footnote)
    }
}
