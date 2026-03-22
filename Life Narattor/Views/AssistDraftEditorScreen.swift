import SwiftUI

struct AssistDraftEditorScreen: View {
    let payload: AssistArchivePayload
    let initialBody: String
    let onContinueDialogue: (String, String) -> Void
    let onRegenerate: () -> Void
    let onConfirmRecord: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var bodyText: String

    init(
        payload: AssistArchivePayload,
        initialBody: String,
        onContinueDialogue: @escaping (String, String) -> Void,
        onRegenerate: @escaping () -> Void,
        onConfirmRecord: @escaping (String, String) -> Void
    ) {
        self.payload = payload
        self.initialBody = initialBody
        self.onContinueDialogue = onContinueDialogue
        self.onRegenerate = onRegenerate
        self.onConfirmRecord = onConfirmRecord
        _title = State(initialValue: payload.card.title)
        _bodyText = State(initialValue: initialBody)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    draftMetaCard

                    VStack(alignment: .leading, spacing: 8) {
                        Text("标题")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                        TextField("记录标题", text: $title)
                            .font(.title2.weight(.bold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("正文")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                        TextEditor(text: $bodyText)
                            .font(.body)
                            .scrollContentBackground(.hidden)
                            .lineSpacing(4)
                            .padding(14)
                            .frame(maxWidth: .infinity, minHeight: 360, alignment: .topLeading)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                }
                .padding(16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("记录草稿")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                actionBar
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                            .frame(width: 30, height: 30)
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var actionBar: some View {
        VStack(spacing: 12) {
            Button {
                onConfirmRecord(cleanedTitle, cleanedBody)
                dismiss()
            } label: {
                Text("确认记录并写入")
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.white)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.accentColor)
            )
            .opacity(cleanedTitle.isEmpty && cleanedBody.isEmpty ? 0.5 : 1)
            .disabled(cleanedTitle.isEmpty && cleanedBody.isEmpty)

            Text("确认后会正式写入记录，并继续进入拆分和标签流程。")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                secondaryActionButton(
                    title: "重新整理",
                    systemImage: "arrow.clockwise"
                ) {
                    dismiss()
                    onRegenerate()
                }

                secondaryActionButton(
                    title: "继续对话",
                    systemImage: "bubble.left.and.bubble.right"
                ) {
                    onContinueDialogue(cleanedTitle, cleanedBody)
                    dismiss()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
    }

    private var draftMetaCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("来自助手对话")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text("先看一眼草稿，再决定是否写入记录。确认后才会进入拆分和标签。")
                .font(.footnote)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                draftMetaPill("整理段落 \(payload.card.effectiveRecordUnits.count)")
                if !payload.card.tagSuggestions.isEmpty {
                    draftMetaPill("标签建议 \(payload.card.tagSuggestions.count)")
                }
                draftMetaPill("置信度 \(payload.card.confidence)")
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var cleanedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cleanedBody: String {
        bodyText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func draftMetaPill(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(Capsule())
    }

    private func secondaryActionButton(
        title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.accentColor)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}
