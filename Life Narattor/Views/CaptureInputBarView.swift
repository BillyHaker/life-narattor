import SwiftUI

struct CaptureInputBarView: View {
    @Binding var text: String
    @Binding var mode: CaptureInputMode
    let onSend: () -> Void
    let onRecord: () -> Void
    let showsModePicker: Bool
    let textPlaceholder: String
    private let isTextFieldFocused: FocusState<Bool>.Binding?
    @FocusState private var localTextFieldFocused: Bool

    init(
        text: Binding<String>,
        mode: Binding<CaptureInputMode>,
        onSend: @escaping () -> Void,
        onRecord: @escaping () -> Void,
        showsModePicker: Bool = true,
        textPlaceholder: String = "记录当下发生的事或想法…",
        isTextFieldFocused: FocusState<Bool>.Binding? = nil
    ) {
        _text = text
        _mode = mode
        self.onSend = onSend
        self.onRecord = onRecord
        self.showsModePicker = showsModePicker
        self.textPlaceholder = textPlaceholder
        self.isTextFieldFocused = isTextFieldFocused
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showsModePicker {
                Picker("模式", selection: $mode) {
                    ForEach(CaptureInputMode.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)
            }

            HStack(alignment: .center, spacing: 10) {
                Button(action: onRecord) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(.blue)
                        .frame(width: 44, height: 44)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }

                TextField(textPlaceholder, text: $text, axis: .vertical)
                    .font(.body)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .lineLimit(1...4)
                    .applyTextInputFocus(isTextFieldFocused, fallback: $localTextFieldFocused)

                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .primary)
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color(.systemGray5)),
            alignment: .top
        )
    }
}

private extension View {
    @ViewBuilder
    func applyTextInputFocus(
        _ externalFocus: FocusState<Bool>.Binding?,
        fallback localFocus: FocusState<Bool>.Binding
    ) -> some View {
        if let externalFocus {
            self.focused(externalFocus)
        } else {
            self.focused(localFocus)
        }
    }
}
