import CoreData
import SwiftUI

struct CaptureDetailSheet: View {
    let item: CaptureItem
    let context: NSManagedObjectContext

    @State private var selectedTab: CaptureDetailTab = .cleaned
    @State private var showingTagSheet = false
    @State private var selectedAtomID: UUID?
    @State private var atoms: [AtomItem] = []

    private var atomStore: AtomTagStore { AtomTagStore(context: context) }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Picker("内容", selection: $selectedTab) {
                    ForEach(CaptureDetailTab.allCases) { tab in
                        Text(tab.title).tag(tab)
                    }
                }
                .pickerStyle(.segmented)

                Group {
                    switch selectedTab {
                    case .cleaned:
                        Text(item.cleanText ?? item.rawText)
                            .font(.body)
                            .foregroundStyle(.primary)
                    case .raw:
                        Text(item.rawText)
                            .font(.body)
                            .foregroundStyle(.primary)
                    case .atoms:
                        atomsView
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
            }
            .padding(16)
            .navigationTitle("记录详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("添加标签") {
                        showingTagSheet = true
                    }
                }
            }
            .sheet(isPresented: $showingTagSheet) {
                AddTagSheet(context: context, atomID: selectedAtomID, onSaved: reloadAtoms)
            }
            .sheet(item: $selectedAtomID) { atomID in
                if let atom = atoms.first(where: { $0.id == atomID }) {
                    AtomDetailSheet(atom: atom, context: context, onSaved: reloadAtoms)
                }
            }
            .onAppear {
                ensureAtomsIfNeeded()
                reloadAtoms()
            }
        }
    }

    private var atomsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if atoms.isEmpty {
                Text("没有可拆分的信息")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(atoms) { atom in
                    CaptureAtomRowView(atom: atom) {
                        selectedAtomID = atom.id
                    } onAddTag: {
                        selectedAtomID = atom.id
                        showingTagSheet = true
                    }
                }
            }
        }
    }

    private func ensureAtomsIfNeeded() {
        guard item.atomsCount == 0, let cleanText = item.cleanText else { return }
        let count = atomStore.createAtoms(from: cleanText, captureID: item.id)
        if count > 0 {
            atomStore.updateCaptureStats(captureID: item.id, atomsCount: count, processingState: .atomsReady)
        }
    }

    private func reloadAtoms() {
        atoms = atomStore.fetchAtoms(captureID: item.id)
    }
}

enum CaptureDetailTab: String, CaseIterable, Identifiable {
    case cleaned
    case raw
    case atoms

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cleaned:
            return "整理后"
        case .raw:
            return "原始"
        case .atoms:
            return "拆分"
        }
    }
}

struct CaptureAtomRowView: View {
    let atom: AtomItem
    let onOpenDetail: () -> Void
    let onAddTag: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: atom.type.iconName)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(atom.type.title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Menu {
                    Button("添加标签", action: onAddTag)
                    Button("更改类型", action: onOpenDetail)
                    Button("标记为重点") {}
                    Button("删除", role: .destructive) {}
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(.secondary)
                }
            }

            Text(atom.content)
                .font(.body)

            if !atom.tags.isEmpty {
                HStack(spacing: 8) {
                    ForEach(atom.tags) { tag in
                        Text(tag.name)
                            .font(.caption)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color(.systemGray6))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture(perform: onOpenDetail)
    }
}
