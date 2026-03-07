import SwiftUI

struct AudioRecorderOverlayView: View {
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            VStack(spacing: 12) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(.white)
                Text("按住录音（占位）")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text("松手发送")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(24)
            .background(Color.black.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}
