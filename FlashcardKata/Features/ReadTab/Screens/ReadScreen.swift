//
//  ReadScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view for displaying flashcards in a casual reading mode. It supports different flashcard
//  layouts, settings customization, and handles guest user scenarios.

import SwiftUI

/// A view for reading flashcards with various layout and customization options.
struct ReadScreen: View {
    // MARK: - Properties
    @ObservedObject var viewModel: ReadViewModel
    @State private var viewState: ReadViewState = .progress
    @State private var layoutType: FlashcardLayout = .frontOnly
    @State private var showReadSettings: Bool = false
    @State private var reviewSettings: ReviewSettings = ReviewSettings()
    @State private var fetchTask: Task<Void, Never>?
    @State private var isDisabled: Bool = true

    let defaultButtonAction: () -> Void

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Group {
                switch viewState {
                // Loading state
                case .progress:
                    FullScreenProgressScreen()
                        .edgesIgnoringSafeArea(.bottom)
                // Guest user state
                case .guest:
                    GuestDefaultScreen(
                        guestViewType: .read,
                        buttonAction: viewModel.navigateToSignInWithoutAccount
                    )
                // No flashcard data state
                case .empty:
                    DefaultEmptyScreen(
                        defaultEmptyViewType: .getStarted,
                        buttonAction: defaultButtonAction
                    )
                // Flashcard reading list with loaded data state
                case .readingList:
                    ReadingListView(
                        flashcardLayout: $layoutType,
                        flashcardDisplayModels: $viewModel.flashcardDisplayModels,
                        showHint: viewModel.reviewSettings.showHint,
                        showDifficultyLevel: viewModel.reviewSettings.showDifficultyLevel,
                        showDeckName: viewModel.reviewSettings.showFlashcardDeckName
                    )
                }
            }
            .navigationTitle("Read")
            .onAppear {
                guard !viewModel.isGuestUser() else {
                    viewState = .guest
                    return
                }
                fetchTask = Task {
                    await loadFlashcardDisplayModels()
                    updateViewStateForFlashcardData()
                }
            }
            .onDisappear {
                // Cancel the task when the view disappears
                fetchTask?.cancel()
                fetchTask = nil
            }
            .sheet(isPresented: $showReadSettings) {
                ReadSettingsScreen(
                    viewModel: viewModel,
                    loadFlashcards: loadFlashcardDisplayModels
                )
            }
            .toolbar {
                toolbarSetFlashcardLayout()
                toolbarReadSettings()
            }
            .applyColoredNavigationBarStyle(
                backgroundGradientColors: Tab.read.backgroundGradientColors,
                disableBackgroundColor: viewState != .readingList
            )
        }
    }

    // MARK: - Helpers
    /// Possible states of the `ReadScreen` view.
    private enum ReadViewState {
        case guest
        case progress
        case empty
        case readingList
    }
    
    private func loadFlashcardDisplayModels() async {
        await viewModel.loadInitialData()
        if !viewModel.flashcardDisplayModels.isEmpty {
            isDisabled = false
        }
    }
    
    /// Determines the view state based on the presence of flashcard data.
    private func updateViewStateForFlashcardData() {
        viewState = viewModel.flashcardDisplayModels.isEmpty ? .empty : .readingList
    }

    // MARK: - Toolbar Content
    @ToolbarContentBuilder
    private func toolbarSetFlashcardLayout() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                layoutType.toggle()
            } label: {
                Image(systemName: layoutType == .frontOnly ? "rectangle.grid.1x2" : "rectangle.portrait")
                    .fontWeight(.semibold)
            }
            .disabled(isDisabled)
            .accessibilityIdentifier("readFlashcardLayoutButton")
        }
    }

    @ToolbarContentBuilder
    private func toolbarReadSettings() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showReadSettings = true
            } label: {
                Image(systemName: "gear")
            }
            .disabled(isDisabled)
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    @Previewable @Environment(\.font) var font
    ReadScreen(viewModel: ReadViewModel(databaseManager: MockDatabaseManager()), defaultButtonAction: {})
        .environment(\.font, Font.customBody)
}
#endif
