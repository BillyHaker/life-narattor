import CoreData
import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var context
    private let aiService: AIService = MockAIService()

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

            ReviewHomeScreen()
                .tabItem {
                    Label("回顾", systemImage: "sparkles")
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
