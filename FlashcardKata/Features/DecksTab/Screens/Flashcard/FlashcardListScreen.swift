//
//  FlashcardListScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  This screen manages and displays a flashcard list associated with a selected deck.

import SwiftUI

/// This screen displays a list of flashcards associated with a selected deck, and supports adding, editing, and deleting flashcards.
struct FlashcardListScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @StateObject var flashcardFormViewModel: FlashcardFormViewModel
    @ObservedObject var viewModel: FlashcardsListViewModel
    @State private var selectedFlashcardID: String? // Used to pass the selected flashcard ID to the detail screen
    @State private var isFirstTimeOpening: Bool = true
    @State private var isNavigationActive = false
    @MainActor @State private var isLoading: Bool = false
    @State private var showEditFlashcard: Bool = false
    @State private var showAddFlashcard: Bool = false
    @State private var showModifyFlashcardButtons: Bool = false
    @State private var fetchTask: Task<Void, Never>?
    @Binding var selectedDeckID: String? // ID of the selected deck, passed to new flashcards to associate them with the correct deck
    @Binding var selectedDeckIDData: (Theme, String)
    
    // MARK: - Computed Properties
    /// The theme of the selected deck, used to style the flashcards.
    var selectedDeckTheme: Theme {
        selectedDeckIDData.0
    }
    /// The name of the selected deck, used for navigation title.
    var selectedDeckName: String {
        selectedDeckIDData.1
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            // Progress Screen
            if isLoading {
                FullScreenProgressScreen()
                    .edgesIgnoringSafeArea(.bottom)
            // Empty flashcard list
            } else if viewModel.flashcards.isEmpty {
                DefaultEmptyScreen(
                    defaultEmptyViewType: .flashcard,
                    buttonAction: { showAddFlashcard = true }
                )
            // Flashcard list with data
            } else {
                SearchableFlashcardListView(
                    viewModel: viewModel,
                    showModifyFlashcardButtons: $showModifyFlashcardButtons,
                    isNavigationActive: $isNavigationActive,
                    showEditFlashcard: $showEditFlashcard,
                    selectedFlashcardID: $selectedFlashcardID,
                    reloadData: reloadData,
                    theme: selectedDeckTheme
                )
            }
        }
        .navigationTitle(selectedDeckName)
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .toolbar {
            toolbarBackButton { dismiss() }
            toolbarshowModifyFlashcardButton(showModifyFlashcard: $showModifyFlashcardButtons)
            toolbarAddFlashcardButton(showAddFlashcard: $showAddFlashcard)
        }
        .applyColoredNavigationBarStyle(
            backgroundGradientColors: Tab.decks.backgroundGradientColors,
            disableBackgroundColor: viewModel.flashcards.isEmpty || isLoading
        )
        .onAppear {
            if viewModel.selectedDeckID != selectedDeckID {
                viewModel.selectedDeckID = selectedDeckID
            }
            if isFirstTimeOpening {
                loadAndSetupSearch()
            } else {
                reloadData()
            }
        }
        .onDisappear {
            fetchTask?.cancel()
            fetchTask = nil
            viewModel.resetViewModel()
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
                selectedDeckID: $selectedDeckID
            )
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showEditFlashcard) {
            EditFlashcardScreen(viewModel: flashcardFormViewModel, selectedFlashcardID: $selectedFlashcardID)
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Private Methods
    /// Reloads the flashcard list data and updates the view.
    private func reloadData() {
        isLoading = true
        fetchTask = Task {
            await viewModel.fetchInitialFlashcards()
            isLoading = false
        }
    }

    /// Loads initial flashcards and sets up the search functionality.
    /// Preconditions: The selected deck ID must be set.
    /// Postconditions: The flashcards are fetched and the search functionality is set up.
    private func loadAndSetupSearch() {
        isLoading = true
        fetchTask = Task {
            await viewModel.fetchInitialFlashcards()
            await viewModel.setUpSearch()
            isFirstTimeOpening = false
            isLoading = false
        }
    }

    /// Reloads data after the dismissal of the add/edit flashcard sheets
    private func handleSheetDismissal(isSheetVisible: Bool) {
        if !isSheetVisible {
            reloadData()
        }
    }

    // MARK: - Toolbar Content
    @ToolbarContentBuilder
    func toolbarAddFlashcardButton(showAddFlashcard: Binding<Bool>) -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showAddFlashcard.wrappedValue = true
            } label: {
                Image(systemName: "rectangle.badge.plus")
            }
            .accessibilityIdentifier("addFlashcardButton")
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
            .disabled(viewModel.flashcards.isEmpty)
            .accessibilityIdentifier("showModifyFlashcardButton")
        }
    }
}

extension FlashcardListScreen {
    // MARK: - Initializer
    init(
        viewModel: FlashcardsListViewModel,
        selectedDeckID: Binding<String?>,
        selectedDeckIDData: Binding<(Theme, String)>
    ) {
        _flashcardFormViewModel = StateObject(wrappedValue:
            FlashcardFormViewModel(databaseManager: viewModel.databaseManager)
        )
        _viewModel = ObservedObject(wrappedValue: viewModel)
        _selectedDeckID = selectedDeckID
        _selectedDeckIDData = selectedDeckIDData
    }
}

// MARK: - Preview
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
            selectedDeckIDData: .constant((.green, "Swift Coding Basics"))
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
            selectedDeckIDData: .constant((.blue, "Flashcards"))
        )
    }
}
#endif
