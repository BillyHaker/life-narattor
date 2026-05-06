import SwiftUI

struct OnboardingGuideScreen: View {
    let onFinish: () -> Void

    @State private var pageIndex = 0

    private let pages: [OnboardingGuidePage] = [
        OnboardingGuidePage(
            eyebrow: "第一步",
            title: "先记一句就好",
            detail: "不用写完整日记。把刚发生的事、一个想法、一个情绪留住，短一点也很好。",
            systemImage: "text.bubble",
            accent: .blue,
            actionTitle: "试着记下当下",
            points: ["可以很短，也可以很碎", "文字和语音都可以", "先留下，之后再整理"]
        ),
        OnboardingGuidePage(
            eyebrow: "第二步",
            title: "说不清，就找助手",
            detail: "当你只有一个模糊念头，助手可以陪你问几句，再整理成一条记录草稿。确认后才会保存。",
            systemImage: "bubble.left.and.bubble.right",
            accent: .teal,
            actionTitle: "从对话变成记录",
            points: ["适合没想清楚的时候", "整理前可以继续追问", "草稿可编辑，确认后写入"]
        ),
        OnboardingGuidePage(
            eyebrow: "第三步",
            title: "时间线会慢慢长出来",
            detail: "你不需要每天总结。昨天、7 天、30 天的故事线，会从已经留下的片段里沉淀出来。",
            systemImage: "clock.arrow.circlepath",
            accent: .green,
            actionTitle: "回看最近的节奏",
            points: ["今天先看节点", "结束后的时间段再总结", "回看不是打分，只是参考"]
        ),
        OnboardingGuidePage(
            eyebrow: "第四步",
            title: "想不明白，就直接问",
            detail: "AI 回顾适合问：最近反复卡住的是什么？某个变化从什么时候开始？哪条线索值得继续看？",
            systemImage: "sparkles",
            accent: .purple,
            actionTitle: "问出隐藏的联系",
            points: ["可以从问题开始", "也可以从线索开始", "结果会尽量带事实依据"]
        )
    ]

    var body: some View {
        ZStack {
            background

            VStack(spacing: 18) {
                header

                TabView(selection: $pageIndex) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingGuideCard(page: page)
                            .padding(.horizontal, 22)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

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
            Text("开始使用 Life Narrator")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
            Text("先留下片段。整理、回看和发现线索，可以交给之后的你和 AI。")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
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
                        withAnimation(.easeInOut(duration: 0.22)) {
                            pageIndex -= 1
                        }
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
                        withAnimation(.easeInOut(duration: 0.22)) {
                            pageIndex += 1
                        }
                    }
                } label: {
                    Text(pageIndex == pages.count - 1 ? "开始记录" : "继续")
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

            Button("跳过，直接进入") {
                onFinish()
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.secondary)
            .padding(.top, 1)
        }
    }
}

private struct OnboardingGuideCard: View {
    let page: OnboardingGuidePage

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            icon

            VStack(alignment: .leading, spacing: 10) {
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

            actionPill

            VStack(spacing: 10) {
                ForEach(page.points, id: \.self) { point in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(page.accent)
                        Text(point)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                    .padding(13)
                    .background(page.accent.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }

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

    private var actionPill: some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.right.circle.fill")
                .font(.system(size: 18, weight: .semibold))
            Text(page.actionTitle)
                .font(.system(size: 16, weight: .bold))
            Spacer(minLength: 0)
        }
        .foregroundStyle(page.accent)
        .padding(.horizontal, 15)
        .padding(.vertical, 13)
        .background(page.accent.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct OnboardingGuidePage {
    let eyebrow: String
    let title: String
    let detail: String
    let systemImage: String
    let accent: Color
    let actionTitle: String
    let points: [String]
}

#Preview {
    OnboardingGuideScreen {}
}
