//
//  EditDeckView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View for managing and displaying a flashcard list for a selected deck.

import SwiftUI

struct FlashcardListScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var flashcardFormViewModel: FlashcardFormViewModel
    @ObservedObject var viewModel: FlashcardsListViewModel
    @State private var selectedFlashcardID: String?
    @State private var isFirstTimeOpening: Bool = true
    @State private var isNavigationActive = false
    @State private var isLoading: Bool = false
    @State private var showEditFlashcard: Bool = false
    @State private var showAddFlashcard: Bool = false
    @State private var showModifyFlashcardButtons: Bool = false
    @State private var fetchTask: Task<Void, Never>?
    @Binding var selectedDeckID: String?

    typealias SelectedDeckData = (theme: Theme, deckName: String)
    let selectedDeckData: SelectedDeckData

    var body: some View {
        ZStack {
            if isLoading {
                FullScreenProgressScreen()
            } else if viewModel.flashcards.isEmpty {
                DefaultEmptyScreen(
                    defaultEmptyViewType: .flashcard,
                    buttonAction: { showAddFlashcard = true }
                )
            }

            // Keep flashcard list in view to ensure search bar is stable
            SearchableFlashcardView(
                viewModel: viewModel,
                showModifyFlashcardButtons: $showModifyFlashcardButtons,
                isNavigationActive: $isNavigationActive,
                showEditFlashcard: $showEditFlashcard,
                selectedFlashcardID: $selectedFlashcardID,
                selectedDeckID: selectedDeckID,
                reloadData: reloadData,
                showSearchable: !isFlashcardListViewHidden,
                theme: selectedDeckData.theme
            )
            .opacity(isFlashcardListViewHidden ? 0 : 1)
            .allowsHitTesting(isFlashcardListViewHidden ? false : true)
        }
        .navigationTitle(selectedDeckData.deckName)
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
            viewModel.isEndOfList = false
            viewModel.flashcards = []
            viewModel.clearSearchText()
        }
        .navigationDestination(isPresented: $isNavigationActive) {
            FlashcardCardScreen(
                viewModel: flashcardFormViewModel,
                selectedFlashcardID: $selectedFlashcardID,
                selectedDeckID: selectedDeckID
            )
        }
        .onChange(of: showAddFlashcard) { _, newValue in
            handleSheetDismissal(isSheetVisible: newValue)
        }
        .onChange(of: showEditFlashcard) { _, newValue in
            handleSheetDismissal(isSheetVisible: newValue)
        }
        .sheet(isPresented: $showAddFlashcard) {
            AddFlashcardScreen(
                viewModel: flashcardFormViewModel,
                selectedDeckID: selectedDeckID
            )
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showEditFlashcard) {
            EditFlashcardScreen(viewModel: flashcardFormViewModel, selectedFlashcardID: $selectedFlashcardID)
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Helper Methods
    private func reloadData() async {
        if let selectedDeckID {
            try? await viewModel.fetchInitialFlashcards(selectedDeckID: selectedDeckID)
        }
        isLoading = false
    }

    private func loadAndSetupSearch() async {
        if let selectedDeckID {
            try? await viewModel.fetchInitialFlashcards(selectedDeckID: selectedDeckID)
        }
        await viewModel.setUpSearch()
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
        isLoading || viewModel.flashcards.isEmpty
    }

    // MARK: - Toolbar Content
    @ToolbarContentBuilder
    func toolbarAddFlashcardButton(showAddFlashcard: Binding<Bool>) -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showAddFlashcard.wrappedValue = true
            } label: {
                Image(systemName: "rectangle.badge.plus")
                    .tint(Color.customSecondary)
            }
        }
    }

    @ToolbarContentBuilder
    func toolbarshowModifyFlashcardButton(showModifyFlashcard: Binding<Bool>) -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showModifyFlashcard.wrappedValue.toggle()
                }
            } label: {
                Image(systemName: "square.and.pencil")
            }
            .tint(Color.customSecondary)
            .disabled(viewModel.flashcards.isEmpty)
        }
    }
}

extension FlashcardListScreen {
    init(
        viewModel: FlashcardsListViewModel,
        selectedDeckID: Binding<String?>,
        selectedDeckIDData: (Theme, String)
    ) {
        _flashcardFormViewModel = StateObject(wrappedValue:
            FlashcardFormViewModel(databaseManager: viewModel.databaseManager)
        )
        _viewModel = ObservedObject(wrappedValue: viewModel)
        _selectedDeckID = selectedDeckID
        self.selectedDeckData = selectedDeckIDData
    }
}

#if DEBUG
#Preview {
    @Previewable @Environment(\.font) var font
    NavigationStack {
        FlashcardListScreen(
            flashcardFormViewModel: FlashcardFormViewModel(databaseManager: MockDatabaseManager()),
            viewModel: FlashcardsListViewModel(
                searchBarManager: SearchBarManager(),
                databaseManager: MockDatabaseManager()
            ),
            selectedDeckID: .constant(Deck.sampleSubdeckArray[2].id),
            selectedDeckData: (.blue, "Flashcards")
        )
    }
    .environment(\.font, Font.customBody)
}

#Preview {
    NavigationStack {
        FlashcardListScreen(
            flashcardFormViewModel: FlashcardFormViewModel(databaseManager: EmptyMockDatabaseManager()),
            viewModel: FlashcardsListViewModel(
                searchBarManager: SearchBarManager(),
                databaseManager: EmptyMockDatabaseManager()
            ),
            selectedDeckID: .constant(UUID().uuidString),
            selectedDeckData: (.blue, "Flashcards")
        )
    }
}
#endif
