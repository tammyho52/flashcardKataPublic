//
//  DeckView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct DecksListScreen: View {
    // MARK: - State Management and Dependencies
    @StateObject var deckFormViewModel: DeckFormViewModel
    @StateObject var flashcardsListViewModel: FlashcardsListViewModel
    @ObservedObject var vm: DecksListViewModel
    @State private var isNavigationActive = false
    @State private var showEditDeck: Bool = false
    @State private var showEditSubdeck: Bool = false
    @State private var isLoading: Bool = false
    @State private var selectedDeckID: String?
    @State private var isFirstTimeOpening: Bool = true
    @State private var showModifyDeckButtons: Bool = false
    @State private var fetchTask: Task<Void, Never>?
    @Binding var showAddDeck: Bool
    
    let defaultButtonAction: () -> Void

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                if vm.isGuestUser() {
                    GuestDefaultScreen(
                        guestViewType: .decks,
                        buttonAction: vm.navigateToSignInWithoutAccount
                    )
                } else if isLoading {
                    FullScreenProgressScreen()
                } else if vm.decks.isEmpty {
                    DefaultEmptyScreen(
                        defaultEmptyViewType: .deck,
                        buttonAction: defaultButtonAction
                    )
                }
                
                SearachableDeckListView(
                    vm: vm,
                    isNavigationActive: $isNavigationActive,
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
            .onAppear {
                if !vm.isGuestUser() {
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
            .onDisappear {
                fetchTask?.cancel()
                fetchTask = nil
                vm.isEndOfList = false
            }
            .navigationDestination(isPresented: $isNavigationActive) {
                FlashcardListScreen(vm: flashcardsListViewModel, selectedDeckID: $selectedDeckID, selectedDeckIDData: selectedDeckIDData)
            }
            .sheet(isPresented: $showAddDeck) {
                AddDeckScreen(vm: deckFormViewModel)
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showEditDeck) {
                EditDeckScreen(vm: deckFormViewModel, selectedDeckID: $selectedDeckID)
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showEditSubdeck) {
                EditSubdeckScreen(vm: deckFormViewModel, selectedDeckID: $selectedDeckID)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: Selected Deck Properties
    var selectedDeckIDData: (Theme, String) {
        if let selectedDeck = vm.decks.first(where: { $0.id == selectedDeckID }) {
            return (selectedDeck.theme, selectedDeck.name)
        }
        return (.blue, "Flashcards")
    }
    
    // MARK: - Helper Methods
    private func reloadData() async {
        try? await vm.fetchInitialDeckListData()
        isLoading = false
    }
    
    // MARK: - Helper Functions
    private func loadAndSetupSearch() async {
        try? await vm.fetchInitialDeckListData()
        await vm.setUpSearch()
        isFirstTimeOpening = false
        isLoading = false
    }
    
    private func handleSheetDismissal(isSheetVisible: Bool) async {
        if !isSheetVisible {
            await reloadData()
        }
    }
    
    private var isDeckListViewHidden: Bool {
        isLoading || vm.decks.isEmpty || vm.isGuestUser()
    }
    
    // MARK: - Toolbar Content
    @ToolbarContentBuilder
    func toolbarAddNewDeckButton(showAddNewDeck: Binding<Bool>) -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                showAddNewDeck.wrappedValue = true
                vm.isEndOfList = false
            }) {
                Image(systemName: "rectangle.stack.badge.plus")
            }
            .tint(Color.customSecondary)
            .disabled(vm.isGuestUser())
        }
    }
    
    @ToolbarContentBuilder
    func toolbarshowModifyDeckButton(showModifyDeck: Binding<Bool>) -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showModifyDeck.wrappedValue.toggle()
                    vm.isEndOfList = false
                }
            }) {
                Image(systemName: "square.and.pencil")
            }
            .tint(Color.customSecondary)
            .disabled(vm.decks.isEmpty || vm.isGuestUser())
        }
    }
}

extension DecksListScreen {
    init(vm: DecksListViewModel, showAddDeck: Binding<Bool>, defaultButtonAction: @escaping () -> Void) {
        _vm = ObservedObject(wrappedValue: vm)
        _deckFormViewModel = StateObject(
            wrappedValue: DeckFormViewModel(databaseManager: vm.databaseManager)
        )
        _flashcardsListViewModel = StateObject(wrappedValue: FlashcardsListViewModel(searchBarManager: SearchBarManager(), databaseManager: vm.databaseManager))
        _showAddDeck = showAddDeck
        self.defaultButtonAction = defaultButtonAction
    }
}

#if DEBUG
#Preview {
    // Uses Mock Database Manager that contains data
    let viewModel = DecksListViewModel(searchBarManager: SearchBarManager(), databaseManager: MockDatabaseManager())
    NavigationStack {
        DecksListScreen(deckFormViewModel: DeckFormViewModel(databaseManager: MockDatabaseManager()), flashcardsListViewModel: FlashcardsListViewModel(searchBarManager: SearchBarManager(), databaseManager: MockDatabaseManager()), vm: viewModel, showAddDeck: .constant(false), defaultButtonAction: {})
    }
}

#Preview {
    @Previewable @Environment(\.font) var font
    // Uses Empty Mock Database Manager that has no data
    let viewModel = DecksListViewModel(searchBarManager: SearchBarManager(), databaseManager: EmptyMockDatabaseManager())
    NavigationStack {
        DecksListScreen(deckFormViewModel: DeckFormViewModel(databaseManager: EmptyMockDatabaseManager()), flashcardsListViewModel: FlashcardsListViewModel(searchBarManager: SearchBarManager(), databaseManager: EmptyMockDatabaseManager()), vm: viewModel, showAddDeck: .constant(false), defaultButtonAction: {})
    }
    .environment(\.font, Font.customBody)
}
#endif
