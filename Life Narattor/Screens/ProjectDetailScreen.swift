import CoreData
import SwiftUI

struct ProjectDetailScreen: View {
    let project: ProjectItem
    @Environment(\.managedObjectContext) private var context
    @State private var selectedTab: ProjectDetailTab = .timeline
    @State private var selectedAtom: AtomItem? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView

            Picker("标签", selection: $selectedTab) {
                ForEach(ProjectDetailTab.allCases) { tab in
                    Text(tab.title).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    switch selectedTab {
                    case .timeline:
                        ProjectTimelineTab(projectName: project.name, context: context, onSelectAtom: { atom in
                            selectedAtom = atom
                        })
                    case .review:
                        ProjectReviewTab(projectName: project.name, context: context, onSelectAtom: { atom in
                            selectedAtom = atom
                        })
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .padding(.top, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemGroupedBackground))
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedAtom) { atom in
            AtomDetailSheet(atom: atom, context: context, onSaved: {})
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(project.name)
                .font(.title2.weight(.semibold))
            Text(project.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("更新于 \(formattedDate(project.updatedAt))")
                .font(.footnote)
                .foregroundStyle(.secondary)
            NavigationLink {
                SearchScreen(initialQuery: project.name, initialFilter: .project)
            } label: {
                Text("项目")
                    .font(.caption)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
}

private struct ProjectTimelineTab: View {
    let projectName: String
    let context: NSManagedObjectContext
    let onSelectAtom: (AtomItem) -> Void

    @State private var rows: [ProjectAtomRow] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("项目时间线")
                .font(.headline)

            if rows.isEmpty {
                Text("这个项目还没有记录")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(rows) { row in
                    Button {
                        onSelectAtom(row.atom)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(row.atom.content)
                                .font(.body)
                                .foregroundStyle(.primary)
                            Text(ProjectAtomLoader.formattedDate(row.createdAt))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onAppear(perform: loadRows)
    }

    private func loadRows() {
        rows = ProjectAtomLoader(context: context, projectName: projectName).loadRows()
    }
}

private struct ProjectReviewTab: View {
    let projectName: String
    let context: NSManagedObjectContext
    let onSelectAtom: (AtomItem) -> Void

    @State private var narrativeText: String = ""
    @State private var summaryRows: [ProjectAtomRow] = []
    @State private var selectedCommentStyle: CommentStyle = .gentle
    @State private var isSourcesExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("项目叙事")
                .font(.headline)
            Text(narrativeText.isEmpty ? "这个项目还没有记录" : narrativeText)
                .font(.body)
                .foregroundStyle(narrativeText.isEmpty ? .secondary : .primary)

            VStack(alignment: .leading, spacing: 12) {
                Text("AI回应")
                    .font(.headline)

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

            VStack(alignment: .leading, spacing: 12) {
                Text("结构块")
                    .font(.headline)

                structureSection(title: "时间轴", items: timelineItems)
                structureSection(title: "转折点", items: turningPointItems)
                structureSection(title: "卡点", items: blockerItems)
                structureSection(title: "下一步", items: nextStepItems)
            }

            if !summaryRows.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("项目片段")
                        .font(.headline)
                    ForEach(summaryRows.prefix(3)) { row in
                        Text("• \(row.atom.content)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            DisclosureGroup("引用来源", isExpanded: $isSourcesExpanded) {
                if sourceMappings.isEmpty {
                    Text("暂无引用来源")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(sourceMappings) { row in
                            Button {
                                onSelectAtom(row.atom)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(row.sentence)
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                    Text(ProjectAtomLoader.formattedDate(row.createdAt))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .font(.headline)

            Button("生成项目回顾") {}
                .buttonStyle(.bordered)
        }
        .onAppear(perform: loadReview)
    }

    private var timelineItems: [ProjectAtomRow] {
        summaryRows.prefix(4).map { $0 }
    }

    private var turningPointItems: [ProjectAtomRow] {
        let candidates = summaryRows.filter { $0.atom.type == .decision || $0.atom.type == .insight }
        return Array(candidates.prefix(3))
    }

    private var blockerItems: [ProjectAtomRow] {
        let candidates = summaryRows.filter { $0.atom.type == .question }
        return Array(candidates.prefix(3))
    }

    private var nextStepItems: [ProjectAtomRow] {
        let candidates = summaryRows.filter { $0.atom.type == .action }
        return Array(candidates.prefix(3))
    }

    private var narrativeSentences: [String] {
        narrativeText
            .split(separator: "。")
            .map { String($0) }
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .map { $0 + "。" }
    }

    private var sourceMappings: [ProjectNarrativeSourceRow] {
        guard !summaryRows.isEmpty else { return [] }
        let sentences = narrativeSentences
        if sentences.isEmpty {
            return []
        }
        return zip(sentences, summaryRows).map { sentence, row in
            ProjectNarrativeSourceRow(
                id: UUID(),
                sentence: sentence,
                atom: row.atom,
                createdAt: row.createdAt
            )
        }
    }

    private func structureSection(title: String, items: [ProjectAtomRow]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            if items.isEmpty {
                Text("暂无")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(items) { row in
                    Text("• \(row.atom.content)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func loadReview() {
        let rows = ProjectAtomLoader(context: context, projectName: projectName).loadRows()
        summaryRows = rows
        if rows.isEmpty {
            narrativeText = ""
            return
        }
        let top = rows.map { $0.atom.content }.prefix(3).joined(separator: "、")
        narrativeText = "我在这个项目里记录了\(rows.count)条片段，主要是：\(top)。"
    }
}

private struct ProjectAtomRow: Identifiable {
    let id: UUID
    let atom: AtomItem
    let createdAt: Date
}

private struct ProjectNarrativeSourceRow: Identifiable {
    let id: UUID
    let sentence: String
    let atom: AtomItem
    let createdAt: Date
}

private struct ProjectAtomLoader {
    let context: NSManagedObjectContext
    let projectName: String

    func loadRows() -> [ProjectAtomRow] {
        guard let tag = fetchProjectTag() else { return [] }
        let atomEntities = fetchAtoms(tagID: tag.id)
        guard !atomEntities.isEmpty else { return [] }

        let tagMap = fetchTagMap(atomIDs: atomEntities.map { $0.id })
        let captureDates = fetchCaptureDates(captureIDs: atomEntities.map { $0.captureID })

        return atomEntities.map { atom in
            let startChar = atom.startChar >= 0 ? Int(atom.startChar) : nil
            let endChar = atom.endChar >= 0 ? Int(atom.endChar) : nil
            let item = AtomItem(
                id: atom.id,
                captureID: atom.captureID,
                type: AtomType(rawValue: atom.type) ?? .event,
                content: atom.content,
                orderInCapture: Int(atom.orderInCapture),
                isKey: atom.isKey,
                tags: tagMap[atom.id] ?? [],
                startChar: startChar,
                endChar: endChar,
                atomizeVersion: atom.atomizeVersion
            )
            return ProjectAtomRow(
                id: atom.id,
                atom: item,
                createdAt: captureDates[atom.captureID] ?? atom.createdAt
            )
        }
    }

    private func fetchProjectTag() -> TagEntity? {
        let request = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        request.predicate = NSPredicate(format: "type == %@ AND name == %@", TagType.project.rawValue, projectName)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    private func fetchAtoms(tagID: UUID) -> [AtomEntity] {
        let linkRequest = NSFetchRequest<AtomTagEntity>(entityName: "AtomTagEntity")
        linkRequest.predicate = NSPredicate(format: "tagID == %@", tagID as CVarArg)
        let links = (try? context.fetch(linkRequest)) ?? []
        let atomIDs = links.map { $0.atomID }
        guard !atomIDs.isEmpty else { return [] }

        let atomRequest = NSFetchRequest<AtomEntity>(entityName: "AtomEntity")
        atomRequest.predicate = NSPredicate(format: "id IN %@", atomIDs)
        atomRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return (try? context.fetch(atomRequest)) ?? []
    }

    private func fetchTagMap(atomIDs: [UUID]) -> [UUID: [TagItem]] {
        guard !atomIDs.isEmpty else { return [:] }
        let linkRequest = NSFetchRequest<AtomTagEntity>(entityName: "AtomTagEntity")
        linkRequest.predicate = NSPredicate(format: "atomID IN %@", atomIDs)
        let links = (try? context.fetch(linkRequest)) ?? []
        let tagIDs = links.map { $0.tagID }

        let tagRequest = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        tagRequest.predicate = NSPredicate(format: "id IN %@", tagIDs)
        let tags = (try? context.fetch(tagRequest)) ?? []
        let tagMap = Dictionary(uniqueKeysWithValues: tags.map {
            ($0.id, TagItem(
                id: $0.id,
                name: $0.name,
                type: TagType(rawValue: $0.type) ?? .project,
                isCommon: $0.isCommon,
                isSuggested: false,
                isUserVisible: $0.isUserVisible
            ))
        })

        return links.reduce(into: [:]) { result, link in
            guard let tag = tagMap[link.tagID] else { return }
            result[link.atomID, default: []].append(tag)
        }
    }

    private func fetchCaptureDates(captureIDs: [UUID]) -> [UUID: Date] {
        guard !captureIDs.isEmpty else { return [:] }
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(format: "id IN %@", captureIDs)
        let captures = (try? context.fetch(request)) ?? []
        return Dictionary(uniqueKeysWithValues: captures.map { ($0.id, $0.createdAt) })
    }

    static func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 HH:mm"
        return formatter.string(from: date)
    }
}
