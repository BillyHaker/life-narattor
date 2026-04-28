import CoreData
import SwiftUI

enum RootTab: Hashable {
    case record
    case timeline
    case review
#if DEBUG
    case dev
#endif
}

struct ContentView: View {

    @Environment(\.managedObjectContext) private var context
    @AppStorage("app.hasSeenPrivacyIntro") private var hasSeenPrivacyIntro = false
    @StateObject private var featureFlags = FeatureFlags.shared
    @State private var selectedTab: RootTab = .record

    private let aiService: AIService

    init(aiService: AIService = AIServiceFactory.make()) {
        self.aiService = aiService
    }

    var body: some View {
        Group {
            if hasSeenPrivacyIntro {
                TabView(selection: $selectedTab) {
                    RecordFeedScreen(context: context, aiService: aiService)
                        .tabItem {
                            Label("记录", systemImage: "square.and.pencil")
                        }
                        .tag(RootTab.record)

                    TimelineScreen(aiService: aiService, selectedTab: $selectedTab)
                        .tabItem {
                            Label("时间线", systemImage: "clock")
                        }
                        .tag(RootTab.timeline)

                    NavigationStack {
                        SearchScreen()
                    }
                        .tabItem {
                            Label("AI回顾", systemImage: "sparkles")
                        }
                        .tag(RootTab.review)

#if DEBUG
                    if featureFlags.isDeveloperMenuVisible {
                        DevToolsRootView(storage: CoreDataDebugStorageProvider(context: context), context: context, aiService: aiService)
                            .tabItem {
                                Label("Dev", systemImage: "hammer")
                            }
                            .tag(RootTab.dev)
                    }
#endif
                }
            } else {
                PrivacyIntroScreen {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        hasSeenPrivacyIntro = true
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}

private struct PrivacyIntroScreen: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("开始之前")
                        .font(.system(size: 34, weight: .bold))

                    Text("先把数据边界说清楚，再开始使用。")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 14) {
                    PrivacyPoint(
                        title: "默认只保存在本地",
                        detail: "文字记录、语音、转写和整理结果，默认只保存在你的本地设备上。"
                    )

                    PrivacyPoint(
                        title: "联网功能会单独处理",
                        detail: "只有在你主动使用 AI 对话、AI 回顾、转写或整理功能时，应用才会把必要内容通过我们的后台代理发送给模型服务处理。"
                    )

                    PrivacyPoint(
                        title: "不会暴露模型密钥",
                        detail: "测试版中的 AI 功能通过平台后台统一调用，不会把上游模型服务的密钥放进应用或发给用户端。"
                    )
                }

                Text("继续代表你已经了解当前版本默认以本地优先存储为基础。")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)

                Button(action: onContinue) {
                    Text("继续")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(.horizontal, 24)
            .padding(.top, 48)
            .padding(.bottom, 34)
            .frame(maxWidth: 620)
        }
    }
}

private struct PrivacyPoint: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
            Text(detail)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
