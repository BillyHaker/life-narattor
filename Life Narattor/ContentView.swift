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
    @AppStorage("privacy.hasConsentedToAIProcessing") private var hasConsentedToAIProcessing = false
    @StateObject private var featureFlags = FeatureFlags.shared
    @State private var selectedTab: RootTab = .record

    private let aiService: AIService

    init(aiService: AIService = AIServiceFactory.make()) {
        self.aiService = aiService
    }

    var body: some View {
        Group {
            if hasSeenPrivacyIntro && hasConsentedToAIProcessing {
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
                        hasConsentedToAIProcessing = true
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

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("隐私与 AI 处理说明")
                            .font(.system(size: 34, weight: .bold))

                        Text("先把哪些内容会留在本地、哪些内容会发给 AI 服务说清楚。")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        PrivacyPoint(
                            title: "默认只保存在本地",
                            detail: "你输入的文字记录、语音、转写结果、整理结果和拆分结果默认保存在本机。我们不会把完整记录上传到服务器做长期内容存储。"
                        )

                        PrivacyPoint(
                            title: "使用 AI 时会发送必要内容",
                            detail: "当你主动使用 AI 回顾、助手对话、整理为记录或语音转写时，应用会发送完成本次请求所需的记录文本、问题、相关片段，或语音转写所需音频。"
                        )

                        PrivacyPoint(
                            title: "接收方是 AI 服务提供方",
                            detail: "这些请求会通过 Life Narrator 后台代理发送给第三方 AI 服务处理，包括 OpenAI，以及用于语音转写的火山引擎/豆包服务。"
                        )

                        PrivacyPoint(
                            title: "用途仅限完成你请求的功能",
                            detail: "发送的数据只用于生成本次转写、整理、对话或回顾结果；不用于广告追踪，不出售给第三方，也不会把上游模型密钥放进应用。"
                        )
                    }

                    Text("点击“同意并继续”代表你允许应用在你使用 AI 功能时，按上述方式把必要内容发送给相关 AI 服务处理。")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Button(action: onContinue) {
                        Text("同意并继续")
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
