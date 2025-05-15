//
//  SelectAllScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Customizable view that allows users to select parent item and subitems from a list.

import SwiftUI

protocol UUIDIdentifiable: Identifiable {
    var id: String { get }
    var name: String { get }
}

struct SelectAllScreen<
    ParentItem: Identifiable & UUIDIdentifiable & Hashable,
    SubItem: Identifiable & UUIDIdentifiable & Hashable
>: View {

    @State private var expandAllDeckHelper = ExpandAllHelper()
    @State private var selectAllDeckHelper = SelectAllHelper()
    @State private var parentItemsWithSubItems: [(ParentItem, [SubItem])] = []
    @Binding var selectedParentItemIDs: Set<String>
    @Binding var selectedSubItemIDs: Set<String>
    @MainActor @Binding var isLoading: Bool

    let sectionTitle: String
    let loadParentItemsWithSubItems: () async -> [(ParentItem, [SubItem])]

    var body: some View {
        List {
            HStack {
                SectionHeaderTitle(text: sectionTitle)
                Spacer()
                selectAllButton
                expandAllButton
            }
            .listSectionSeparator(.hidden)
            .listRowSeparator(.hidden)

            ForEach(parentItemsWithSubItems, id: \.0.id) { parentItem, subItems in
                VStack(alignment: .leading) {
                    DisclosureGroup(isExpanded: isExpandedBinding(for: parentItem.id)) {
                        ForEach(subItems) { subItem in
                            subItemSelectionButton(subItem: subItem)
                                .padding(.leading, 20)
                                .padding(.vertical, 5)
                        }
                    } label: {
                        parentItemSelectionButton(parentItem: parentItem)
                            .padding(.vertical, 5)
                    }
                    .buttonStyle(.plain)
                    .tint(subItems.isEmpty ? .clear : Color.customSecondary)

                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .overlay {
                    RoundedRectangle(cornerRadius: DesignConstants.Layout.cornerRadius)
                        .stroke(Color.customSecondary, lineWidth: 2)
                }
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.inset)
        .onAppear {
            isLoading = true
            Task {
                await initialLoadAndSetUp()
                isLoading = false
            }
        }
        .onChange(of: selectAllDeckHelper.selectedParentItemIDs) {
            selectedParentItemIDs = selectAllDeckHelper.selectedParentItemIDs
        }
        .onChange(of: selectAllDeckHelper.selectedSubItemIDs) {
            selectedSubItemIDs = selectAllDeckHelper.selectedSubItemIDs
        }
    }

    func initialLoadAndSetUp() async {
        parentItemsWithSubItems = await loadParentItemsWithSubItems()

        let parentItemIDs = parentItemsWithSubItems
            .filter { !$0.1.isEmpty }
            .map { $0.0.id }
        expandAllDeckHelper.loadInitialItems(itemIDs: parentItemIDs)

        let parentIDsWithSubIDs = parentItemsWithSubItems.reduce(into: [:]) { result, itemPair in
            result[itemPair.0.id] = itemPair.1.map { $0.id }
        }
        selectAllDeckHelper.loadInitialItems(parentIDsWithSubIDs: parentIDsWithSubIDs)
    }

    var selectAllButton: some View {
        HeaderSelectionButton(isChecked: isSelectedAllBinding()) {
            selectAllDeckHelper.toggleSelectAll()
        }
        .accessibilityIdentifier("selectAllButton")
    }

    var expandAllButton: some View {
        HeaderExpansionButton(isChecked: isExpandedAllBinding()) {
            expandAllDeckHelper.toggleExpandAll()
        }
        .accessibilityIdentifier("expandAllButton")
    }

    func parentItemSelectionButton(parentItem: ParentItem) -> some View {
        CheckmarkSelectionButton(
            isChecked: isParentItemSelectedBinding(for: parentItem.id),
            text: parentItem.name,
            fontWeight: .semibold,
            buttonAction: {
                selectAllDeckHelper.toggleSelectedParentItem(itemID: parentItem.id)
            }
        )
        .accessibilityIdentifier("parentItemSelectionButton_\(parentItem.id)")
    }

    func subItemSelectionButton(subItem: SubItem) -> some View {
        CheckmarkSelectionButton(
            isChecked: isSubItemSelectedBinding(for: subItem.id),
            text: subItem.name,
            fontWeight: .regular,
            buttonAction: {
                selectAllDeckHelper.toggleSelectedSubItem(itemID: subItem.id)
            }
        )
        .accessibilityIdentifier("subItemSelectionButton_\(subItem.id)")
    }

    private func isSelectedAllBinding() -> Binding<Bool> {
        Binding(
            get: { selectAllDeckHelper.isSelectAll() },
            set: { _ in } // Manually set by button
        )
    }

    private func isSubItemSelectedBinding(for id: String) -> Binding<Bool> {
        Binding(
            get: { selectAllDeckHelper.isSubItemSelected(for: id) },
            set: { _ in } // Manually set by button
        )
    }

    private func isParentItemSelectedBinding(for id: String) -> Binding<Bool> {
        Binding(
            get: { selectAllDeckHelper.isParentItemSelected(for: id) },
            set: { _ in } // Manually set by button
        )
    }

    private func isExpandedAllBinding() -> Binding<Bool> {
        Binding(
            get: { expandAllDeckHelper.isExpandAll() },
            set: { _ in
            }
        )
    }

    private func isExpandedBinding(for id: String) -> Binding<Bool> {
        Binding(
            get: { expandAllDeckHelper.isExpanded(for: id) },
            set: { newValue in
                if newValue {
                    expandAllDeckHelper.expand(for: id)
                } else {
                    expandAllDeckHelper.collapse(for: id)
                }
            }
        )
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    NavigationStack {
        SelectAllScreen<Deck, Deck>(
            selectedParentItemIDs: .constant([]),
            selectedSubItemIDs: .constant([]),
            isLoading: .constant(false),
            sectionTitle: "Review Decks",
            loadParentItemsWithSubItems: { return [] }
        )
    }
}
#endif
