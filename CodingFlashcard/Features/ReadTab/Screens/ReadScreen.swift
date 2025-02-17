//
//  ReadView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct ReadScreen: View {
    @ObservedObject var vm: ReadViewModel
    @State private var layoutType: FlashcardLayout = .frontOnly
    @State private var showReadSettings: Bool = false
    @State private var reviewSettings: ReviewSettings = ReviewSettings()
    @State private var selectedFlashcardMode: FlashcardMode = .shuffle
    @State private var fetchTask: Task<Void, Never>?
    @State private var isDisabled: Bool = true
    @State private var isLoading: Bool = true
    
    let defaultButtonAction: () -> Void

    var body: some View {
        NavigationStack {
            readStateContent()
                .navigationTitle("Read")
                .onAppear {
                    if !vm.isGuestUser() {
                        isLoading = true
                        fetchTask = Task {
                            await loadFlashcards()
                        }
                    }
                }
                .onDisappear {
                    fetchTask?.cancel()
                    fetchTask = nil
                }
                .sheet(isPresented: $showReadSettings) {
                    ReadSettingsScreen(vm: vm, loadFlashcards: loadFlashcards)
                }
                .toolbar {
                    toolbarSetFlashcardGrid()
                    toolbarReadSettings()
                }
        }
    }
    
    @ViewBuilder
    private func readStateContent() -> some View {
        if vm.isGuestUser() {
            GuestDefaultScreen(
                guestViewType: .read,
                buttonAction: vm.navigateToSignInWithoutAccount
            )
            .applyColoredNavigationBarStyle(backgroundGradientColors: Tab.read.backgroundGradientColors, disableBackgroundColor: true)
        } else if isLoading {
            FullScreenProgressScreen()
                .applyColoredNavigationBarStyle(backgroundGradientColors: Tab.read.backgroundGradientColors, disableBackgroundColor: true)
                .edgesIgnoringSafeArea(.bottom)
        } else if vm.flashcardDisplayModels.isEmpty {
            DefaultEmptyScreen(defaultEmptyViewType: .getStarted, buttonAction: defaultButtonAction)
                .applyColoredNavigationBarStyle(backgroundGradientColors: Tab.read.backgroundGradientColors, disableBackgroundColor: true)
        } else {
            ReadingListView(
                flashcardLayout: $layoutType,
                flashcardDisplayModels: $vm.flashcardDisplayModels,
                showHint: vm.reviewSettings.showHint,
                showDifficultyLevel: vm.reviewSettings.showDifficultyLevel,
                showDeckName: vm.reviewSettings.showFlashcardDeckName
            )
            .applyColoredNavigationBarStyle(backgroundGradientColors: Tab.read.backgroundGradientColors)
        }
    }
    
    private func loadFlashcards() async {
        await vm.loadFlashcardDisplayModels()
        if !vm.flashcardDisplayModels.isEmpty {
            isDisabled = false
        }
        isLoading = false
    }
    
    @ToolbarContentBuilder
    private func toolbarSetFlashcardGrid() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                layoutType.toggle()
            } label: {
                Image(systemName: layoutType == .frontOnly ? "rectangle.grid.1x2" : "rectangle.portrait")
                    .fontWeight(.semibold)
            }
            .disabled(isDisabled)
            .tint(Color.customSecondary)
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
            .tint(Color.customSecondary)
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @Environment(\.font) var font
    ReadScreen(vm: ReadViewModel(databaseManager: MockDatabaseManager()), defaultButtonAction: {})
        .environment(\.font, Font.customBody)
}
#endif
