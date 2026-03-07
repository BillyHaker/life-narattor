import SwiftUI

struct CaptureCardView: View {
    let item: CaptureItem
    let onShowDetail: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(item.cleanText ?? item.rawText)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if item.mode == .log {
                if item.processingState != .cleanReady {
                    Text(statusText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            switch item.mode {
            case .log:
                QuickAckBarView(
                    title: item.ackTitle ?? "✅ 已记下",
                    detail: item.ackDetail ?? "正在整理片段"
                )

                if item.atomsCount > 0 {
                    Button(action: onShowDetail) {
                        Text("已拆成 \(item.atomsCount) 条 ▾")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            case .assist:
                if let payload = item.assistPayload {
                    AssistArchiveCardView(payload: payload)
                } else {
                    QuickAckBarView(
                        title: "正在整理…",
                        detail: "请稍等"
                    )
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .contentShape(Rectangle())
        .onTapGesture(perform: onShowDetail)
    }

    private var statusText: String {
        if item.processingState == .atomsReady || item.processingState == .tagsSuggested {
            return "已拆分为 \(item.atomsCount) 条"
        }
        return item.processingState.displayText
    }
}
