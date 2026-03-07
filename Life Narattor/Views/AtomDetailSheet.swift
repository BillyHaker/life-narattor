import CoreData
import SwiftUI

struct AtomDetailSheet: View {
    let atom: AtomItem
    let context: NSManagedObjectContext
    let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var content: String
    @State private var type: AtomType

    private var store: AtomTagStore { AtomTagStore(context: context) }

    init(atom: AtomItem, context: NSManagedObjectContext, onSaved: @escaping () -> Void) {
        self.atom = atom
        self.context = context
        self.onSaved = onSaved
        _content = State(initialValue: atom.content)
        _type = State(initialValue: atom.type)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("类型") {
                    Picker("类型", selection: $type) {
                        ForEach(AtomType.allCases) { item in
                            Text(item.title).tag(item)
                        }
                    }
                }

                Section("内容") {
                    TextEditor(text: $content)
                        .frame(minHeight: 120)
                }

                Section("标签") {
                    if atom.tags.isEmpty {
                        Text("暂无标签")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(atom.tags) { tag in
                            HStack {
                                Text(tag.name)
                                Spacer()
                                Button("移除") {
                                    store.removeTag(tagID: tag.id, from: atom.id)
                                    onSaved()
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Atom 详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        store.updateAtom(id: atom.id, content: content, type: type)
                        onSaved()
                        dismiss()
                    }
                }
            }
        }
    }
}
