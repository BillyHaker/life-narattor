import PhotosUI
import SwiftUI
import UIKit

struct FeedbackScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var message = ""
    @State private var contact = ""
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var screenshotData: Data? = nil
    @State private var screenshotPreview: UIImage? = nil
    @State private var isSending = false
    @State private var statusMessage: String? = nil
    @State private var didSend = false

    private var canSend: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                introCard
                messageCard
                contactCard
                screenshotCard
                sendButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 34)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("反馈问题")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("关闭") { dismiss() }
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task { await loadScreenshot(from: newItem) }
        }
    }

    private var introCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("告诉我们哪里不顺")
                .font(.system(size: 24, weight: .bold))
            Text("一句描述就够。你可以附一张截图，便于我们定位界面或 AI 服务问题。反馈不会包含你的完整记录正文。")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var messageCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("问题描述")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
            TextField("例如：记录拆分一直失败，或 AI 回顾没有结果", text: $message, axis: .vertical)
                .font(.system(size: 17, weight: .regular))
                .lineLimit(5...9)
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .settingsFeedbackCardStyle()
    }

    private var contactCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("回访方式（可选）")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
            TextField("邮箱、微信或其他你方便的联系方式", text: $contact)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .settingsFeedbackCardStyle()
    }

    private var screenshotCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("截图")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Text(screenshotData == nil ? "添加截图" : "更换")
                        .font(.system(size: 15, weight: .semibold))
                }
            }

            if let screenshotPreview {
                Image(uiImage: screenshotPreview)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 260)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(alignment: .topTrailing) {
                        Button {
                            selectedPhotoItem = nil
                            screenshotData = nil
                            self.screenshotPreview = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24, weight: .semibold))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.secondary)
                                .padding(8)
                        }
                    }
            } else {
                Text("可选。截图只用于定位你反馈的问题。")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .settingsFeedbackCardStyle()
    }

    private var sendButton: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                Task { await sendFeedback() }
            } label: {
                HStack(spacing: 8) {
                    if isSending { ProgressView().tint(.white) }
                    Text(didSend ? "已发送" : "发送反馈")
                        .font(.system(size: 17, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .disabled(!canSend || didSend)

            if let statusMessage {
                Text(statusMessage)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(didSend ? Color.secondary : Color.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func loadScreenshot(from item: PhotosPickerItem?) async {
        guard let item else { return }
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                statusMessage = "没有读取到截图，请重新选择。"
                return
            }
            let compressed = image.lifeNarratorCompressedJPEG(maxPixel: 1400, quality: 0.72)
            screenshotData = compressed
            screenshotPreview = UIImage(data: compressed) ?? image
            statusMessage = nil
        } catch {
            statusMessage = "读取截图失败，请重新选择。"
        }
    }

    private func sendFeedback() async {
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }

        isSending = true
        statusMessage = nil
        defer { isSending = false }

        do {
            try await FeedbackService().submit(
                message: trimmedMessage,
                contact: contact.trimmingCharacters(in: .whitespacesAndNewlines),
                screenshotData: screenshotData
            )
            didSend = true
            statusMessage = "已收到。谢谢你把这个问题告诉我们。"
        } catch FeedbackServiceError.backendUnavailable {
            statusMessage = "反馈服务还没有配置公网地址。你可以先通过技术支持页面或已有联系渠道反馈。"
        } catch {
            statusMessage = "发送失败，请稍后再试。"
        }
    }
}

private struct FeedbackService {
    func submit(message: String, contact: String, screenshotData: Data?) async throws {
        guard let baseURL = BackendConfig.baseURL else {
            throw FeedbackServiceError.backendUnavailable
        }

        var request = URLRequest(url: baseURL.appendingPathComponent("/v1/feedback"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(appIdentifier(), forHTTPHeaderField: "X-App-Id")
        request.setValue(appVersion(), forHTTPHeaderField: "X-App-Version")
        request.setValue(AppRuntimeIdentity.userIdentifier(), forHTTPHeaderField: "X-User-Id")

        let payload = FeedbackPayload(
            message: message,
            contact: contact.isEmpty ? nil : contact,
            appVersion: appVersion(),
            osVersion: UIDevice.current.systemVersion,
            deviceModel: deviceModel(),
            screenshot: screenshotData.map {
                FeedbackScreenshot(
                    mimeType: "image/jpeg",
                    data: $0.base64EncodedString(),
                    byteCount: $0.count
                )
            }
        )
        request.httpBody = try JSONEncoder().encode(payload)

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw FeedbackServiceError.requestFailed
        }
    }

    private func appIdentifier() -> String {
        Bundle.main.bundleIdentifier ?? "LifeNarrator"
    }

    private func appVersion() -> String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
        return "\(version) (\(build))"
    }

    private func deviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machine = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0) ?? UIDevice.current.model
            }
        }
        return machine
    }
}

private enum FeedbackServiceError: Error {
    case backendUnavailable
    case requestFailed
}

private struct FeedbackPayload: Encodable {
    let message: String
    let contact: String?
    let appVersion: String
    let osVersion: String
    let deviceModel: String
    let screenshot: FeedbackScreenshot?

    private enum CodingKeys: String, CodingKey {
        case message
        case contact
        case appVersion = "app_version"
        case osVersion = "os_version"
        case deviceModel = "device_model"
        case screenshot
    }
}

private struct FeedbackScreenshot: Encodable {
    let mimeType: String
    let data: String
    let byteCount: Int

    private enum CodingKeys: String, CodingKey {
        case mimeType = "mime_type"
        case data
        case byteCount = "byte_count"
    }
}

private extension View {
    func settingsFeedbackCardStyle() -> some View {
        self
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private extension UIImage {
    func lifeNarratorCompressedJPEG(maxPixel: CGFloat, quality: CGFloat) -> Data {
        let longest = max(size.width, size.height)
        let scale = longest > maxPixel ? maxPixel / longest : 1
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let image = renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return image.jpegData(compressionQuality: quality) ?? Data()
    }
}
