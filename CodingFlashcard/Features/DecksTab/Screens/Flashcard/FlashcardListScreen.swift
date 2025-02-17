//
//  EditDeckView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct FlashcardListScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var flashcardFormViewModel: FlashcardFormViewModel
    @ObservedObject var vm: FlashcardsListViewModel
    @State private var selectedFlashcardID: String?
    @State private var isFirstTimeOpening: Bool = true
    @State private var isNavigationActive = false
    @State private var isLoading: Bool = false
    @State private var showEditFlashcard: Bool = false
    @State private var showAddFlashcard: Bool = false
    @State private var showModifyFlashcardButtons: Bool = false
    @State private var fetchTask: Task<Void, Never>?
    @Binding var selectedDeckID: String?
    
    let selectedDeckIDData: (Theme, String)
    
    var body: some View {
        ZStack {
            if isLoading {
                FullScreenProgressScreen()
            } else if vm.flashcards.isEmpty {
                DefaultEmptyScreen(
                    defaultEmptyViewType: .flashcard,
                    buttonAction: { showAddFlashcard = true }
                )
            }
            
            SearchableFlashcardView(
                vm: vm,
                showModifyFlashcardButtons: $showModifyFlashcardButtons,
                isNavigationActive: $isNavigationActive,
                showEditFlashcard: $showEditFlashcard,
                selectedFlashcardID: $selectedFlashcardID,
                selectedDeckID: selectedDeckID,
                reloadData: reloadData,
                showSearchable: !isFlashcardListViewHidden,
                theme: selectedDeckIDData.0
            )
            .opacity(isFlashcardListViewHidden ? 0 : 1)
            .allowsHitTesting(isFlashcardListViewHidden ? false : true)
        }
        .navigationTitle(selectedDeckIDData.1)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .applyColoredNavigationBarStyle(backgroundGradientColors: Tab.decks.backgroundGradientColors)
        .toolbar {
            toolbarBackButton { dismiss() }
            toolbarshowModifyFlashcardButton(showModifyFlashcard: $showModifyFlashcardButtons)
            toolbarAddFlashcardButton(showAddFlashcard: $showAddFlashcard)
        }
        .onAppear {
            isLoading = true
            fetchTask = Task {
                if isFirstTimeOpening {
                    await loadAndSetupSearch()
                } else {
                    await reloadData()
                }
            }
        }
        .onDisappear {
            fetchTask?.cancel()
            fetchTask = nil
            vm.isEndOfList = false
            vm.flashcards = []
            vm.clearSearchText()
        }
        .navigationDestination(isPresented: $isNavigationActive) {
            FlashcardCardScreen(vm: flashcardFormViewModel, selectedFlashcardID: $selectedFlashcardID, selectedDeckID: selectedDeckID)
        }
        .onChange(of: showAddFlashcard) { _, newValue in
            handleSheetDismissal(isSheetVisible: newValue)
        }
        .onChange(of: showEditFlashcard) { _, newValue in
            handleSheetDismissal(isSheetVisible: newValue)
        }
        .sheet(isPresented: $showAddFlashcard) {
            AddFlashcardScreen(vm: flashcardFormViewModel, selectedDeckID: selectedDeckID)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showEditFlashcard) {
            EditFlashcardScreen(vm: flashcardFormViewModel, selectedFlashcardID: $selectedFlashcardID)
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Helper Methods
    private func reloadData() async {
        if let selectedDeckID {
            try? await vm.fetchInitialFlashcards(selectedDeckID: selectedDeckID)
        }
        isLoading = false
    }
    
    private func loadAndSetupSearch() async {
        if let selectedDeckID {
            try? await vm.fetchInitialFlashcards(selectedDeckID: selectedDeckID)
        }
        await vm.setUpSearch()
        isFirstTimeOpening = false
        isLoading = false
    }
    
    private func handleSheetDismissal(isSheetVisible: Bool) {
        if !isSheetVisible {
            isLoading = true
            fetchTask = Task {
                await reloadData()
            }
        }
    }
    
    private var isFlashcardListViewHidden: Bool {
        isLoading || vm.flashcards.isEmpty
    }
    
    // MARK: - Toolbar Content
    @ToolbarContentBuilder
    func toolbarAddFlashcardButton(showAddFlashcard: Binding<Bool>) -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                showAddFlashcard.wrappedValue = true
            }) {
                Image(systemName: "rectangle.badge.plus")
                    .tint(Color.customSecondary)
            }
        }
    }
    
    @ToolbarContentBuilder
    func toolbarshowModifyFlashcardButton(showModifyFlashcard: Binding<Bool>) -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showModifyFlashcard.wrappedValue.toggle()
                }
            }) {
                Image(systemName: "square.and.pencil")
            }
            .tint(Color.customSecondary)
            .disabled(vm.flashcards.isEmpty)
        }
    }
}

extension FlashcardListScreen {
    init(vm: FlashcardsListViewModel, selectedDeckID: Binding<String?>, selectedDeckIDData: (Theme, String)) {
        _flashcardFormViewModel = StateObject(wrappedValue: FlashcardFormViewModel(databaseManager: vm.databaseManager))
        _vm = ObservedObject(wrappedValue: vm)
        _selectedDeckID = selectedDeckID
        self.selectedDeckIDData = selectedDeckIDData
    }
}

#if DEBUG
#Preview {
    @Previewable @Environment(\.font) var font
    NavigationStack {
        FlashcardListScreen(flashcardFormViewModel: FlashcardFormViewModel(databaseManager: MockDatabaseManager()), vm: FlashcardsListViewModel(searchBarManager: SearchBarManager(), databaseManager: MockDatabaseManager()), selectedDeckID: .constant(Deck.sampleSubdeckArray[2].id), selectedDeckIDData: (.blue, "Flashcards"))
    }
    .environment(\.font, Font.customBody)
}

#Preview {
    NavigationStack {
        FlashcardListScreen(flashcardFormViewModel: FlashcardFormViewModel(databaseManager: EmptyMockDatabaseManager()), vm: FlashcardsListViewModel(searchBarManager: SearchBarManager(), databaseManager: EmptyMockDatabaseManager()), selectedDeckID: .constant(UUID().uuidString),  selectedDeckIDData: (.blue, "Flashcards"))
    }
}
#endif
