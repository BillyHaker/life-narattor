import SwiftUI
import UIKit

struct AppSettingsScreen: View {
    @Environment(\.dismiss) private var dismiss

    private let privacyURL = URL(string: "https://billyha.github.io/life-narattor/privacy/")!
    private let supportURL = URL(string: "https://billyha.github.io/life-narattor/support/")!

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    planCard

                    SettingsListCard(title: "AI 与订阅") {
                        SettingsValueRow(title: "当前方案", systemImage: "sparkles", value: "免费体验")
                        SettingsValueRow(title: "AI 额度", systemImage: "bolt.circle", value: "按使用量消耗")
                        SettingsValueRow(title: "管理订阅", systemImage: "creditcard", value: "即将开放")
                        SettingsValueRow(title: "自带 API", systemImage: "key", value: "计划中")
                    }

                    SettingsListCard(title: "数据与隐私") {
                        SettingsValueRow(title: "本地记录", systemImage: "iphone", value: "默认保存在本机")
                        SettingsValueRow(title: "导出数据", systemImage: "square.and.arrow.up", value: "即将支持")
                        SettingsDetailRow(
                            title: "AI 处理说明",
                            systemImage: "lock.shield",
                            detail: "使用 AI 回顾、助手、整理或语音转写时，会发送完成本次请求所需的内容。"
                        )
                        SettingsLinkRow(title: "隐私政策", systemImage: "doc.text", url: privacyURL)
                    }

                    SettingsListCard(title: "语音") {
                        SettingsValueRow(title: "语音转写", systemImage: "waveform", value: "豆包/火山引擎")
                        SettingsActionRow(title: "麦克风权限", systemImage: "mic", value: "系统设置") {
                            openSystemSettings()
                        }
                    }

                    SettingsListCard(title: "帮助与关于") {
                        NavigationLink {
                            FeedbackScreen()
                        } label: {
                            SettingsBaseRow(systemImage: "bubble.left.and.text.bubble.right") {
                                Text("反馈问题")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.primary)
                                Spacer(minLength: 12)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .buttonStyle(.plain)
                        SettingsLinkRow(title: "技术支持", systemImage: "questionmark.circle", url: supportURL)
                        SettingsValueRow(title: "版本", systemImage: "info.circle", value: appVersionText)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 34)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("设置")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.primary)
            Text("管理方案、隐私、语音和支持。")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 2)
    }

    private var planCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "sparkles")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 48, height: 48)
                    .background(Color.blue.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Text("Life Narrator")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.primary)
                    Text("当前为免费体验")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.blue)
                    Text("基础记录保持轻量免费，AI 功能按额度使用。")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: 10) {
                SettingsPill(text: "本地优先")
                SettingsPill(text: "AI 额度")
                SettingsPill(text: "7 天试用")
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        }
    }

    private var appVersionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "-"
        return "\(version) (\(build))"
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

private struct SettingsListCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 2)

            VStack(spacing: 0) {
                content
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.black.opacity(0.04), lineWidth: 1)
            }
        }
    }
}

private struct SettingsPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(Capsule())
    }
}

private struct SettingsValueRow: View {
    let title: String
    let systemImage: String
    let value: String

    var body: some View {
        SettingsBaseRow(systemImage: systemImage) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
            Spacer(minLength: 12)
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}

private struct SettingsDetailRow: View {
    let title: String
    let systemImage: String
    let detail: String

    var body: some View {
        SettingsBaseRow(systemImage: systemImage, alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                Text(detail)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }
}

private struct SettingsLinkRow: View {
    let title: String
    let systemImage: String
    let url: URL

    var body: some View {
        Link(destination: url) {
            SettingsBaseRow(systemImage: systemImage) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                Spacer(minLength: 12)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct SettingsActionRow: View {
    let title: String
    let systemImage: String
    let value: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            SettingsBaseRow(systemImage: systemImage) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                Spacer(minLength: 12)
                Text(value)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct SettingsBaseRow<Content: View>: View {
    let systemImage: String
    var alignment: VerticalAlignment = .center
    @ViewBuilder let content: Content

    var body: some View {
        HStack(alignment: alignment, spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.blue)
                .frame(width: 30, height: 30)
                .background(Color.blue.opacity(0.09))
                .clipShape(Circle())

            content
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}
