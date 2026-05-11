import SwiftUI

struct OnboardingGuideScreen: View {
    let onFinish: () -> Void

    @State private var pageIndex = 0

    private let pages: [OnboardingGuidePage] = [
        OnboardingGuidePage(
            eyebrow: "直接记录",
            title: "不用写完整日记",
            detail: "Life Narrator 不是来催你认真写作的。先把这一刻留下来：一句话、一段语音、一个模糊感受，都可以。",
            systemImage: "quote.bubble.fill",
            accent: .blue,
            guideTitle: "你只需要做一件事",
            guideText: "在记录页写下或说出刚发生的事。它可以很短，整理可以之后再说。",
            example: "例如：今天开会被打断后有点烦。"
        ),
        OnboardingGuidePage(
            eyebrow: "助手整理",
            title: "清楚就直接记，说不清就找助手",
            detail: "有些事一开始只是一团感觉。你可以先和助手聊几句，等它整理成草稿后，再决定是否写入记录。",
            systemImage: "bubble.left.and.bubble.right.fill",
            accent: .teal,
            guideTitle: "两种入口，目的相同",
            guideText: "直接记录适合已经想清楚的片段；助手适合还没组织好的念头。确认前都不会正式写入。",
            example: "例如：我今天为什么一直提不起劲？"
        ),
        OnboardingGuidePage(
            eyebrow: "回看线索",
            title: "回看时，再让 AI 帮你找联系",
            detail: "记录多起来后，时间线会把已经结束的时间段整理成故事线。AI 回顾则适合追问变化、重复模式和隐藏线索。",
            systemImage: "sparkles",
            accent: .purple,
            guideTitle: "AI 只在你需要回看时介入",
            guideText: "它会尽量基于事实回答：发生了什么、哪些事反复出现、哪条线索值得继续看。",
            example: "例如：最近反复卡住的地方是什么？"
        )
    ]

    var body: some View {
        ZStack {
            background

            VStack(spacing: 18) {
                header

                OnboardingGuideCard(page: pages[pageIndex])
                    .id(pageIndex)
                    .padding(.horizontal, 22)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .gesture(
                        DragGesture(minimumDistance: 24)
                            .onEnded { value in
                                handleDrag(value.translation.width)
                            }
                    )
                    .animation(.easeInOut(duration: 0.22), value: pageIndex)

                footer
            }
            .padding(.top, 26)
            .padding(.bottom, 24)
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(.systemGroupedBackground),
                Color(.systemBackground),
                Color.blue.opacity(0.06)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("先轻轻记下来")
                .font(.system(size: 29, weight: .bold))
                .multilineTextAlignment(.center)
            Text("可以直接记，也可以先和助手聊。没有固定顺序，先把片段接住就好。")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal, 34)
        }
    }

    private var footer: some View {
        VStack(spacing: 13) {
            HStack(spacing: 7) {
                ForEach(pages.indices, id: \.self) { index in
                    Capsule()
                        .fill(index == pageIndex ? pages[pageIndex].accent : Color(.systemGray4))
                        .frame(width: index == pageIndex ? 24 : 7, height: 7)
                        .animation(.spring(response: 0.25, dampingFraction: 0.85), value: pageIndex)
                }
            }

            HStack(spacing: 12) {
                if pageIndex > 0 {
                    Button {
                        goPrevious()
                    } label: {
                        Text("上一步")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.primary)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }

                Button {
                    if pageIndex == pages.count - 1 {
                        onFinish()
                    } else {
                        goNext()
                    }
                } label: {
                    Text(pageIndex == pages.count - 1 ? "开始记一句" : "继续")
                        .font(.system(size: 17, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(pages[pageIndex].accent)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .padding(.horizontal, 22)

            Button("先进入看看") {
                onFinish()
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.secondary)
            .padding(.top, 1)
        }
    }

    private func handleDrag(_ translationWidth: CGFloat) {
        if translationWidth < -42 {
            goNext()
        } else if translationWidth > 42 {
            goPrevious()
        }
    }

    private func goNext() {
        guard pageIndex < pages.count - 1 else { return }
        withAnimation(.easeInOut(duration: 0.22)) {
            pageIndex += 1
        }
    }

    private func goPrevious() {
        guard pageIndex > 0 else { return }
        withAnimation(.easeInOut(duration: 0.22)) {
            pageIndex -= 1
        }
    }
}

private struct OnboardingGuideCard: View {
    let page: OnboardingGuidePage

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            icon

            VStack(alignment: .leading, spacing: 11) {
                Text(page.eyebrow)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(page.accent)
                Text(page.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(page.detail)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            guideBlock
            exampleBlock

            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: 620, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.05), radius: 24, x: 0, y: 12)
    }

    private var icon: some View {
        ZStack {
            Circle()
                .fill(page.accent.opacity(0.12))
                .frame(width: 78, height: 78)
            Image(systemName: page.systemImage)
                .font(.system(size: 31, weight: .semibold))
                .foregroundStyle(page.accent)
        }
    }

    private var guideBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(page.guideTitle)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.primary)
            Text(page.guideText)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(page.accent.opacity(0.09))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var exampleBlock: some View {
        HStack(alignment: .top, spacing: 11) {
            Image(systemName: "arrow.turn.down.right")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(page.accent)
                .padding(.top, 2)
            Text(page.example)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 13)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct OnboardingGuidePage {
    let eyebrow: String
    let title: String
    let detail: String
    let systemImage: String
    let accent: Color
    let guideTitle: String
    let guideText: String
    let example: String
}

#Preview {
    OnboardingGuideScreen {}
}
