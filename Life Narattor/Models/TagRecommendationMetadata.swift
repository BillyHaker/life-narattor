import Foundation

enum TagRecommendability: Int {
    case low = 0
    case normal = 1
    case high = 2
}

enum TagScope: Int {
    case broad = 0
    case specific = 1
}

enum TagStability: Int {
    case low = 0
    case normal = 1
    case high = 2
}

struct TagRecommendationMetadata {
    let recommendability: TagRecommendability
    let scope: TagScope
    let stability: TagStability

    static func forTag(name: String, type: TagType, isUserVisible: Bool) -> TagRecommendationMetadata {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if let seeded = seededMetadata[TagMetadataKey(type: type, name: trimmed)] {
            return seeded
        }

        if !isUserVisible {
            return TagRecommendationMetadata(
                recommendability: .normal,
                scope: .specific,
                stability: .normal
            )
        }

        switch type {
        case .project:
            return TagRecommendationMetadata(
                recommendability: .high,
                scope: .specific,
                stability: .high
            )
        case .habit:
            return TagRecommendationMetadata(
                recommendability: .high,
                scope: .specific,
                stability: .high
            )
        case .theme:
            return TagRecommendationMetadata(
                recommendability: .normal,
                scope: .broad,
                stability: .high
            )
        case .person:
            return TagRecommendationMetadata(
                recommendability: .high,
                scope: .specific,
                stability: .high
            )
        case .goal:
            return TagRecommendationMetadata(
                recommendability: .high,
                scope: .specific,
                stability: .high
            )
        case .context:
            return TagRecommendationMetadata(
                recommendability: .normal,
                scope: .specific,
                stability: .high
            )
        }
    }

    private static let seededMetadata: [TagMetadataKey: TagRecommendationMetadata] = [
        .init(type: .project, name: "Life Narrator"): .init(recommendability: .high, scope: .specific, stability: .high),
        .init(type: .project, name: "英语口语"): .init(recommendability: .high, scope: .specific, stability: .high),
        .init(type: .project, name: "健身计划"): .init(recommendability: .high, scope: .specific, stability: .high),
        .init(type: .project, name: "求职准备"): .init(recommendability: .high, scope: .specific, stability: .high),
        .init(type: .project, name: "内容创作"): .init(recommendability: .high, scope: .specific, stability: .high),

        .init(type: .habit, name: "早起"): .init(recommendability: .high, scope: .specific, stability: .high),
        .init(type: .habit, name: "晨间启动"): .init(recommendability: .high, scope: .specific, stability: .high),
        .init(type: .habit, name: "深度工作"): .init(recommendability: .high, scope: .specific, stability: .high),
        .init(type: .habit, name: "晚间复盘"): .init(recommendability: .high, scope: .specific, stability: .high),
        .init(type: .habit, name: "运动打卡"): .init(recommendability: .high, scope: .specific, stability: .high),
        .init(type: .habit, name: "刷手机"): .init(recommendability: .normal, scope: .specific, stability: .normal),
        .init(type: .habit, name: "拖延"): .init(recommendability: .normal, scope: .specific, stability: .normal),
        .init(type: .habit, name: "规律吃饭"): .init(recommendability: .normal, scope: .specific, stability: .high),

        .init(type: .theme, name: "工作安排"): .init(recommendability: .normal, scope: .broad, stability: .high),
        .init(type: .theme, name: "发音训练"): .init(recommendability: .high, scope: .specific, stability: .high),
        .init(type: .theme, name: "情绪波动"): .init(recommendability: .low, scope: .broad, stability: .normal),
        .init(type: .theme, name: "时间管理"): .init(recommendability: .normal, scope: .broad, stability: .high),
        .init(type: .theme, name: "睡眠"): .init(recommendability: .normal, scope: .specific, stability: .high),
        .init(type: .theme, name: "饮食"): .init(recommendability: .normal, scope: .specific, stability: .high),
        .init(type: .theme, name: "执行力"): .init(recommendability: .normal, scope: .broad, stability: .normal),
        .init(type: .theme, name: "自我怀疑"): .init(recommendability: .low, scope: .broad, stability: .normal),

        .init(type: .person, name: "新老板"): .init(recommendability: .high, scope: .specific, stability: .high),
        .init(type: .person, name: "同事"): .init(recommendability: .normal, scope: .broad, stability: .normal),
        .init(type: .person, name: "家人"): .init(recommendability: .normal, scope: .broad, stability: .high),
        .init(type: .person, name: "朋友"): .init(recommendability: .normal, scope: .broad, stability: .high),

        .init(type: .goal, name: "提升英语表达"): .init(recommendability: .high, scope: .specific, stability: .high),
        .init(type: .goal, name: "建立稳定作息"): .init(recommendability: .high, scope: .specific, stability: .high),
        .init(type: .goal, name: "提高专注力"): .init(recommendability: .high, scope: .specific, stability: .high),
        .init(type: .goal, name: "改善工作状态"): .init(recommendability: .normal, scope: .specific, stability: .high),
        .init(type: .goal, name: "减少拖延"): .init(recommendability: .high, scope: .specific, stability: .high),

        .init(type: .context, name: "公司"): .init(recommendability: .normal, scope: .specific, stability: .high),
        .init(type: .context, name: "家里"): .init(recommendability: .normal, scope: .specific, stability: .high),
        .init(type: .context, name: "通勤"): .init(recommendability: .normal, scope: .specific, stability: .high),
        .init(type: .context, name: "晨间"): .init(recommendability: .high, scope: .specific, stability: .high),
        .init(type: .context, name: "晚上"): .init(recommendability: .normal, scope: .specific, stability: .high),
        .init(type: .context, name: "周末"): .init(recommendability: .normal, scope: .specific, stability: .high)
    ]
}

private struct TagMetadataKey: Hashable {
    let type: TagType
    let name: String
}
