import SwiftUI

struct RecordingChipView: View {
    let startedAt: Date
    let onStop: () -> Void
    let onCancel: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.red)
                .frame(width: 10, height: 10)
            Text("录音中 \(elapsedText)")
                .font(.footnote.weight(.semibold))
            Spacer()
            Button("停止", action: onStop)
                .buttonStyle(.borderedProminent)
            Button("取消", action: onCancel)
                .buttonStyle(.bordered)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color(.systemGray5)),
            alignment: .top
        )
    }

    private var elapsedText: String {
        let seconds = Int(Date().timeIntervalSince(startedAt))
        let minutes = seconds / 60
        let remaining = seconds % 60
        return String(format: "%02d:%02d", minutes, remaining)
    }
}
