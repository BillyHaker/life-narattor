import SwiftUI

struct CaptureCardView: View {
    let item: CaptureItem
    let onShowDetail: () -> Void
    let onAssistSave: () -> Void
    let onAssistEdit: (AssistArchivePayload) -> Void
    let onAssistEnd: () -> Void
    let onRetryTranscription: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(item.cleanText ?? item.rawText)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if item.inputType == .voice, let transcriptionStatus = item.transcriptionStatus {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(item.isTranscriptionActive ? "正在转写…" : transcriptionStatus.displayText)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        if !item.isTranscriptionActive && transcriptionStatus == .failed {
                            Button("重试", action: onRetryTranscription)
                                .font(.footnote.weight(.semibold))
                        }
                    }

                    if !item.isTranscriptionActive,
                       (transcriptionStatus == .failed || transcriptionStatus == .offline),
                       let reason = item.transcriptionErrorReason,
                       !reason.isEmpty {
                        Text(reason)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } else if item.mode == .log {
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
                if let record = item.assistRecord {
                    if record.status == .ended {
                        Text("已结束")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        AssistArchiveCardView(
                            payload: record.payload,
                            status: record.status,
                            onSave: onAssistSave,
                            onEdit: onAssistEdit,
                            onEnd: onAssistEnd
                        )
                    }
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
        return "已记录"
    }
}
