import Foundation

struct CleanDefillerResult {
    let cleanText: String
    let removedFillers: [String]
    let rulesetVersion: String
}

struct CleanDefillerComplexity {
    let shouldUseAI: Bool
    let reasons: [String]
}

enum CleanDefiller {
    static let rulesetVersion = "clean_v1"

    static func clean(_ text: String) -> CleanDefillerResult {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return CleanDefillerResult(cleanText: "", removedFillers: [], rulesetVersion: rulesetVersion)
        }

        var working = normalizeWhitespace(trimmed)
        var removed: [String] = []

        let fillerPatterns: [(pattern: String, label: String)] = [
            (#"(?:(?<=^)|(?<=[\s，。！？,.]))(?:嗯+|呃+|额+|啊+|唉+)(?=$|[\s，。！？,.])"#, "语气词"),
            (#"(?:(?<=^)|(?<=[\s，。！？,.]))(?:你知道吗)(?=$|[\s，。！？,.])"#, "你知道吗"),
            (#"(?:(?<=^)|(?<=[\s，。！？,.]))(?:那个)(?=$|[\s，。！？,.])"#, "那个")
        ]

        for rule in fillerPatterns {
            let matches = matches(of: rule.pattern, in: working)
            if !matches.isEmpty {
                removed.append(contentsOf: Array(repeating: rule.label, count: matches.count))
                working = replacingMatches(of: rule.pattern, in: working, with: " ")
            }
        }

        working = collapseChineseStutters(in: working)
        working = collapseRepeatedBlocks(in: working)
        working = collapseRepeatedEnglishWords(in: working)
        working = normalizePausePunctuation(in: working)
        working = collapseWhitespaceAroundPunctuation(in: working)
        working = insertTerminalPunctuationIfNeeded(in: working)

        let cleanText = working.trimmingCharacters(in: .whitespacesAndNewlines)
        return CleanDefillerResult(
            cleanText: cleanText.isEmpty ? trimmed : cleanText,
            removedFillers: removed,
            rulesetVersion: rulesetVersion
        )
    }

    static func analyzeComplexity(originalText: String, cleanedText: String? = nil) -> CleanDefillerComplexity {
        let text = normalizeWhitespace(originalText)
        guard !text.isEmpty else {
            return CleanDefillerComplexity(shouldUseAI: false, reasons: [])
        }

        let baseline = cleanedText.map(normalizeWhitespace) ?? clean(text).cleanText
        let fillerCount = fillerMatchCount(in: text)
        let repeatedSequenceCount = repeatedSequenceMatches(in: text)
        let englishWordCount = englishWordMatches(in: text)
        let hasTerminalPunctuation = text.contains { "。！？.!?".contains($0) }
        let differenceRatio = normalizedDifferenceRatio(original: text, cleaned: baseline)
        let stillHasRepetition = repeatedSequenceMatches(in: baseline) > 0

        var reasons: [String] = []
        if text.count >= 35 { reasons.append("length") }
        if fillerCount >= 3 { reasons.append("fillers") }
        if repeatedSequenceCount >= 2 { reasons.append("repetition") }
        if englishWordCount >= 2 { reasons.append("mixed_english") }
        if text.count >= 40 && !hasTerminalPunctuation { reasons.append("long_unpunctuated") }
        if differenceRatio >= 0.15 && stillHasRepetition { reasons.append("rule_cleaner_not_enough") }

        let strongTrigger =
            (englishWordCount >= 2 && repeatedSequenceCount >= 2) ||
            (text.count >= 60 && !hasTerminalPunctuation)
        let shouldUseAI = strongTrigger || reasons.count >= 2
        return CleanDefillerComplexity(shouldUseAI: shouldUseAI, reasons: reasons)
    }

    private static func normalizeWhitespace(_ text: String) -> String {
        text
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func collapseChineseStutters(in text: String) -> String {
        replacingMatches(of: #"([我你他她它这那])\1+"#, in: text, with: "$1")
    }

    private static func collapseRepeatedEnglishWords(in text: String) -> String {
        replacingMatches(of: #"(?i)\b([a-z]+)(?:\s+\1\b)+"#, in: text, with: "$1")
    }

    private static func collapseRepeatedBlocks(in text: String) -> String {
        var result = text
        var changed = true

        while changed {
            changed = false
            let scalars = Array(result)
            guard scalars.count >= 4 else { break }

            outer: for start in scalars.indices {
                for blockLength in stride(from: 6, through: 2, by: -1) {
                    let end = start + blockLength * 2
                    guard end <= scalars.count else { continue }
                    let firstBlock = String(scalars[start ..< start + blockLength])
                    guard !containsPunctuation(firstBlock) else { continue }

                    var cursor = start + blockLength
                    var repeatCount = 1
                    while cursor + blockLength <= scalars.count,
                          String(scalars[cursor ..< cursor + blockLength]) == firstBlock {
                        repeatCount += 1
                        cursor += blockLength
                    }

                    guard repeatCount >= 2 else { continue }

                    let prefix = String(scalars[..<start])
                    let suffix = String(scalars[cursor...])
                    result = prefix + firstBlock + suffix
                    changed = true
                    break outer
                }
            }
        }

        return result
    }

    private static func normalizePausePunctuation(in text: String) -> String {
        var result = text
        result = replacingMatches(of: #"[.。…]{2,}"#, in: result, with: "，")
        result = replacingMatches(of: #"[，,]{2,}"#, in: result, with: "，")
        result = replacingMatches(of: #"\s*([，。！？])\s*"#, in: result, with: "$1")
        result = replacingMatches(of: #"([，。！？]){2,}"#, in: result, with: "$1")
        return result
    }

    private static func collapseWhitespaceAroundPunctuation(in text: String) -> String {
        var result = text
        result = replacingMatches(of: #"\s+([，。！？,.])"#, in: result, with: "$1")
        result = replacingMatches(of: #"([，。！？])([^\s，。！？])"#, in: result, with: "$1$2")
        result = replacingMatches(of: #"\s{2,}"#, in: result, with: " ")
        return result
    }

    private static func insertTerminalPunctuationIfNeeded(in text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let last = trimmed.last else { return trimmed }
        if "。！？.!?".contains(last) {
            return trimmed
        }
        return trimmed + "。"
    }

    private static func matches(of pattern: String, in text: String) -> [NSTextCheckingResult] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return [] }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.matches(in: text, options: [], range: range)
    }

    private static func fillerMatchCount(in text: String) -> Int {
        let fillerPatterns = [
            #"(?:(?<=^)|(?<=[\s，。！？,.]))(?:嗯+|呃+|额+|啊+|唉+)(?=$|[\s，。！？,.])"#,
            #"(?:(?<=^)|(?<=[\s，。！？,.]))(?:你知道吗)(?=$|[\s，。！？,.])"#,
            #"(?:(?<=^)|(?<=[\s，。！？,.]))(?:那个)(?=$|[\s，。！？,.])"#,
            #"(?:(?<=^)|(?<=[\s，。！？,.]))(?:就是)(?=$|[\s，。！？,.])"#,
            #"(?:(?<=^)|(?<=[\s，。！？,.]))(?:然后)+(?=$|[\s，。！？,.])"#
        ]
        return fillerPatterns.reduce(0) { $0 + matches(of: $1, in: text).count }
    }

    private static func repeatedSequenceMatches(in text: String) -> Int {
        let patterns = [
            #"([我你他她它这那])\1+"#,
            #"(?i)\b([a-z]+)(?:\s+\1\b)+"#,
            #"(.{1,6})\1+"#
        ]
        return patterns.reduce(0) { $0 + matches(of: $1, in: text).count }
    }

    private static func englishWordMatches(in text: String) -> Int {
        matches(of: #"(?i)\b[a-z]{2,}\b"#, in: text).count
    }

    private static func normalizedDifferenceRatio(original: String, cleaned: String) -> Double {
        guard !original.isEmpty else { return 0 }
        let delta = abs(original.count - cleaned.count)
        return Double(delta) / Double(max(original.count, 1))
    }

    private static func replacingMatches(of pattern: String, in text: String, with template: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return text }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: template)
    }

    private static func containsPunctuation(_ text: String) -> Bool {
        text.contains { "，。！？,.!?；：、 ".contains($0) }
    }
}
