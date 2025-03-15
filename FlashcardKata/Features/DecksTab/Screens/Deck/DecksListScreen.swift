//
//  DeckView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Displays user's deck and subdeck list with navigation to edit decks and flashcards.

import SwiftUI

struct DecksListScreen: View {
    @StateObject var deckFormViewModel: DeckFormViewModel
    @StateObject var flashcardsListViewModel: FlashcardsListViewModel
    @ObservedObject var viewModel: DecksListViewModel

    @State private var isFlashcardNavigationActive = false
    @State private var isLoading: Bool = false
    @State private var isFirstTimeOpening: Bool = true
    @State private var selectedDeckID: String?
    @State private var showEditDeck: Bool = false
    @State private var showEditSubdeck: Bool = false
    @State private var showModifyDeckButtons: Bool = false
    @State private var fetchTask: Task<Void, Never>?
    @Binding var showAddDeck: Bool

    let defaultButtonAction: () -> Void

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isGuestUser() {
                    GuestDefaultScreen(
                        guestViewType: .decks,
                        buttonAction: viewModel.navigateToSignInWithoutAccount
                    )
                } else if isLoading {
                    FullScreenProgressScreen()
                } else if viewModel.decks.isEmpty {
                    DefaultEmptyScreen(
                        defaultEmptyViewType: .deck,
                        buttonAction: defaultButtonAction
                    )
                }

                // Keep deck list in view to ensure search bar is stable
                SearachableDeckListView(
                    viewModel: viewModel,
                    isNavigationActive: $isFlashcardNavigationActive,
                    showEditDeck: $showEditDeck,
                    showEditSubdeck: $showEditSubdeck,
                    showModifyDeckButtons: $showModifyDeckButtons,
                    selectedDeckID: $selectedDeckID,
                    reloadData: reloadData,
                    showSearchable: !isDeckListViewHidden
                )
                .opacity(isDeckListViewHidden ? 0 : 1)
                .allowsHitTesting(isDeckListViewHidden ? false : true)
            }
            .navigationTitle("Decks")
            .scrollIndicators(.hidden)
            .applyColoredNavigationBarStyle(backgroundGradientColors: Tab.decks.backgroundGradientColors)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                toolbarshowModifyDeckButton(showModifyDeck: $showModifyDeckButtons)
                toolbarAddNewDeckButton(showAddNewDeck: $showAddDeck)
            }
            .onAppear { onAppearLogic() }
            .onDisappear { onDisappearLogic() }
            .onChange(of: showAddDeck) { _, newValue in
                isLoading = true
                Task {
                    await handleSheetDismissal(isSheetVisible: newValue)
                }
            }
            .onChange(of: showEditDeck) { _, newValue in
                isLoading = true
                Task {
                    await handleSheetDismissal(isSheetVisible: newValue)
                }
            }
            .onChange(of: showEditSubdeck) { _, newValue in
                isLoading = true
                Task {
                    await handleSheetDismissal(isSheetVisible: newValue)
                }
            }
            .navigationDestination(isPresented: $isFlashcardNavigationActive) {
                FlashcardListScreen(
                    viewModel: flashcardsListViewModel,
                    selectedDeckID: $selectedDeckID,
                    selectedDeckIDData: selectedDeckIDData
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
                EditSubdeckScreen(viewModel: deckFormViewModel, selectedDeckID: $selectedDeckID)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: Selected Deck Properties
    var selectedDeckIDData: (Theme, String) {
        if let selectedDeck = viewModel.decks.first(where: { $0.id == selectedDeckID }) {
            return (selectedDeck.theme, selectedDeck.name)
        }
        return (.blue, "Flashcards")
    }

    // MARK: - Helper Methods
    private func onAppearLogic() {
        if !viewModel.isGuestUser() {
            isLoading = true
            fetchTask = Task {
                if isFirstTimeOpening {
                    await loadAndSetupSearch()
                } else {
                    await reloadData()
                }
            }
        }
    }

    private func onDisappearLogic() {
        fetchTask?.cancel()
        fetchTask = nil
        viewModel.isEndOfList = false
    }

    private func reloadData() async {
        try? await viewModel.fetchInitialDeckListData()
        isLoading = false
    }

    private func loadAndSetupSearch() async {
        try? await viewModel.fetchInitialDeckListData()
        await viewModel.setUpSearch()
        isFirstTimeOpening = false
        isLoading = false
    }

    // Reloads data when modal sheets are dismissed.
    private func handleSheetDismissal(isSheetVisible: Bool) async {
        if !isSheetVisible {
            await reloadData()
        }
    }

    private var isDeckListViewHidden: Bool {
        isLoading || viewModel.decks.isEmpty || viewModel.isGuestUser()
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
            .tint(Color.customSecondary)
            .disabled(viewModel.isGuestUser())
        }
    }

    @ToolbarContentBuilder
    func toolbarshowModifyDeckButton(showModifyDeck: Binding<Bool>) -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showModifyDeck.wrappedValue.toggle()
                    viewModel.isEndOfList = false
                }
            } label: {
                Image(systemName: "square.and.pencil")
            }
            .tint(Color.customSecondary)
            .disabled(viewModel.decks.isEmpty || viewModel.isGuestUser())
        }
    }
}

extension DecksListScreen {
    init(viewModel: DecksListViewModel, showAddDeck: Binding<Bool>, defaultButtonAction: @escaping () -> Void) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
        _deckFormViewModel = StateObject(
            wrappedValue: DeckFormViewModel(databaseManager: viewModel.databaseManager)
        )
        _flashcardsListViewModel = StateObject(wrappedValue: FlashcardsListViewModel(
            searchBarManager: SearchBarManager(),
            databaseManager: viewModel.databaseManager
        ))
        _showAddDeck = showAddDeck
        self.defaultButtonAction = defaultButtonAction
    }
}

#if DEBUG
#Preview {
    // Uses Mock Database Manager that contains data
    let viewModel = DecksListViewModel(searchBarManager: SearchBarManager(), databaseManager: MockDatabaseManager())
    NavigationStack {
        DecksListScreen(
            deckFormViewModel: DeckFormViewModel(databaseManager: MockDatabaseManager()),
            flashcardsListViewModel: FlashcardsListViewModel(
                searchBarManager: SearchBarManager(),
                databaseManager: MockDatabaseManager()
            ),
            viewModel: viewModel,
            showAddDeck: .constant(false),
            defaultButtonAction: {}
        )
    }
}

#Preview {
    @Previewable @Environment(\.font) var font
    // Uses Empty Mock Database Manager that has no data
    let viewModel = DecksListViewModel(
        searchBarManager: SearchBarManager(),
        databaseManager: EmptyMockDatabaseManager()
    )
    NavigationStack {
        DecksListScreen(
            deckFormViewModel: DeckFormViewModel(databaseManager: EmptyMockDatabaseManager()),
            flashcardsListViewModel: FlashcardsListViewModel(
                searchBarManager: SearchBarManager(),
                databaseManager: EmptyMockDatabaseManager()
            ),
            viewModel: viewModel,
            showAddDeck: .constant(false),
            defaultButtonAction: {}
        )
    }
    .environment(\.font, Font.customBody)
}
#endif
