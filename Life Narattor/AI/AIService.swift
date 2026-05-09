import Foundation
import AVFoundation

protocol AIService {
    func quickAck(for capture: CaptureItem) async throws -> QuickAckResult
    func cleanTranscript(text: String, forceAI: Bool) async throws -> CleanDefillerResult
    func chatReply(for capture: CaptureItem, questionText: String) async throws -> String
    func analyzeFocusedEvidence(_ bundle: FocusedEvidenceBundle, followupQuestion: String?) async throws -> String
    func analyzeNarrativeMaterial(_ material: NarrativeMaterial, periodName: String, followupQuestion: String?) async throws -> String
    func assistArchive(for capture: CaptureItem, questionText: String) async throws -> AssistArchivePayload
    func createDeepTask(_ request: DeepTaskRequest) async throws -> DeepTaskHandle
    func atomize(capture: CaptureItem, tagLibrary: TagLibrary) async throws -> AtomizeResult
    func suggestTags(atomization: AtomizeResult, tagLibrary: TagLibrary) async throws -> TagSuggestionResult
    func clusterHiddenTags(_ tags: [HiddenTagInventoryItem]) async throws -> HiddenTagClusterResult
    func normalizeHiddenTags(in bucket: HiddenTagBucket, tags: [HiddenTagInventoryItem]) async throws -> [HiddenTagCanonicalMapping]
    func transcribeAudio(fileURL: URL, locale: String?) async throws -> String
}

enum AIServiceError: Error {
    case missingAPIKey
    case invalidResponse
    case httpStatus(Int)
    case emptyResponse
    case unsupported
}

enum AIServiceFactory {
    static func make() -> AIService {
        if let baseURL = BackendConfig.baseURL {
            let host = baseURL.host ?? baseURL.absoluteString
            LogStore.shared.log("AIService=Backend (\(host))", category: .ai)
            return BackendAIService(baseURL: baseURL, token: BackendConfig.token)
        }

#if DEBUG
        if let apiKey = OpenAIConfig.apiKey, !apiKey.isEmpty {
            LogStore.shared.log("AIService=OpenAI", category: .ai)
            return OpenAIService(apiKey: apiKey)
        }
#endif

        LogStore.shared.log("AIService=Unavailable", category: .ai)
        return UnavailableAIService()
    }
}

struct BackendConfig {
    static var baseURL: URL? {
        if let raw = ProcessInfo.processInfo.environment["LIFENARRATOR_AI_BASE"]?.trimmingCharacters(in: .whitespacesAndNewlines),
           !raw.isEmpty {
            return URL(string: raw)
        }

        if let raw = Bundle.main.object(forInfoDictionaryKey: "LifeNarratorAIBaseURL") as? String {
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                return URL(string: trimmed)
            }
        }

        if let raw = bundledAppConfigValue(forKey: "AIBaseURL") {
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                return URL(string: trimmed)
            }
        }

        return nil
    }

    static var token: String? {
        ProcessInfo.processInfo.environment["LIFENARRATOR_AI_TOKEN"]
    }

    private static func bundledAppConfigValue(forKey key: String) -> String? {
        guard let url = Bundle.main.url(forResource: "AppConfig", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
            return nil
        }
        return plist[key] as? String
    }
}

enum AppRuntimeIdentity {
    private static let key = "LifeNarrator.BetaUserID"

    static func userIdentifier() -> String {
        if let existing = UserDefaults.standard.string(forKey: key), !existing.isEmpty {
            syncToICloudIfNeeded(existing)
            return existing
        }
        if let cloudValue = NSUbiquitousKeyValueStore.default.string(forKey: key), !cloudValue.isEmpty {
            UserDefaults.standard.set(cloudValue, forKey: key)
            return cloudValue
        }
        let created = "beta-\(UUID().uuidString.lowercased())"
        UserDefaults.standard.set(created, forKey: key)
        syncToICloudIfNeeded(created)
        return created
    }

    private static func syncToICloudIfNeeded(_ userID: String) {
        let store = NSUbiquitousKeyValueStore.default
        if store.string(forKey: key) != userID {
            store.set(userID, forKey: key)
        }
        store.synchronize()
    }
}

struct OpenAIConfig {
    static var apiKey: String? {
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !envKey.isEmpty {
            return envKey
        }
        return KeychainStore.get("OPENAI_API_KEY")
    }

    static let model: String = "gpt-4o-mini"
    static let transcriptionModel: String = "whisper-1"
}

struct QuickAckResult {
    let ackTitle: String
    let ackDetail: String
}

struct DeepTaskRequest: Encodable {
    let taskType: DeepTaskType
    let scopeKey: String
    let inputs: [String: String]

    private enum CodingKeys: String, CodingKey {
        case taskType = "task_type"
        case scopeKey = "scope_key"
        case inputs
    }
}

enum DeepTaskType: String, Codable {
    case projectReview
    case weeklyReview
    case themeReview
    case deepDailyReview
}

struct DeepTaskHandle {
    let id: String
}

final class UnavailableAIService: AIService {
    func quickAck(for capture: CaptureItem) async throws -> QuickAckResult {
        throw AIServiceError.missingAPIKey
    }

    func cleanTranscript(text: String, forceAI: Bool) async throws -> CleanDefillerResult {
        throw AIServiceError.missingAPIKey
    }

    func chatReply(for capture: CaptureItem, questionText: String) async throws -> String {
        throw AIServiceError.missingAPIKey
    }

    func analyzeFocusedEvidence(_ bundle: FocusedEvidenceBundle, followupQuestion: String? = nil) async throws -> String {
        throw AIServiceError.missingAPIKey
    }

    func analyzeNarrativeMaterial(_ material: NarrativeMaterial, periodName: String, followupQuestion: String? = nil) async throws -> String {
        throw AIServiceError.missingAPIKey
    }

    func assistArchive(for capture: CaptureItem, questionText: String) async throws -> AssistArchivePayload {
        throw AIServiceError.missingAPIKey
    }

    func createDeepTask(_ request: DeepTaskRequest) async throws -> DeepTaskHandle {
        throw AIServiceError.missingAPIKey
    }

    func atomize(capture: CaptureItem, tagLibrary: TagLibrary) async throws -> AtomizeResult {
        throw AIServiceError.missingAPIKey
    }

    func suggestTags(atomization: AtomizeResult, tagLibrary: TagLibrary) async throws -> TagSuggestionResult {
        throw AIServiceError.missingAPIKey
    }

    func clusterHiddenTags(_ tags: [HiddenTagInventoryItem]) async throws -> HiddenTagClusterResult {
        throw AIServiceError.missingAPIKey
    }

    func normalizeHiddenTags(in bucket: HiddenTagBucket, tags: [HiddenTagInventoryItem]) async throws -> [HiddenTagCanonicalMapping] {
        throw AIServiceError.missingAPIKey
    }

    func transcribeAudio(fileURL: URL, locale: String?) async throws -> String {
        throw AIServiceError.missingAPIKey
    }
}

final class OpenAIService: AIService {
    private let apiKey: String
    private let session: URLSession

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    func quickAck(for capture: CaptureItem) async throws -> QuickAckResult {
        LogStore.shared.log("QuickAck=OpenAI", category: .ai)
        let payload = try await requestJSON(
            schemaName: "quick_ack",
            schema: quickAckSchema(),
            instructions: """
            Return JSON only.
            Role: high-trust personal assistant. Calm, direct, restrained.
            ack_title should be very short, neutral, and non-cheerleading.
            ack_detail should mirror the user's point cleanly without praise, coaching, or extra expansion.
            Avoid emoji, exclamation marks, and therapeutic tone.
            """,
            userInput: "Generate ack_title and ack_detail for: \(capture.cleanText ?? capture.rawText)"
        )

        guard let data = payload.data(using: .utf8) else {
            throw AIServiceError.invalidResponse
        }

        let result = try JSONDecoder().decode(QuickAckPayload.self, from: data)
        return QuickAckResult(ackTitle: result.ackTitle, ackDetail: result.ackDetail)
    }

    func cleanTranscript(text: String, forceAI: Bool) async throws -> CleanDefillerResult {
        let ruleResult = CleanDefiller.clean(text)
        let payload = try await requestJSON(
            schemaName: "clean_transcript",
            schema: cleanTranscriptSchema(),
            instructions: """
            Return JSON only.
            You are cleaning spoken-language transcription, not summarizing it.
            Keep the user's original meaning, sequence, and speaking style.
            Preserve the original grammatical person and narrative viewpoint. If the user speaks in first person, keep first person.
            Only remove filler words, merge obvious repetition, repair broken clauses, and add minimal punctuation.
            Do not add facts, do not summarize, do not rewrite into formal prose.
            If the text is already clear, make the smallest possible edits.
            Answer concisely and precisely.
            """,
            userInput: """
            Raw transcript: \(text)
            Rule-cleaned baseline: \(ruleResult.cleanText)
            force_ai: \(forceAI ? "true" : "false")
            """
        )

        guard let data = payload.data(using: .utf8) else {
            throw AIServiceError.invalidResponse
        }

        let result = try JSONDecoder().decode(CleanTranscriptPayload.self, from: data)
        let cleanText = result.cleanText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else {
            throw AIServiceError.emptyResponse
        }

        return CleanDefillerResult(
            cleanText: cleanText,
            removedFillers: result.removedFillers,
            rulesetVersion: "ai_clean_v1"
        )
    }

    func chatReply(for capture: CaptureItem, questionText: String) async throws -> String {
        let payload = try await requestJSON(
            schemaName: "chat_reply",
            schema: chatReplySchema(),
            instructions: "Return JSON only. Answer concisely and precisely.",
            userInput: "User asked: \(questionText). Conversation context: \(capture.cleanText ?? capture.rawText)."
        )

        guard let data = payload.data(using: .utf8) else {
            throw AIServiceError.invalidResponse
        }

        let result = try JSONDecoder().decode(ChatReplyPayload.self, from: data)
        return result.reply
    }

    func analyzeFocusedEvidence(_ bundle: FocusedEvidenceBundle, followupQuestion: String? = nil) async throws -> String {
        let payload = try await requestJSON(
            schemaName: "focused_evidence_analysis",
            schema: chatReplySchema(),
            instructions: """
            Return JSON only. Reply in concise natural Chinese using record/review language, not English.
            You are analyzing structured evidence, not inventing facts.
            system_signals are factual context such as date, weekday, time segment, input source, and processing state. Use them only as factual context.
            If followup_question is empty, first show facts directly supported by the evidence, then weaker links or signals, then 1-2 short follow-up questions.
            If followup_question is present, answer only that follow-up from the current evidence bundle and keep the answer short.
            Do not claim strong causality unless the evidence explicitly supports it.
            If evidence is limited, say it is only a tentative signal.
            Prefer the labels: 事实： / 联系： / 可继续问：
            """,
            userInput: focusedEvidenceJSONString(from: bundle, followupQuestion: followupQuestion)
        )

        guard let data = payload.data(using: .utf8) else {
            throw AIServiceError.invalidResponse
        }

        let result = try JSONDecoder().decode(ChatReplyPayload.self, from: data)
        return result.reply
    }

    func analyzeNarrativeMaterial(_ material: NarrativeMaterial, periodName: String, followupQuestion: String? = nil) async throws -> String {
        let payload = try await requestJSON(
            schemaName: "review_narrative_analysis",
            schema: chatReplySchema(),
            instructions: """
            Return JSON only. Reply in concise natural Chinese using record/review language, not English.
            You are reviewing structured life material for a time period.
            system_signals are factual context such as date, weekday, time segment, input source, and processing state. Use them only as factual context.
            If followup_question is empty, write a short review note, not a report: first show facts that are directly visible in the records, then weaker links or insights that are not obvious from linear diary reading, then 1-2 short follow-up questions.
            If followup_question is present, answer only that follow-up from the current material and keep the answer short.
            Stay evidence-bound. Do not invent motives or facts. Do not use coaching tone. Do not claim strong causality.
            Keep the reply short enough to fit on the first screen.
            Prefer the labels: 事实： / 联系： / 可继续问：
            """,
            userInput: """
            period_name: \(periodName)
            followup_question: \(followupQuestion ?? "")
            material: \(narrativeMaterialJSONString(from: material))
            """
        )

        guard let data = payload.data(using: .utf8) else {
            throw AIServiceError.invalidResponse
        }

        let result = try JSONDecoder().decode(ChatReplyPayload.self, from: data)
        return result.reply
    }

    func assistArchive(for capture: CaptureItem, questionText: String) async throws -> AssistArchivePayload {
        let payload = try await requestJSON(
            schemaName: "assist_archive",
            schema: assistArchiveSchema(),
            instructions: """
            Return JSON only.
            You are turning an assistant conversation into a record draft the person can save directly.
            Write in natural Chinese record language, not in system-summary language.
            Do not use third-person product wording such as “用户”, “助手”, “AI”, or “系统” in title, context, summaries, key points, or next steps.
            Do not write case-note language like “用户咨询…”, “助手建议…”, “本次对话中…”, “摘要”, “总结”, or “纪要”.
            Prefer direct record phrasing:
            - concise, natural narration
            - neutral tone
            - no coaching voice
            - no report voice
            Titles should feel like real note titles that can be kept directly, not “总结/摘要/纪要”.
            Build one concise archive card and split the conversation into 1-4 meaningful record units by topic.
            Each record unit should stand on its own and should not be a sentence fragment.
            """,
            userInput: """
            User asked: \(questionText).
            Conversation context: \(capture.cleanText ?? capture.rawText).
            """
        )

        guard let data = payload.data(using: .utf8) else {
            throw AIServiceError.invalidResponse
        }

        let result = try JSONDecoder().decode(AssistArchiveDraftPayload.self, from: data)
        return AssistArchivePayload(
            reply: result.reply,
            card: AssistArchiveCard(
                title: result.title,
                context: result.context,
                keyPoints: result.keyPoints,
                nextSteps: result.nextSteps,
                recordUnits: result.recordUnits,
                tagSuggestions: [],
                confidence: "medium"
            ),
            turnPolicy: AssistTurnPolicy(usedClarification: false, turnsRemaining: 1)
        )
    }

    func createDeepTask(_ request: DeepTaskRequest) async throws -> DeepTaskHandle {
        return DeepTaskHandle(id: "openai-task-\(UUID().uuidString)")
    }

    func atomize(capture: CaptureItem, tagLibrary: TagLibrary) async throws -> AtomizeResult {
        let cleanText = capture.cleanText ?? capture.rawText
        let payload: [String: Any] = [
            "capture_id": capture.id.uuidString,
            "clean_text": cleanText,
            "language": "zh",
            "policy": [
                "no_formalization": true,
                "max_units": 4,
                "prefer_retainable_units": true
            ],
            "existing_visible_tags": tagLibrary.summary
        ]
        let userInput = jsonString(from: payload)
        let output = try await requestJSON(
            schemaName: "atomize",
            schema: atomizeSchema(),
            instructions: """
            Return JSON only.
            You are helping the user accumulate life material they can revisit later to understand themselves, compare patterns, and improve their life.
            Preserve the user's original phrasing, perspective, intent, and narrative structure. Do not formalize.
            First extract semantic chunks that keep all meaningful information, including actions, states, judgments, results, time anchors, and explicit causal or turning relations.
            Then assemble 1-4 record units, defaulting to as few units as possible.
            A record unit is a complete thing the user may later revisit, expand, search, or compare. It is not a clause or phrase fragment.
            Split only when the text clearly contains different retainable matters, different stages in time, or different outcomes.
            Each unit summary must contain exactly one main matter. Do not pack two parallel matters into one summary.
            If a detail is only time, degree, condition, emotional color, or background, keep it in context_attributes instead of creating another unit.
            If the text contains a sequence of related actions, preserve that sequence in behavioral_chain instead of flattening it into a generic summary.
            If the text explicitly states a result, outcome, feeling, or state change for the matter, preserve it in result_or_state instead of dropping it.
            Do not lose explicit feelings, results, or consequences from the original text.
            Feelings or state phrases should normally stay attached to the nearest main matter in result_or_state. Do not make them their own unit unless the text is mainly about that state itself.
            result_or_state must contain only consequences, outcomes, feelings, or state changes explicitly stated for the main matter. Do not restate the main matter itself there.
            Do not infer definite causality from time adjacency, same paragraph, emotional similarity, or co-occurrence.
            Only use definite causal wording when the original text explicitly uses causal markers such as 因为、所以、导致、让我、使得、造成、引发、可能是.
            If causality is not explicit, preserve the facts as parallel facts or temporal sequence.
            Use weak wording such as 可能相关 only when the original text itself suggests uncertainty.
            Each unit summary must stand on its own when read without the original text.
            If the original text clearly shares a time anchor, subject, or sequence relation across clauses, carry that context into the relevant unit when needed for clarity.
            tag_hints must be noun or noun-phrase style retrieval clues, not full sentences.
            Do not add new facts, motives, or interpretations.
            """,
            userInput: userInput
        )
        guard let data = output.data(using: .utf8) else {
            throw AIServiceError.invalidResponse
        }
        return try JSONDecoder().decode(AtomizeResult.self, from: data)
    }

    func suggestTags(atomization: AtomizeResult, tagLibrary: TagLibrary) async throws -> TagSuggestionResult {
        let chunkPayload = atomization.semanticChunks.map { chunk in
            [
                "text": chunk.text,
                "kind": chunk.kind,
                "sequence_index": chunk.sequenceIndex as Any
            ]
        }
        let unitPayload = atomization.recordUnits.map { unit in
            [
                "summary": unit.summary,
                "context_attributes": unit.contextAttributes.map { ["name": $0.name, "value": $0.value] },
                "behavioral_chain": unit.behavioralChain,
                "result_or_state": unit.resultOrState,
                "tag_hints": unit.tagHints
            ]
        }
        let payload: [String: Any] = [
            "semantic_chunks": chunkPayload,
            "record_units": unitPayload,
            "existing_visible_tags": tagLibrary.summary,
            "policy": [
                "max_visible_suggestions": 0,
                "target_hidden_suggestions": 4,
                "prefer_existing_visible_tags": true,
                "only_create_new_visible_tag_if_no_close_match": true
            ]
        ]
        let userInput = jsonString(from: payload)
        let output = try await requestJSON(
            schemaName: "tag_suggest",
            schema: tagSuggestionSchema(),
            instructions: """
            Return JSON only.
            Return an empty suggestions array.
            Also return 2-5 hidden suggestions by default unless the material is truly too weak.
            Work from record units first, then use semantic chunks as supporting detail.
            Treat tag_hints inside each record unit as the strongest retrieval cues.
            hidden_suggestions should be richer than visible suggestions and should usually include concrete themes, states, contexts, habits, or retrieval clues that help later recall.
            hidden_suggestions must still be short noun or noun-phrase tags.
            Do not output sentence-like labels.
            """,
            userInput: userInput
        )
        guard let data = output.data(using: .utf8) else {
            throw AIServiceError.invalidResponse
        }
        return try JSONDecoder().decode(TagSuggestionResult.self, from: data)
    }

    func clusterHiddenTags(_ tags: [HiddenTagInventoryItem]) async throws -> HiddenTagClusterResult {
        let userInput = jsonString(from: [
            "hidden_tags": tags.map {
                [
                    "id": $0.id.uuidString,
                    "name": $0.name,
                    "type": $0.type,
                    "link_count": $0.linkCount
                ]
            }
        ])
        let output = try await requestJSON(
            schemaName: "hidden_tag_cluster",
            schema: hiddenTagClusterSchema(),
            instructions: """
            Return JSON only.
            You are organizing hidden retrieval tags into broad semantic buckets before later synonym normalization.
            Do not merge, rename, or simplify tags here. Only assign them to broad groups.
            Put every tag into exactly one bucket.
            Use only these buckets: work_project, habit_rhythm, state_emotion, body_health, context_scene, person_relation, interest_topic, misc.
            Keep grouping broad and stable. When unsure, use misc.
            """,
            userInput: userInput
        )
        guard let data = output.data(using: .utf8) else {
            throw AIServiceError.invalidResponse
        }
        return try JSONDecoder().decode(HiddenTagClusterResult.self, from: data)
    }

    func normalizeHiddenTags(in bucket: HiddenTagBucket, tags: [HiddenTagInventoryItem]) async throws -> [HiddenTagCanonicalMapping] {
        let userInput = jsonString(from: [
            "bucket": bucket.rawValue,
            "hidden_tags": tags.map {
                [
                    "id": $0.id.uuidString,
                    "name": $0.name,
                    "type": $0.type,
                    "link_count": $0.linkCount
                ]
            }
        ])
        let output = try await requestJSON(
            schemaName: "hidden_tag_normalize",
            schema: hiddenTagNormalizationSchema(),
            instructions: """
            Return JSON only.
            You are standardizing hidden retrieval tags inside one already-grouped semantic bucket.
            Only merge tags when their meaning is fully or nearly identical.
            Do not merge broader/narrower tags, cause/effect tags, adjacent-but-different tags, or tags that simply co-occur.
            Every raw tag must receive one canonical_name.
            If a tag has no true synonym in the group, keep a canonical_name very close to the raw name.
            canonical_name must be a short noun or noun phrase, not a sentence.
            """,
            userInput: userInput
        )
        guard let data = output.data(using: .utf8) else {
            throw AIServiceError.invalidResponse
        }
        let result = try JSONDecoder().decode(HiddenTagNormalizationMap.self, from: data)
        return result.mappings
    }

    func transcribeAudio(fileURL: URL, locale: String?) async throws -> String {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw AIServiceError.invalidResponse
        }

        let transcript = try await transcribeWithAudioAPI(fileURL: fileURL, locale: locale)
        let trimmed = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw AIServiceError.emptyResponse
        }
        return trimmed
    }

    private func requestJSON(
        schemaName: String,
        schema: [String: Any],
        instructions: String,
        userInput: String
    ) async throws -> String {
        let startTime = Date()
        let requestBody = try makeRequestBody(
            schemaName: schemaName,
            schema: schema,
            instructions: instructions,
            userInput: userInput
        )

        let url = URL(string: "https://api.openai.com/v1/responses")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = requestBody

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            recordDebugEntry(
                operation: schemaName,
                status: "invalid response",
                startTime: startTime,
                requestBody: requestBody,
                responseBody: data,
                errorMessage: nil
            )
            throw AIServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            recordDebugEntry(
                operation: schemaName,
                status: "http \(httpResponse.statusCode)",
                startTime: startTime,
                requestBody: requestBody,
                responseBody: data,
                errorMessage: nil
            )
            throw AIServiceError.httpStatus(httpResponse.statusCode)
        }

        let output = try parseOutputText(from: data)
        guard !output.isEmpty else {
            recordDebugEntry(
                operation: schemaName,
                status: "empty response",
                startTime: startTime,
                requestBody: requestBody,
                responseBody: data,
                errorMessage: nil
            )
            throw AIServiceError.emptyResponse
        }

        recordDebugEntry(
            operation: schemaName,
            status: "success",
            startTime: startTime,
            requestBody: requestBody,
            responseBody: data,
            errorMessage: nil
        )

        return output
    }

    private func transcribeWithAudioAPI(fileURL: URL, locale: String?) async throws -> String {
        let audioData = try Data(contentsOf: fileURL)
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/audio/transcriptions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let languageCode = locale?
            .split(separator: "-")
            .first
            .map(String.init)
            .map { $0.lowercased() }

        var body = Data()
        body.appendMultipartField(name: "model", value: OpenAIConfig.transcriptionModel, boundary: boundary)
        if let languageCode, !languageCode.isEmpty {
            body.appendMultipartField(name: "language", value: languageCode, boundary: boundary)
        }
        body.appendMultipartFile(
            name: "file",
            filename: fileURL.lastPathComponent,
            mimeType: mimeType(for: fileURL),
            data: audioData,
            boundary: boundary
        )
        body.appendString("--\(boundary)--\r\n")

        let (data, response) = try await session.upload(for: request, from: body)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw AIServiceError.httpStatus(httpResponse.statusCode)
        }

        let payload = try JSONDecoder().decode(AudioTranscriptionResponse.self, from: data)
        return payload.text
    }

    private func mimeType(for fileURL: URL) -> String {
        switch fileURL.pathExtension.lowercased() {
        case "m4a":
            return "audio/mp4"
        case "wav":
            return "audio/wav"
        case "mp3":
            return "audio/mpeg"
        default:
            return "application/octet-stream"
        }
    }

    private func recordDebugEntry(
        operation: String,
        status: String,
        startTime: Date,
        requestBody: Data,
        responseBody: Data,
        errorMessage: String?
    ) {
        let durationMs = Int(Date().timeIntervalSince(startTime) * 1000)
        let requestText = AIDebugRedactor.redact(String(data: requestBody, encoding: .utf8) ?? "")
        let responseText = AIDebugRedactor.redact(String(data: responseBody, encoding: .utf8) ?? "")
        AIDebugStore.shared.record(
            AIDebugEntry(
                id: UUID(),
                timestamp: Date(),
                operation: operation,
                model: OpenAIConfig.model,
                status: status,
                durationMs: durationMs,
                requestBody: requestText,
                responseBody: responseText,
                errorMessage: errorMessage
            )
        )
    }

    private func makeRequestBody(
        schemaName: String,
        schema: [String: Any],
        instructions: String,
        userInput: String
    ) throws -> Data {
        let body: [String: Any] = [
            "model": OpenAIConfig.model,
            "instructions": instructions,
            "input": [
                ["role": "user", "content": userInput]
            ],
            "text": [
                "format": [
                    "type": "json_schema",
                    "name": schemaName,
                    "schema": schema,
                    "strict": true
                ]
            ]
        ]

        return try JSONSerialization.data(withJSONObject: body)
    }

    private func parseOutputText(from data: Data) throws -> String {
        let object = try JSONSerialization.jsonObject(with: data)
        guard let dictionary = object as? [String: Any] else {
            throw AIServiceError.invalidResponse
        }

        if let outputText = dictionary["output_text"] as? String {
            return outputText
        }

        if let outputItems = dictionary["output"] as? [[String: Any]] {
            for item in outputItems {
                if let contents = item["content"] as? [[String: Any]] {
                    for content in contents {
                        if let text = content["text"] as? String {
                            return text
                        }
                    }
                }
            }
        }

        return ""
    }

    private func jsonString(from payload: [String: Any]) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys]),
              let text = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return text
    }

    private func focusedEvidenceJSONString(from bundle: FocusedEvidenceBundle, followupQuestion: String?) -> String {
        let evidenceGroupsPayload: [[String: Any]] = bundle.evidenceGroups.map { group in
            let unitsPayload: [[String: Any]] = group.units.map { unit in
                [
                    "summary": unit.summary,
                    "context_attributes": unit.contextAttributes.map { ["name": $0.name, "value": $0.value] },
                    "behavioral_chain": unit.behavioralChain,
                    "result_or_state": unit.resultOrState,
                    "system_signals": systemSignalsPayload(from: unit.systemSignals)
                ]
            }
            return [
                "title": group.title,
                "rationale": group.rationale,
                "units": unitsPayload
            ]
        }

        let payload: [String: Any] = [
            "leading_question": bundle.leadingQuestion,
            "top_signals": bundle.topSignals,
            "comparison_windows": bundle.comparisonWindows,
            "evidence_groups": evidenceGroupsPayload,
            "followup_question": followupQuestion ?? ""
        ]
        return jsonString(from: payload)
    }

    private func narrativeMaterialJSONString(from material: NarrativeMaterial) -> String {
        let representativeUnitsPayload: [[String: Any]] = material.representativeUnits.map { unit in
            [
                "summary": unit.summary,
                "context_attributes": unit.contextAttributes.map { ["name": $0.name, "value": $0.value] },
                "behavioral_chain": unit.behavioralChain,
                "result_or_state": unit.resultOrState,
                "visible_tags": unit.visibleTags,
                "hidden_tags": unit.hiddenTags,
                "tag_hints": unit.tagHints,
                "system_signals": systemSignalsPayload(from: unit.systemSignals)
            ]
        }
        let sectionsPayload: [[String: Any]] = material.sections.map { section in
            [
                "title": section.title,
                "bullets": section.bullets
            ]
        }

        let payload: [String: Any] = [
            "primary_themes": material.primaryThemes,
            "change_signals": material.changeSignals,
            "repeated_patterns": material.repeatedPatterns,
            "turning_points": material.turningPoints,
            "representative_units": representativeUnitsPayload,
            "sections": sectionsPayload
        ]
        return jsonString(from: payload)
    }

    private func systemSignalsPayload(from signals: [SystemSignal]) -> [[String: String]] {
        signals.map {
            [
                "type": $0.kind.rawValue,
                "value": $0.value,
                "display_name": $0.displayName
            ]
        }
    }

    private func quickAckSchema() -> [String: Any] {
        [
            "type": "object",
            "properties": [
                "ack_title": ["type": "string"],
                "ack_detail": ["type": "string"]
            ],
            "required": ["ack_title", "ack_detail"],
            "additionalProperties": false
        ]
    }

    private func assistArchiveSchema() -> [String: Any] {
        [
            "type": "object",
            "properties": [
                "reply": ["type": "string"],
                "title": ["type": "string"],
                "context": ["type": "string"],
                "key_points": [
                    "type": "array",
                    "items": ["type": "string"]
                ],
                "next_steps": [
                    "type": "array",
                    "items": ["type": "string"]
                ],
                "record_units": [
                    "type": "array",
                    "items": [
                        "type": "object",
                        "properties": [
                            "title": ["type": "string"],
                            "summary": ["type": "string"],
                            "key_points": [
                                "type": "array",
                                "items": ["type": "string"]
                            ],
                            "next_steps": [
                                "type": "array",
                                "items": ["type": "string"]
                            ]
                        ],
                        "required": ["title", "summary", "key_points", "next_steps"],
                        "additionalProperties": false
                    ]
                ]
            ],
            "required": ["reply", "title", "context", "key_points", "next_steps", "record_units"],
            "additionalProperties": false
        ]
    }

    private func chatReplySchema() -> [String: Any] {
        [
            "type": "object",
            "properties": [
                "reply": ["type": "string"]
            ],
            "required": ["reply"],
            "additionalProperties": false
        ]
    }

    private func cleanTranscriptSchema() -> [String: Any] {
        [
            "type": "object",
            "properties": [
                "clean_text": ["type": "string"],
                "change_level": ["type": "string", "enum": ["light", "medium"]],
                "removed_fillers": [
                    "type": "array",
                    "items": ["type": "string"]
                ]
            ],
            "required": ["clean_text", "change_level", "removed_fillers"],
            "additionalProperties": false
        ]
    }

    private func atomizeSchema() -> [String: Any] {
        [
            "type": "object",
            "properties": [
                "semantic_chunks": [
                    "type": "array",
                    "items": [
                        "type": "object",
                        "properties": [
                            "text": ["type": "string"],
                            "kind": ["type": "string"],
                            "sequence_index": ["type": ["integer", "null"]]
                        ],
                        "required": ["text", "kind", "sequence_index"],
                        "additionalProperties": false
                    ]
                ],
                "record_units": [
                    "type": "array",
                    "items": [
                        "type": "object",
                        "properties": [
                            "summary": ["type": "string"],
                            "context_attributes": [
                                "type": "array",
                                "items": [
                                    "type": "object",
                                    "properties": [
                                        "name": ["type": "string"],
                                        "value": ["type": "string"]
                                    ],
                                    "required": ["name", "value"],
                                    "additionalProperties": false
                                ]
                            ],
                            "behavioral_chain": [
                                "type": "array",
                                "items": ["type": "string"]
                            ],
                            "result_or_state": [
                                "type": "array",
                                "items": ["type": "string"]
                            ],
                            "tag_hints": [
                                "type": "array",
                                "items": ["type": "string"]
                            ],
                            "confidence": ["type": ["number", "null"]],
                            "start_char": ["type": ["integer", "null"]],
                            "end_char": ["type": ["integer", "null"]]
                        ],
                        "required": ["summary", "context_attributes", "behavioral_chain", "result_or_state", "tag_hints", "confidence", "start_char", "end_char"],
                        "additionalProperties": false
                    ]
                ],
                "atomize_version": ["type": ["string", "null"]]
            ],
            "required": ["semantic_chunks", "record_units", "atomize_version"],
            "additionalProperties": false
        ]
    }

    private func tagSuggestionSchema() -> [String: Any] {
        let allowedTagTypes = TagType.allCases.map(\.rawValue)
        let tagProperties: [String: Any] = [
            "tag_type": ["type": "string", "enum": allowedTagTypes],
            "name": ["type": "string"],
            "score": ["type": ["number", "null"]]
        ]
        let suggestionItem: [String: Any] = [
            "type": "object",
            "properties": tagProperties,
            "required": ["tag_type", "name", "score"],
            "additionalProperties": false
        ]
        return [
            "type": "object",
            "properties": [
                "suggestions": [
                    "type": "array",
                    "items": suggestionItem
                ],
                "hidden_suggestions": [
                    "type": "array",
                    "items": suggestionItem
                ]
            ],
            "required": ["suggestions", "hidden_suggestions"],
            "additionalProperties": false
        ]
    }

    private func hiddenTagClusterSchema() -> [String: Any] {
        let bucketNames = HiddenTagBucket.allCases.map(\.rawValue)
        return [
            "type": "object",
            "properties": [
                "groups": [
                    "type": "array",
                    "items": [
                        "type": "object",
                        "properties": [
                            "bucket": ["type": "string", "enum": bucketNames],
                            "title": ["type": "string"],
                            "member_ids": ["type": "array", "items": ["type": "string"]]
                        ],
                        "required": ["bucket", "title", "member_ids"],
                        "additionalProperties": false
                    ]
                ]
            ],
            "required": ["groups"],
            "additionalProperties": false
        ]
    }

    private func hiddenTagNormalizationSchema() -> [String: Any] {
        let bucketNames = HiddenTagBucket.allCases.map(\.rawValue)
        return [
            "type": "object",
            "properties": [
                "updated_at": ["type": ["string", "null"]],
                "mappings": [
                    "type": "array",
                    "items": [
                        "type": "object",
                        "properties": [
                            "raw_tag_id": ["type": "string"],
                            "raw_name": ["type": "string"],
                            "raw_type": ["type": "string"],
                            "bucket": ["type": "string", "enum": bucketNames],
                            "canonical_name": ["type": "string"],
                            "confidence": ["type": ["number", "null"]],
                            "reason": ["type": ["string", "null"]]
                        ],
                        "required": ["raw_tag_id", "raw_name", "raw_type", "bucket", "canonical_name", "confidence", "reason"],
                        "additionalProperties": false
                    ]
                ]
            ],
            "required": ["updated_at", "mappings"],
            "additionalProperties": false
        ]
    }
}

private struct QuickAckPayload: Decodable {
    let ackTitle: String
    let ackDetail: String

    private enum CodingKeys: String, CodingKey {
        case ackTitle = "ack_title"
        case ackDetail = "ack_detail"
    }
}

private struct CleanTranscriptPayload: Decodable {
    let cleanText: String
    let changeLevel: String
    let removedFillers: [String]

    private enum CodingKeys: String, CodingKey {
        case cleanText = "clean_text"
        case changeLevel = "change_level"
        case removedFillers = "removed_fillers"
    }
}

final class BackendAIService: AIService {
    private let baseURL: URL
    private let token: String?
    private let session: URLSession

    init(baseURL: URL, token: String?, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.token = token
        self.session = session
    }

    func quickAck(for capture: CaptureItem) async throws -> QuickAckResult {
        let requestBody = QuickAckRequest(
            captureID: capture.id.uuidString,
            cleanText: capture.cleanText ?? capture.rawText,
            rawText: capture.rawText,
            personaProfile: "stable_warm"
        )

        let response: QuickAckResponse = try await post(
            path: "/v1/quick/ack",
            body: requestBody
        )

        return QuickAckResult(ackTitle: response.ackTitle, ackDetail: response.ackDetail)
    }

    func cleanTranscript(text: String, forceAI: Bool) async throws -> CleanDefillerResult {
        let ruleResult = CleanDefiller.clean(text)
        let requestBody = CleanTranscriptRequest(
            rawText: text,
            ruleCleanText: ruleResult.cleanText,
            forceAI: forceAI,
            personaProfile: "stable_warm"
        )

        let response: CleanTranscriptResponse = try await post(
            path: "/v1/clean",
            body: requestBody
        )

        let cleanText = response.cleanText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else {
            throw AIServiceError.emptyResponse
        }

        return CleanDefillerResult(
            cleanText: cleanText,
            removedFillers: response.removedFillers,
            rulesetVersion: "ai_clean_v1"
        )
    }

    func chatReply(for capture: CaptureItem, questionText: String) async throws -> String {
        let requestBody = ChatReplyRequest(
            mode: "chat",
            captureID: capture.id.uuidString,
            payload: AssistArchiveRequestPayload(
                questionText: questionText,
                importedTranscriptText: nil,
                contextText: capture.cleanText ?? capture.rawText
            ),
            personaProfile: "stable_warm"
        )

        let response: ChatReplyResponse = try await post(
            path: "/v1/chat",
            body: requestBody
        )

        return response.reply
    }

    func analyzeFocusedEvidence(_ bundle: FocusedEvidenceBundle, followupQuestion: String? = nil) async throws -> String {
        let requestBody = FocusedEvidenceAnalysisRequest(
            leadingQuestion: bundle.leadingQuestion,
            topSignals: bundle.topSignals,
            comparisonWindows: bundle.comparisonWindows,
            followupQuestion: followupQuestion,
            evidenceGroups: bundle.evidenceGroups.map {
                FocusedEvidenceAnalysisGroup(
                    title: $0.title,
                    rationale: $0.rationale,
                    units: $0.units.map {
                        FocusedEvidenceAnalysisUnit(
                            summary: $0.summary,
                            contextAttributes: $0.contextAttributes.map { FocusedEvidenceAnalysisAttribute(name: $0.name, value: $0.value) },
                            behavioralChain: $0.behavioralChain,
                            resultOrState: $0.resultOrState,
                            systemSignals: $0.systemSignals.map { AnalysisSystemSignal(from: $0) }
                        )
                    }
                )
            }
        )

        let response: ChatReplyResponse = try await post(
            path: "/v1/focused-analysis",
            body: requestBody
        )

        return response.reply
    }

    func analyzeNarrativeMaterial(_ material: NarrativeMaterial, periodName: String, followupQuestion: String? = nil) async throws -> String {
        let requestBody = NarrativeAnalysisRequest(
            periodName: periodName,
            followupQuestion: followupQuestion,
            primaryThemes: material.primaryThemes,
            changeSignals: material.changeSignals,
            repeatedPatterns: material.repeatedPatterns,
            turningPoints: material.turningPoints,
            representativeUnits: material.representativeUnits.map {
                FocusedEvidenceAnalysisUnit(
                    summary: $0.summary,
                    contextAttributes: $0.contextAttributes.map { FocusedEvidenceAnalysisAttribute(name: $0.name, value: $0.value) },
                    behavioralChain: $0.behavioralChain,
                    resultOrState: $0.resultOrState,
                    systemSignals: $0.systemSignals.map { AnalysisSystemSignal(from: $0) }
                )
            },
            sections: material.sections.map { NarrativeAnalysisSection(title: $0.title, bullets: $0.bullets) }
        )

        let response: ChatReplyResponse = try await post(
            path: "/v1/review-analysis",
            body: requestBody
        )

        return response.reply
    }

    func assistArchive(for capture: CaptureItem, questionText: String) async throws -> AssistArchivePayload {
        let requestBody = AssistArchiveRequest(
            mode: "assist",
            captureID: capture.id.uuidString,
            payload: AssistArchiveRequestPayload(
                questionText: questionText,
                importedTranscriptText: nil,
                contextText: capture.cleanText ?? capture.rawText
            ),
            constraints: AssistArchiveConstraints(maxTurns: 3, allowClarification: true),
            personaProfile: "stable_warm"
        )

        let response: AssistArchiveResponse = try await post(
            path: "/v1/assist",
            body: requestBody
        )

        return AssistArchivePayload(
            reply: response.reply,
            card: response.archiveCard,
            turnPolicy: response.turnPolicy
        )
    }

    func createDeepTask(_ request: DeepTaskRequest) async throws -> DeepTaskHandle {
        let response: DeepTaskResponse = try await post(
            path: "/v1/tasks",
            body: request
        )

        return DeepTaskHandle(id: response.id)
    }

    func atomize(capture: CaptureItem, tagLibrary: TagLibrary) async throws -> AtomizeResult {
        let requestBody = AtomizeRequest(
            captureID: capture.id.uuidString,
            cleanText: capture.cleanText ?? capture.rawText,
            rawText: capture.rawText,
            language: "zh",
            policy: AtomizePolicy(
                noFormalization: true,
                maxUnits: 4,
                preferRetainableUnits: true
            ),
            existingVisibleTags: tagLibrary.summary
        )

        let response: AtomizeResult = try await post(
            path: "/v1/atomize",
            body: requestBody
        )
        return response
    }

    func suggestTags(atomization: AtomizeResult, tagLibrary: TagLibrary) async throws -> TagSuggestionResult {
        let requestBody = TagSuggestRequest(
            semanticChunks: atomization.semanticChunks.map {
                TagSuggestChunk(text: $0.text, kind: $0.kind, sequenceIndex: $0.sequenceIndex)
            },
            recordUnits: atomization.recordUnits.map {
                TagSuggestRecordUnit(
                    summary: $0.summary,
                    contextAttributes: $0.contextAttributes.map {
                        TagSuggestAttribute(name: $0.name, value: $0.value)
                    },
                    behavioralChain: $0.behavioralChain,
                    resultOrState: $0.resultOrState,
                    tagHints: $0.tagHints
                )
            },
            existingVisibleTags: tagLibrary.summary,
            policy: TagSuggestPolicy(
                maxVisibleSuggestions: 1,
                targetHiddenSuggestions: 4,
                preferExistingVisibleTags: true,
                onlyCreateNewVisibleTagIfNoCloseMatch: true
            ),
            personaProfile: "stable_warm"
        )

        let response: TagSuggestionResult = try await post(
            path: "/v1/tags",
            body: requestBody
        )
        return response
    }

    func clusterHiddenTags(_ tags: [HiddenTagInventoryItem]) async throws -> HiddenTagClusterResult {
        let requestBody = HiddenTagClusterRequest(hiddenTags: tags)
        let response: HiddenTagClusterResult = try await post(
            path: "/v1/hidden-tags/cluster",
            body: requestBody
        )
        return response
    }

    func normalizeHiddenTags(in bucket: HiddenTagBucket, tags: [HiddenTagInventoryItem]) async throws -> [HiddenTagCanonicalMapping] {
        let requestBody = HiddenTagNormalizeRequest(bucket: bucket, hiddenTags: tags)
        let response: HiddenTagNormalizationMap = try await post(
            path: "/v1/hidden-tags/normalize",
            body: requestBody
        )
        return response.mappings
    }

    func transcribeAudio(fileURL: URL, locale: String?) async throws -> String {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw AIServiceError.invalidResponse
        }

        let audioData = try Data(contentsOf: fileURL)
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: baseURL.appendingPathComponent("/v1/transcribe"))
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(appIdentifier(), forHTTPHeaderField: "X-App-Id")
        request.setValue(appVersion(), forHTTPHeaderField: "X-App-Version")
        request.setValue(betaUserIdentifier(), forHTTPHeaderField: "X-User-Id")
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let audioSeconds = estimatedAudioDurationSeconds(for: fileURL)
        request.setValue(String(audioSeconds), forHTTPHeaderField: "X-Audio-Seconds")

        let languageCode = locale?
            .split(separator: "-")
            .first
            .map(String.init)
            .map { $0.lowercased() }

        var body = Data()
        body.appendMultipartField(name: "model", value: OpenAIConfig.transcriptionModel, boundary: boundary)
        if let languageCode, !languageCode.isEmpty {
            body.appendMultipartField(name: "language", value: languageCode, boundary: boundary)
        }
        body.appendMultipartFile(
            name: "file",
            filename: fileURL.lastPathComponent,
            mimeType: mimeType(for: fileURL),
            data: audioData,
            boundary: boundary
        )
        body.appendString("--\(boundary)--\r\n")

        let (data, response) = try await session.upload(for: request, from: body)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw AIServiceError.httpStatus(httpResponse.statusCode)
        }

        let payload = try JSONDecoder().decode(AudioTranscriptionResponse.self, from: data)
        let trimmed = payload.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw AIServiceError.emptyResponse
        }
        return trimmed
    }

    private func post<Response: Decodable, Body: Encodable>(path: String, body: Body) async throws -> Response {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(appIdentifier(), forHTTPHeaderField: "X-App-Id")
        request.setValue(appVersion(), forHTTPHeaderField: "X-App-Version")
        request.setValue(betaUserIdentifier(), forHTTPHeaderField: "X-User-Id")
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw AIServiceError.httpStatus(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw AIServiceError.invalidResponse
        }
    }

    private func betaUserIdentifier() -> String {
        AppRuntimeIdentity.userIdentifier()
    }

    private func estimatedAudioDurationSeconds(for fileURL: URL) -> Int {
        let asset = AVURLAsset(url: fileURL)
        let seconds = CMTimeGetSeconds(asset.duration)
        guard seconds.isFinite, seconds > 0 else { return 1 }
        return max(1, Int(ceil(seconds)))
    }

    private func appIdentifier() -> String {
        Bundle.main.bundleIdentifier ?? "LifeNarrator"
    }

    private func appVersion() -> String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
    }

    private func mimeType(for fileURL: URL) -> String {
        switch fileURL.pathExtension.lowercased() {
        case "m4a":
            return "audio/mp4"
        case "wav":
            return "audio/wav"
        case "mp3":
            return "audio/mpeg"
        default:
            return "application/octet-stream"
        }
    }
}

private struct QuickAckRequest: Encodable {
    let captureID: String
    let cleanText: String
    let rawText: String
    let personaProfile: String

    private enum CodingKeys: String, CodingKey {
        case captureID = "capture_id"
        case cleanText = "clean_text"
        case rawText = "raw_text"
        case personaProfile = "persona_profile"
    }
}

private struct CleanTranscriptRequest: Encodable {
    let rawText: String
    let ruleCleanText: String
    let forceAI: Bool
    let personaProfile: String

    private enum CodingKeys: String, CodingKey {
        case rawText = "raw_text"
        case ruleCleanText = "rule_clean_text"
        case forceAI = "force_ai"
        case personaProfile = "persona_profile"
    }
}

private struct QuickAckResponse: Decodable {
    let ackTitle: String
    let ackDetail: String

    private enum CodingKeys: String, CodingKey {
        case ackTitle = "ack_title"
        case ackDetail = "ack_detail"
    }
}

private struct CleanTranscriptResponse: Decodable {
    let cleanText: String
    let changeLevel: String
    let removedFillers: [String]

    private enum CodingKeys: String, CodingKey {
        case cleanText = "clean_text"
        case changeLevel = "change_level"
        case removedFillers = "removed_fillers"
    }
}

private struct AssistArchiveRequest: Encodable {
    let mode: String
    let captureID: String
    let payload: AssistArchiveRequestPayload
    let constraints: AssistArchiveConstraints
    let personaProfile: String

    private enum CodingKeys: String, CodingKey {
        case mode
        case captureID = "capture_id"
        case payload
        case constraints
        case personaProfile = "persona_profile"
    }
}

private struct AtomizeRequest: Encodable {
    let captureID: String
    let cleanText: String
    let rawText: String
    let language: String
    let policy: AtomizePolicy
    let existingVisibleTags: [String: [String]]

    private enum CodingKeys: String, CodingKey {
        case captureID = "capture_id"
        case cleanText = "clean_text"
        case rawText = "raw_text"
        case language
        case policy
        case existingVisibleTags = "existing_visible_tags"
    }
}

private struct AtomizePolicy: Encodable {
    let noFormalization: Bool
    let maxUnits: Int
    let preferRetainableUnits: Bool

    private enum CodingKeys: String, CodingKey {
        case noFormalization = "no_formalization"
        case maxUnits = "max_units"
        case preferRetainableUnits = "prefer_retainable_units"
    }
}

private struct TagSuggestChunk: Encodable {
    let text: String
    let kind: String
    let sequenceIndex: Int?

    private enum CodingKeys: String, CodingKey {
        case text
        case kind
        case sequenceIndex = "sequence_index"
    }
}

private struct TagSuggestAttribute: Encodable {
    let name: String
    let value: String
}

private struct TagSuggestRecordUnit: Encodable {
    let summary: String
    let contextAttributes: [TagSuggestAttribute]
    let behavioralChain: [String]
    let resultOrState: [String]
    let tagHints: [String]

    private enum CodingKeys: String, CodingKey {
        case summary
        case contextAttributes = "context_attributes"
        case behavioralChain = "behavioral_chain"
        case resultOrState = "result_or_state"
        case tagHints = "tag_hints"
    }
}

private struct TagSuggestPolicy: Encodable {
    let maxVisibleSuggestions: Int
    let targetHiddenSuggestions: Int
    let preferExistingVisibleTags: Bool
    let onlyCreateNewVisibleTagIfNoCloseMatch: Bool

    private enum CodingKeys: String, CodingKey {
        case maxVisibleSuggestions = "max_visible_suggestions"
        case targetHiddenSuggestions = "target_hidden_suggestions"
        case preferExistingVisibleTags = "prefer_existing_visible_tags"
        case onlyCreateNewVisibleTagIfNoCloseMatch = "only_create_new_visible_tag_if_no_close_match"
    }
}

private struct TagSuggestRequest: Encodable {
    let semanticChunks: [TagSuggestChunk]
    let recordUnits: [TagSuggestRecordUnit]
    let existingVisibleTags: [String: [String]]
    let policy: TagSuggestPolicy
    let personaProfile: String

    private enum CodingKeys: String, CodingKey {
        case semanticChunks = "semantic_chunks"
        case recordUnits = "record_units"
        case existingVisibleTags = "existing_visible_tags"
        case policy
        case personaProfile = "persona_profile"
    }
}

private struct HiddenTagClusterRequest: Encodable {
    let hiddenTags: [HiddenTagInventoryItem]

    private enum CodingKeys: String, CodingKey {
        case hiddenTags = "hidden_tags"
    }
}

private struct HiddenTagNormalizeRequest: Encodable {
    let bucket: HiddenTagBucket
    let hiddenTags: [HiddenTagInventoryItem]

    private enum CodingKeys: String, CodingKey {
        case bucket
        case hiddenTags = "hidden_tags"
    }
}

private struct FocusedEvidenceAnalysisAttribute: Encodable {
    let name: String
    let value: String
}

private struct AnalysisSystemSignal: Encodable {
    let type: String
    let value: String
    let displayName: String

    init(from signal: SystemSignal) {
        type = signal.kind.rawValue
        value = signal.value
        displayName = signal.displayName
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case value
        case displayName = "display_name"
    }
}

private struct FocusedEvidenceAnalysisUnit: Encodable {
    let summary: String
    let contextAttributes: [FocusedEvidenceAnalysisAttribute]
    let behavioralChain: [String]
    let resultOrState: [String]
    let systemSignals: [AnalysisSystemSignal]

    private enum CodingKeys: String, CodingKey {
        case summary
        case contextAttributes = "context_attributes"
        case behavioralChain = "behavioral_chain"
        case resultOrState = "result_or_state"
        case systemSignals = "system_signals"
    }
}

private struct FocusedEvidenceAnalysisGroup: Encodable {
    let title: String
    let rationale: String
    let units: [FocusedEvidenceAnalysisUnit]
}

private struct FocusedEvidenceAnalysisRequest: Encodable {
    let leadingQuestion: String
    let topSignals: [String]
    let comparisonWindows: [String]
    let followupQuestion: String?
    let evidenceGroups: [FocusedEvidenceAnalysisGroup]

    private enum CodingKeys: String, CodingKey {
        case leadingQuestion = "leading_question"
        case topSignals = "top_signals"
        case comparisonWindows = "comparison_windows"
        case followupQuestion = "followup_question"
        case evidenceGroups = "evidence_groups"
    }
}

private struct NarrativeAnalysisSection: Encodable {
    let title: String
    let bullets: [String]
}

private struct NarrativeAnalysisRequest: Encodable {
    let periodName: String
    let followupQuestion: String?
    let primaryThemes: [String]
    let changeSignals: [String]
    let repeatedPatterns: [String]
    let turningPoints: [String]
    let representativeUnits: [FocusedEvidenceAnalysisUnit]
    let sections: [NarrativeAnalysisSection]

    private enum CodingKeys: String, CodingKey {
        case periodName = "period_name"
        case followupQuestion = "followup_question"
        case primaryThemes = "primary_themes"
        case changeSignals = "change_signals"
        case repeatedPatterns = "repeated_patterns"
        case turningPoints = "turning_points"
        case representativeUnits = "representative_units"
        case sections
    }
}

private struct ChatReplyRequest: Encodable {
    let mode: String
    let captureID: String
    let payload: AssistArchiveRequestPayload
    let personaProfile: String

    private enum CodingKeys: String, CodingKey {
        case mode
        case captureID = "capture_id"
        case payload
        case personaProfile = "persona_profile"
    }
}

private struct AssistArchiveRequestPayload: Encodable {
    let questionText: String
    let importedTranscriptText: String?
    let contextText: String?

    private enum CodingKeys: String, CodingKey {
        case questionText = "question_text"
        case importedTranscriptText = "imported_transcript_text"
        case contextText = "context_text"
    }
}

private struct AssistArchiveConstraints: Encodable {
    let maxTurns: Int
    let allowClarification: Bool

    private enum CodingKeys: String, CodingKey {
        case maxTurns = "max_turns"
        case allowClarification = "allow_clarification"
    }
}

private struct AssistArchiveResponse: Decodable {
    let reply: String
    let archiveCard: AssistArchiveCard
    let turnPolicy: AssistTurnPolicy

    private enum CodingKeys: String, CodingKey {
        case reply
        case archiveCard = "archive_card"
        case turnPolicy = "turn_policy"
    }
}

private struct ChatReplyResponse: Decodable {
    let reply: String
}

private struct ChatReplyPayload: Decodable {
    let reply: String
}

private struct AssistArchiveDraftPayload: Decodable {
    let reply: String
    let title: String
    let context: String
    let keyPoints: [String]
    let nextSteps: [String]
    let recordUnits: [AssistRecordUnit]

    private enum CodingKeys: String, CodingKey {
        case reply
        case title
        case context
        case keyPoints = "key_points"
        case nextSteps = "next_steps"
        case recordUnits = "record_units"
    }
}

private struct DeepTaskResponse: Decodable {
    let id: String
}

private struct AudioTranscriptionResponse: Decodable {
    let text: String
}

private extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }

    mutating func appendMultipartField(name: String, value: String, boundary: String) {
        appendString("--\(boundary)\r\n")
        appendString("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
        appendString("\(value)\r\n")
    }

    mutating func appendMultipartFile(
        name: String,
        filename: String,
        mimeType: String,
        data: Data,
        boundary: String
    ) {
        appendString("--\(boundary)\r\n")
        appendString("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n")
        appendString("Content-Type: \(mimeType)\r\n\r\n")
        append(data)
        appendString("\r\n")
    }
}
