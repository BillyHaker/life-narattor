import SwiftUI

struct DevToolsAIDebugView: View {
    @State private var store = AIDebugStore.shared
    @State private var selectedEntry: AIDebugEntry? = nil

    var body: some View {
        List {
            if store.entries.isEmpty {
                Text("暂无 AI 调试记录")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(store.entries) { entry in
                    Button {
                        selectedEntry = entry
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(entry.operation) · \(entry.status)")
                                .font(.subheadline.weight(.semibold))
                            Text("\(entry.model) · \(entry.durationMs)ms · \(entry.timestamp.formatted(date: .numeric, time: .shortened))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("AI Debug")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Clear") {
                    store.clear()
                }
            }
        }
        .sheet(item: $selectedEntry) { entry in
            DevToolsAIDebugDetail(entry: entry)
        }
    }
}

private struct DevToolsAIDebugDetail: View {
    let entry: AIDebugEntry

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    section(title: "状态", value: "\(entry.status) · \(entry.durationMs)ms")
                    section(title: "模型", value: entry.model)
                    section(title: "请求", value: entry.requestBody)
                    section(title: "响应", value: entry.responseBody)
                    if let errorMessage = entry.errorMessage {
                        section(title: "错误", value: errorMessage)
                    }
                }
                .padding(16)
            }
            .navigationTitle(entry.operation)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func section(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.footnote)
                .textSelection(.enabled)
        }
    }
}
