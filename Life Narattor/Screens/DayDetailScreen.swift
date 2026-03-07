import SwiftUI

struct DayDetailScreen: View {
    let day: TimelineDay

    @State private var selectedCommentStyle: CommentStyle = .gentle
    @State private var isCommentEnabled: Bool = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                narrativeSection
                commentSection
                recordsSection
                sourcesSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .navigationTitle(formattedHeaderDate(day.date))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }

    private var headerSection: some View {
        Text(formattedHeaderDate(day.date))
            .font(.title2.weight(.semibold))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var narrativeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日叙事")
                .font(.headline)

            Text("今天我主要在整理记录，也完成了一些小的推进。")
                .font(.body)
                .foregroundStyle(.primary)

            HStack(spacing: 12) {
                Button("编辑叙事") {}
                    .buttonStyle(.bordered)
                Button("重新生成") {}
                    .buttonStyle(.bordered)
            }
        }
    }

    private var commentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("AI 的回应")
                    .font(.headline)
                Spacer()
                Toggle("关闭回应", isOn: $isCommentEnabled)
                    .labelsHidden()
            }

            if isCommentEnabled {
                Picker("风格", selection: $selectedCommentStyle) {
                    ForEach(CommentStyle.allCases) { style in
                        Text(style.title).tag(style)
                    }
                }
                .pickerStyle(.segmented)

                Text(selectedCommentStyle.sampleText)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var recordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日记录")
                .font(.headline)

            ForEach(day.highlights, id: \.self) { highlight in
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .fill(Color(.systemGray3))
                        .frame(width: 6, height: 6)
                        .padding(.top, 6)
                    Text(highlight)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
            }
        }
    }

    private var sourcesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("引用来源")
                .font(.headline)
            Text("来自 09:12 · 开会做了进度对齐")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private func formattedHeaderDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy/MM/dd · EEEE"
        return formatter.string(from: date)
    }
}

enum CommentStyle: String, CaseIterable, Identifiable {
    case gentle
    case honest
    case action
    case pattern

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gentle:
            return "温和观察"
        case .honest:
            return "诚实直说"
        case .action:
            return "行动提醒"
        case .pattern:
            return "模式识别"
        }
    }

    var sampleText: String {
        switch self {
        case .gentle:
            return "听下来你已经在把事情慢慢理清，这点很稳。"
        case .honest:
            return "你提到的“方向乱”不止一次，也许还缺一个更固定的收敛方式。"
        case .action:
            return "下次再觉得乱的时候，也许先写下 3 个必须回答的问题会更快收敛。"
        case .pattern:
            return "最近几次你先烦一下，然后就会转向整理结构。"
        }
    }
}
