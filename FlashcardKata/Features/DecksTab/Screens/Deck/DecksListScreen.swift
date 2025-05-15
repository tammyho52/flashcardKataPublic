//
//  DeckView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  This screen is responsible for displaying the user's decks and subdecks, managing
//  navigation to edit decks and flashcards, and handling the addition of new decks. It also
//  includes a search functionality for easy access to specific decks.

import SwiftUI

/// A view that manages the user's deck and subdeck list, with the ability to navigate to edit decks and flashcards.
struct DecksListScreen: View {
    // MARK: - View Models
    @StateObject var deckFormViewModel: DeckFormViewModel
    @StateObject var flashcardsListViewModel: FlashcardsListViewModel
    @ObservedObject var viewModel: DecksListViewModel
    
    // MARK: - Navigation
    @State private var isFlashcardNavigationActive = false
    @State private var selectedDeckID: String?
    @State private var selectedDeckIDData: (Theme, String) = (.blue, "Flashcards")
    
    // MARK: - UI State
    @State private var isLoading: Bool = false
    @State private var isFirstTimeOpening: Bool = true
    @State private var showEditDeck: Bool = false
    @State private var showEditSubdeck: Bool = false
    @State private var showModifyDeckButtons: Bool = false
    
    // MARK: - Data Fetching
    @State private var fetchTask: Task<Void, Never>?
    
    // MARK: - Binding
    @Binding var showAddDeck: Bool
    
    let defaultButtonAction: () -> Void
    
    // MARK: - Initializer
    init(
        viewModel: DecksListViewModel,
        showAddDeck: Binding<Bool>,
        defaultButtonAction: @escaping () -> Void
    ) {
        _deckFormViewModel = StateObject(
            wrappedValue: DeckFormViewModel(databaseManager: viewModel.databaseManager)
        )
        _flashcardsListViewModel = StateObject(wrappedValue: FlashcardsListViewModel(
            searchBarManager: SearchBarManager(),
            databaseManager: viewModel.databaseManager
        ))
        _viewModel = ObservedObject(wrappedValue: viewModel)
        _showAddDeck = showAddDeck
        self.defaultButtonAction = defaultButtonAction
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Guest user screen
                if viewModel.isGuestUser() {
                    GuestDefaultScreen(
                        guestViewType: .decks,
                        buttonAction: viewModel.navigateToSignInWithoutAccount
                    )
                // Loading screen
                } else if isLoading {
                    FullScreenProgressScreen()
                        .edgesIgnoringSafeArea(.bottom)
                // Empty decks screen
                } else if viewModel.deckWithSubdecks.isEmpty {
                    DefaultEmptyScreen(
                        defaultEmptyViewType: .deck,
                        buttonAction: defaultButtonAction
                    )
                // Decks list screen
                } else {
                    SearchableDeckListView(
                        viewModel: viewModel,
                        isNavigationActive: $isFlashcardNavigationActive,
                        showModifyDeckButtons: $showModifyDeckButtons,
                        selectedDeckID: $selectedDeckID,
                        showEditDeck: $showEditDeck,
                        showEditSubdeck: $showEditSubdeck,
                        reloadData: reloadData
                    )
                }
            }
            .navigationTitle("Decks")
            .scrollIndicators(.hidden)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                toolbarShowModifyDeckButton(showModifyDeck: $showModifyDeckButtons)
                toolbarAddNewDeckButton(showAddNewDeck: $showAddDeck)
            }
            .applyColoredNavigationBarStyle(
                backgroundGradientColors: Tab.decks.backgroundGradientColors,
                disableBackgroundColor: viewModel.deckWithSubdecks.isEmpty
            )
            .onAppear { onAppearLogic() }
            .onDisappear { onDisappearLogic() }
            .onChange(of: selectedDeckID) { _, newValue in
                // Updates selected deck ID data when a new deck is selected.
                if newValue != nil {
                    updateSelectedDeckIDData()
                }
            }
            .onChange(of: showAddDeck) { _, newValue in
                handleSheetDismissal(isSheetVisible: newValue)
            }
            .onChange(of: showEditDeck) { _, newValue in
                handleSheetDismissal(isSheetVisible: newValue)
            }
            .onChange(of: showEditSubdeck) { _, newValue in
                handleSheetDismissal(isSheetVisible: newValue)
            }
            .navigationDestination(isPresented: $isFlashcardNavigationActive) {
                FlashcardListScreen(
                    viewModel: flashcardsListViewModel,
                    selectedDeckID: $selectedDeckID,
                    selectedDeckIDData: $selectedDeckIDData
                )
            }
            .sheet(isPresented: $showAddDeck) {
                AddDeckScreen(viewModel: deckFormViewModel)
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showEditDeck) {
                EditDeckScreen(viewModel: deckFormViewModel, selectedDeckID: $selectedDeckID)
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showEditSubdeck) {
                EditSubdeckView(viewModel: deckFormViewModel, selectedDeckID: $selectedDeckID)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - Private Methods
    /// Updates selected deck data based on the selected deck ID.
    private func updateSelectedDeckIDData () {
        if let selectedDeck = viewModel.allDecks.first(where: { $0.id == selectedDeckID }) {
            selectedDeckIDData = (selectedDeck.theme, selectedDeck.name)
        }
    }
    
    /// Handles the logic when the view appears, including setting up search and loading data.
    private func onAppearLogic() {
        if !viewModel.isGuestUser() {
            if isFirstTimeOpening {
                loadAndSetupSearch()
            } else {
                reloadData()
            }
        }
    }
    
    /// Cancels the fetch task and resets the view model when the view disappears.
    private func onDisappearLogic() {
        fetchTask?.cancel()
        fetchTask = nil
        viewModel.resetViewModel()
    }
    
    /// Reloads the data for the decks list.
    private func reloadData() {
        isLoading = true
        fetchTask = Task {
            await viewModel.fetchInitialDecksWithSubdecks()
            isLoading = false
        }
    }
    
    /// Loads initial deck list data and sets up the search functionality for the decks list.
    private func loadAndSetupSearch() {
        isLoading = true
        fetchTask = Task {
            await viewModel.fetchInitialDecksWithSubdecks()
            await viewModel.setUpSearch()
            isFirstTimeOpening = false
            isLoading = false
        }
    }

    /// Reloads the data when modal sheets are dismissed, ensuring the latest data is displayed.
    private func handleSheetDismissal(isSheetVisible: Bool) {
        if !isSheetVisible {
            reloadData()
        }
    }

    // MARK: - Toolbar Content
    @ToolbarContentBuilder
    func toolbarAddNewDeckButton(showAddNewDeck: Binding<Bool>) -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showAddNewDeck.wrappedValue = true
                viewModel.isEndOfList = false
            } label: {
                Image(systemName: "rectangle.stack.badge.plus")
            }
            .disabled(viewModel.isGuestUser())
            .accessibilityIdentifier("addDeckButton")
        }
    }

    @ToolbarContentBuilder
    func toolbarShowModifyDeckButton(showModifyDeck: Binding<Bool>) -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showModifyDeck.wrappedValue.toggle()
                    viewModel.isEndOfList = false
                }
            } label: {
                Image(systemName: "square.and.pencil")
            }
            .disabled(viewModel.deckWithSubdecks.isEmpty || viewModel.isGuestUser())
            .accessibilityIdentifier("showModifyDeckButton")
        }
    }
}

// MARK: - Preview
#if DEBUG
/// Mock Database Manager that contains data for preview.
#Preview {
    let databaseManager = AnyDatabaseManager(databaseManager: MockDatabaseManager())
    let viewModel: DecksListViewModel = {
        let viewModel = DecksListViewModel(
            searchBarManager: SearchBarManager(),
            databaseManager: databaseManager
        )
        Task {
            await viewModel.fetchInitialDecksWithSubdecks()
            await viewModel.setUpSearch()
        }
        return viewModel
    }()
    NavigationStack {
        DecksListScreen(
            viewModel: viewModel,
            showAddDeck: .constant(false),
            defaultButtonAction: {}
        )
    }
}

/// Empty mock Database Manager that contains no data for preview.
#Preview {
    @Previewable @Environment(\.font) var font
    let databaseManager = AnyDatabaseManager(databaseManager: EmptyMockDatabaseManager())
    let viewModel = DecksListViewModel(
        searchBarManager: SearchBarManager(),
        databaseManager: databaseManager
    )
    NavigationStack {
        DecksListScreen(
            viewModel: viewModel,
            showAddDeck: .constant(false),
            defaultButtonAction: {}
        )
    }
    .environment(\.font, Font.customBody)
}
#endif
