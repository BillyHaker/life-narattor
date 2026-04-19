import SwiftUI

struct RecordingChipView: View {
    let startedAt: Date
    let level: Double
    let onStop: () -> Void
    let onCancel: () -> Void

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.14))
                            .frame(width: 34, height: 34)
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("正在录音")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                    }

                    Spacer()

                    Text(elapsedText(now: context.date))
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                }

                HStack(alignment: .center, spacing: 12) {
                    HStack(spacing: 5) {
                        ForEach(0..<16, id: \.self) { index in
                            Capsule()
                                .fill(index < activeMeterBars ? Color.red : Color(.systemGray4).opacity(0.75))
                                .frame(width: 4, height: CGFloat(10 + (index % 5) * 4))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Button("取消", action: onCancel)
                        .buttonStyle(.bordered)
                        .tint(.secondary)

                    Button("停止", action: onStop)
                        .buttonStyle(.borderedProminent)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 12, y: 4)
        }
    }

    private var activeMeterBars: Int {
        let clamped = min(max(level, 0), 1)
        if clamped == 0 { return 0 }
        return max(1, Int(ceil(clamped * 16)))
    }

    private func elapsedText(now: Date) -> String {
        let seconds = Int(now.timeIntervalSince(startedAt))
        let minutes = seconds / 60
        let remaining = seconds % 60
        return String(format: "%02d:%02d", minutes, remaining)
    }
}
