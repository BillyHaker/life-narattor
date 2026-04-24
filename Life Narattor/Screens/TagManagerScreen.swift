import CoreData
import SwiftUI

struct TagManagerScreen: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var selectedType: TagType = .project
    @State private var tags: [TagEntity] = []
    @State private var showingEditor = false
    @State private var editorMode: TagEditorMode = .create(.project)
    @State private var editorText = ""
    @State private var editorError: String? = nil
    @State private var showingMergePicker = false
    @State private var mergeSource: TagEntity? = nil
    @State private var mergeTarget: TagEntity? = nil
    @State private var showingMergeConfirm = false
    @State private var pendingDelete: TagEntity? = nil

    var body: some View {
        VStack(spacing: 16) {
            Picker("标签类型", selection: $selectedType) {
                ForEach(TagType.allCases) { tagType in
                    Text(tagType.title).tag(tagType)
                }
            }
            .pickerStyle(.menu)
            .padding(.horizontal, 16)

            if tags.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(tags, id: \.id) { tag in
                        TagRow(tag: tag, onRename: {
                            editorMode = .rename(tag)
                            editorText = tag.name
                            editorError = nil
                            showingEditor = true
                        }, onMerge: {
                            mergeSource = tag
                            mergeTarget = nil
                            showingMergePicker = true
                        }, onDelete: {
                            pendingDelete = tag
                        })
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("管理标签")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("新建标签") {
                    editorMode = .create(selectedType)
                    editorText = ""
                    editorError = nil
                    showingEditor = true
                }
            }
        }
        .confirmationDialog("删除标签", isPresented: Binding(get: {
            pendingDelete != nil
        }, set: { isPresented in
            if !isPresented {
                pendingDelete = nil
            }
        })) {
            Button("删除", role: .destructive) {
                if let tag = pendingDelete {
                    deleteTag(tag)
                }
                pendingDelete = nil
            }
            Button("取消", role: .cancel) {
                pendingDelete = nil
            }
        } message: {
            Text("删除后将不会出现在标签选择器中，但历史记录仍保留。")
        }
        .sheet(isPresented: $showingEditor) {
            NavigationStack {
                TagEditorView(
                    title: editorMode.title,
                    placeholder: "请输入标签名",
                    text: $editorText,
                    errorText: editorError,
                    onCancel: { showingEditor = false },
                    onSave: {
                        handleEditorSave()
                    }
                )
            }
        }
        .sheet(isPresented: $showingMergePicker) {
            NavigationStack {
                MergeTagPickerView(
                    source: mergeSource,
                    tags: tags,
                    selectedTarget: $mergeTarget,
                    onCancel: { showingMergePicker = false },
                    onConfirm: {
                        showingMergeConfirm = true
                    }
                )
            }
        }
        .confirmationDialog("合并标签", isPresented: $showingMergeConfirm, titleVisibility: .visible) {
            Button("确认合并", role: .destructive) {
                if let source = mergeSource, let target = mergeTarget {
                    mergeTag(source: source, target: target)
                }
                showingMergePicker = false
                showingMergeConfirm = false
            }
            Button("取消", role: .cancel) {
                showingMergeConfirm = false
            }
        } message: {
            if let source = mergeSource, let target = mergeTarget {
                Text("将“\(source.name)”合并到“\(target.name)”？该操作会影响历史记录。")
            }
        }
        .onAppear {
            reloadTags()
        }
        .onChange(of: selectedType) { _, _ in
            reloadTags()
        }
    }

    private var emptyStateView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("这个分类还没有标签。")
                .font(.body)
                .foregroundStyle(.secondary)
            Button("新建一个") {
                editorMode = .create(selectedType)
                editorText = ""
                editorError = nil
                showingEditor = true
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal, 16)
    }

    private func reloadTags() {
        let request = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        request.predicate = NSPredicate(format: "type == %@ AND isUserVisible == YES", selectedType.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        tags = (try? context.fetch(request)) ?? []
    }

    private func handleEditorSave() {
        let trimmed = editorText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            editorError = "请输入标签名"
            return
        }

        switch editorMode {
        case .create(let type):
            if hasDuplicate(name: trimmed, type: type) {
                editorError = "已存在同名标签"
                return
            }
            let tag = TagEntity(context: context)
            tag.id = UUID()
            tag.name = trimmed
            tag.type = type.rawValue
            tag.isUserVisible = true
            tag.isCommon = false
            tag.createdAt = Date()
            saveContext()
        case .rename(let tag):
            if hasDuplicate(name: trimmed, type: selectedType, excluding: tag.id) {
                editorError = "已存在同名标签"
                return
            }
            tag.name = trimmed
            saveContext()
        }

        editorError = nil
        showingEditor = false
        reloadTags()
    }

    private func hasDuplicate(name: String, type: TagType, excluding id: UUID? = nil) -> Bool {
        let request = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        var predicates: [NSPredicate] = [
            NSPredicate(format: "type == %@", type.rawValue),
            NSPredicate(format: "name == %@", name),
            NSPredicate(format: "isUserVisible == YES")
        ]

        if let id {
            predicates.append(NSPredicate(format: "id != %@", id as CVarArg))
        }

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        return (try? context.count(for: request)) ?? 0 > 0
    }

    private func deleteTag(_ tag: TagEntity) {
        tag.isUserVisible = false
        saveContext()
        reloadTags()
    }

    private func mergeTag(source: TagEntity, target: TagEntity) {
        guard source.id != target.id else { return }
        let request = NSFetchRequest<AtomTagEntity>(entityName: "AtomTagEntity")
        request.predicate = NSPredicate(format: "tagID == %@", source.id as CVarArg)

        if let links = try? context.fetch(request) {
            for link in links {
                link.tagID = target.id
            }
        }

        source.isUserVisible = false
        saveContext()
        reloadTags()
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }
}

private enum TagEditorMode {
    case create(TagType)
    case rename(TagEntity)

    var title: String {
        switch self {
        case .create:
            return "新建标签"
        case .rename:
            return "重命名标签"
        }
    }
}

private struct TagRow: View {
    let tag: TagEntity
    let onRename: () -> Void
    let onMerge: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(tag.name)
                    .font(.body)
                Text(TagType(rawValue: tag.type)?.title ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Menu {
                Button("重命名", action: onRename)
                Button("合并到…", action: onMerge)
                Button("删除", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

private struct TagEditorView: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let errorText: String?
    let onCancel: () -> Void
    let onSave: () -> Void

    var body: some View {
        Form {
            Section(title) {
                TextField(placeholder, text: $text)
                if let errorText {
                    Text(errorText)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("取消", action: onCancel)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("保存", action: onSave)
            }
        }
    }
}

private struct MergeTagPickerView: View {
    let source: TagEntity?
    let tags: [TagEntity]
    @Binding var selectedTarget: TagEntity?
    let onCancel: () -> Void
    let onConfirm: () -> Void

    private var availableTargets: [TagEntity] {
        guard let source else { return [] }
        return tags.filter { $0.id != source.id }
    }

    var body: some View {
        List {
            if let source {
                mergeSection(for: source)
            }
        }
        .navigationTitle("合并标签")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("取消", action: onCancel)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("确认", action: onConfirm)
                    .disabled(selectedTarget == nil)
            }
        }
    }

    @ViewBuilder
    private func mergeSection(for source: TagEntity) -> some View {
        Section("合并到") {
            ForEach(availableTargets, id: \.id) { tag in
                MergeTargetRow(
                    name: tag.name,
                    isSelected: selectedTarget?.id == tag.id
                ) {
                    selectedTarget = tag
                }
            }
        }
    }
}

private struct MergeTargetRow: View {
    let name: String
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        HStack {
            Text(name)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundStyle(Color.accentColor)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
    }
}
