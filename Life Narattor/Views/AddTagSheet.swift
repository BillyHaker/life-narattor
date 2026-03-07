import CoreData
import SwiftUI

struct AddTagSheet: View {
    let context: NSManagedObjectContext
    let atomID: UUID?
    let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: TagType = .project
    @State private var newTagName: String = ""

    private var store: AtomTagStore { AtomTagStore(context: context) }

    var body: some View {
        NavigationStack {
            List {
                Picker("类型", selection: $selectedType) {
                    ForEach(TagType.allCases) { type in
                        Text(type.title).tag(type)
                    }
                }
                .pickerStyle(.segmented)

                if atomID == nil {
                    Text("请选择一个原子")
                        .foregroundStyle(.secondary)
                } else {
                    Section("常用标签") {
                        let tags = store.fetchTags(type: selectedType).filter { $0.isCommon }
                        if tags.isEmpty {
                            Text("暂无常用标签")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(tags) { tag in
                                tagRow(tag: tag)
                            }
                        }
                    }

                    Section("全部") {
                        let tags = store.fetchTags(type: selectedType)
                        if tags.isEmpty {
                            Text("暂无标签")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(tags) { tag in
                                tagRow(tag: tag)
                            }
                        }
                    }

                    Section("新建") {
                        HStack {
                            TextField("新标签名称", text: $newTagName)
                            Button("创建") {
                                guard let atomID else { return }
                                let tag = store.addTag(name: newTagName, type: selectedType)
                                store.assignTag(tagID: tag.id, to: atomID)
                                newTagName = ""
                                onSaved()
                                dismiss()
                            }
                            .disabled(newTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
            }
            .navigationTitle("添加标签")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func tagRow(tag: TagItem) -> some View {
        Button {
            guard let atomID else { return }
            store.assignTag(tagID: tag.id, to: atomID)
            onSaved()
            dismiss()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(tag.name)
                        .font(.body)
                    Text(tag.type.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "plus.circle")
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
}
