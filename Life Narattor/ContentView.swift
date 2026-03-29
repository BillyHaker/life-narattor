import CoreData
import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var context
    @AppStorage("app.hasSeenPrivacyIntro") private var hasSeenPrivacyIntro = false

    private let aiService: AIService

    init(aiService: AIService = AIServiceFactory.make()) {
        self.aiService = aiService
    }

    var body: some View {
        TabView {
            RecordFeedScreen(context: context, aiService: aiService)
                .tabItem {
                    Label("记录", systemImage: "square.and.pencil")
                }

            TimelineScreen()
                .tabItem {
                    Label("时间线", systemImage: "clock")
                }

            ProjectsListScreen()
                .tabItem {
                    Label("项目", systemImage: "folder")
                }

            NavigationStack {
                SearchScreen()
            }
                .tabItem {
                    Label("AI回顾", systemImage: "sparkles")
                }

#if DEBUG
            DevToolsRootView(storage: CoreDataDebugStorageProvider(context: context), context: context, aiService: aiService)
                .tabItem {
                    Label("Dev", systemImage: "hammer")
                }
#endif
        }
        .sheet(isPresented: Binding(
            get: { !hasSeenPrivacyIntro },
            set: { newValue in
                if !newValue {
                    hasSeenPrivacyIntro = true
                }
            }
        )) {
            PrivacyIntroSheet {
                hasSeenPrivacyIntro = true
            }
            .interactiveDismissDisabled()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}

private struct PrivacyIntroSheet: View {
    let onContinue: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("隐私说明")
                        .font(.system(size: 28, weight: .bold))

                    Text("在开始使用前，我们先把数据边界说清楚。")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 16) {
                    PrivacyPoint(
                        title: "默认只保存在本地",
                        detail: "文字记录、语音、转写和整理结果，默认只保存在你的本地设备上。"
                    )

                    PrivacyPoint(
                        title: "联网功能会单独处理",
                        detail: "只有在你主动使用 AI 对话、AI 回顾、转写或整理功能时，应用才会通过我们的后台代理发起联网请求。"
                    )

                    PrivacyPoint(
                        title: "不会把 provider key 发给测试用户",
                        detail: "测试版中的 AI 功能通过平台后台统一调用，不会把上游模型的 API key 暴露给用户端。"
                    )
                }

                Text("继续代表你已经了解当前测试版以本地优先存储为默认方式。")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)

                Spacer()

                Button(action: onContinue) {
                    Text("继续")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
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
