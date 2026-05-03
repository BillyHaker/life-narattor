import SwiftUI

struct OnboardingGuideScreen: View {
    let onFinish: () -> Void

    @State private var pageIndex = 0

    private let pages: [OnboardingGuidePage] = [
        OnboardingGuidePage(
            eyebrow: "第一步",
            title: "先随手记一句",
            detail: "普通记录可以很短，像给自己留一张便签。说不清的时候，切到助手，让它陪你问几句，再整理成一条记录。",
            systemImage: "square.and.pencil",
            accent: .blue,
            points: ["记录当下发生的事或想法", "助手对话后可整理成记录", "确认后再写入，不会强迫你保存"]
        ),
        OnboardingGuidePage(
            eyebrow: "第二步",
            title: "时间线会慢慢长出来",
            detail: "不用每天写完整日记。零散片段会按昨天、7 天、30 天被整理成故事线，帮你看见最近的节奏。",
            systemImage: "clock.arrow.circlepath",
            accent: .green,
            points: ["先看每天留下的节点", "AI 会整理已结束的时间段", "回看不是打分，只是多一个参照"]
        ),
        OnboardingGuidePage(
            eyebrow: "第三步",
            title: "直接问 AI 回顾",
            detail: "当你想知道重复出现的状态、某个变化从什么时候开始，或者哪条线索值得继续看，可以直接问。",
            systemImage: "sparkles",
            accent: .purple,
            points: ["从问题开始，也可以从线索开始", "结果会尽量带事实和依据", "适合寻找普通记录里不明显的联系"]
        )
    ]

    var body: some View {
        ZStack {
            background

            VStack(spacing: 22) {
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
            .padding(.top, 28)
            .padding(.bottom, 26)
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(.systemGroupedBackground),
                Color(.systemBackground),
                Color.blue.opacity(0.07)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("欢迎来到 Life Narrator")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
            Text("不用写得完整。先留下片段，回看的事交给之后的你和 AI。")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 34)
        }
    }

    private var footer: some View {
        VStack(spacing: 14) {
            HStack(spacing: 7) {
                ForEach(pages.indices, id: \.self) { index in
                    Capsule()
                        .fill(index == pageIndex ? Color.blue : Color(.systemGray4))
                        .frame(width: index == pageIndex ? 22 : 7, height: 7)
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
                    Text(pageIndex == pages.count - 1 ? "开始使用" : "继续")
                        .font(.system(size: 17, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .padding(.horizontal, 22)

            Button("跳过，直接进入") {
                onFinish()
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.secondary)
            .padding(.top, 2)
        }
    }
}

private struct OnboardingGuideCard: View {
    let page: OnboardingGuidePage

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
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

            VStack(spacing: 12) {
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
                    .padding(14)
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
}

private struct OnboardingGuidePage {
    let eyebrow: String
    let title: String
    let detail: String
    let systemImage: String
    let accent: Color
    let points: [String]
}

#Preview {
    OnboardingGuideScreen {}
}
