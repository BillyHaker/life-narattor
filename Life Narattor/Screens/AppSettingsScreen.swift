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

                    SettingsSectionCard(title: "AI 与额度", systemImage: "sparkles") {
                        SettingsInfoRow(
                            title: "当前版本",
                            detail: "记录、助手和回顾会按使用量消耗 AI 额度。额度和订阅状态会在后续版本里显示得更清楚。"
                        )
                        SettingsInfoRow(
                            title: "试用与订阅",
                            detail: "新用户会先获得试用额度。试用结束后，仍可继续使用基础记录；更深的 AI 回顾和高频使用会进入订阅额度。"
                        )
                    }

                    SettingsSectionCard(title: "隐私与 AI 处理", systemImage: "lock.shield") {
                        SettingsInfoRow(
                            title: "记录默认留在本地",
                            detail: "你写下的记录、整理结果和拆分结果默认保存在这台设备上，不会作为长期内容上传到服务器。"
                        )
                        SettingsInfoRow(
                            title: "主动使用 AI 时才发送必要内容",
                            detail: "当你使用 AI 回顾、助手、整理为记录或语音转写时，应用会发送完成本次请求所需的文本、相关片段、问题或音频。"
                        )
                        SettingsInfoRow(
                            title: "第三方 AI 服务",
                            detail: "AI 请求会通过 Life Narrator 后台代理发送给 OpenAI；语音转写可能发送给火山引擎/豆包服务。"
                        )
                        SettingsLinkRow(title: "查看隐私政策", url: privacyURL)
                    }

                    SettingsSectionCard(title: "语音与权限", systemImage: "mic") {
                        SettingsInfoRow(
                            title: "语音转写",
                            detail: "使用语音记录需要麦克风权限。录音只用于生成本次转写和记录整理。"
                        )
                        SettingsActionRow(title: "打开系统权限设置") {
                            openSystemSettings()
                        }
                    }

                    SettingsSectionCard(title: "支持", systemImage: "questionmark.circle") {
                        SettingsLinkRow(title: "技术支持", url: supportURL)
                        SettingsValueRow(title: "版本", value: appVersionText)
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
            Text("管理 AI 使用、隐私说明、语音权限和支持信息。")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, 4)
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

private struct SettingsSectionCard<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 30, height: 30)
                    .background(Color.blue.opacity(0.10))
                    .clipShape(Circle())

                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.primary)
            }

            VStack(alignment: .leading, spacing: 0) {
                content
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        }
    }
}

private struct SettingsInfoRow: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
            Text(detail)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 10)
    }
}

private struct SettingsLinkRow: View {
    let title: String
    let url: URL

    var body: some View {
        Link(destination: url) {
            SettingsRowContent(title: title, accessorySystemImage: "arrow.up.right")
        }
        .buttonStyle(.plain)
        .padding(.vertical, 10)
    }
}

private struct SettingsActionRow: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            SettingsRowContent(title: title, accessorySystemImage: "chevron.right")
        }
        .buttonStyle(.plain)
        .padding(.vertical, 10)
    }
}

private struct SettingsValueRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 10)
    }
}

private struct SettingsRowContent: View {
    let title: String
    let accessorySystemImage: String

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
            Spacer()
            Image(systemName: accessorySystemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
    }
}
