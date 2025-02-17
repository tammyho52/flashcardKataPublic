//
//  StudyView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct ReviewOverviewScreen: View {
    @ObservedObject var vm: ReviewViewModel
    @State private var showReviewSettingsScreen = false
    @State private var isLoading = false
    
    let defaultButtonAction: () -> Void
    
    var body: some View {
        NavigationStack {
            Group {
                if vm.isGuestUser() {
                    GuestDefaultScreen(
                        guestViewType: .kata,
                        buttonAction: vm.navigateToSignInWithoutAccount
                    )
                    .applyColoredNavigationBarStyle(backgroundGradientColors: Tab.kata.backgroundGradientColors, disableBackgroundColor: true)
                } else if isLoading {
                    FullScreenProgressScreen()
                        .applyColoredNavigationBarStyle(backgroundGradientColors: Tab.kata.backgroundGradientColors, disableBackgroundColor: true)
                        .edgesIgnoringSafeArea(.bottom)
                } else if !vm.hasFlashcards {
                    DefaultEmptyScreen(defaultEmptyViewType: .getStarted, buttonAction: defaultButtonAction)
                        .applyColoredNavigationBarStyle(backgroundGradientColors: Tab.kata.backgroundGradientColors, disableBackgroundColor: true)
                } else {
                    ReviewModeSelectionView(
                        selectedReviewMode: $vm.reviewMode,
                        navigateToReviewSettingsView: {
                            showReviewSettingsScreen = true
                        }
                    )
                    .navigationDestination(isPresented: $showReviewSettingsScreen) {
                        ReviewSettingsScreen(
                            vm: vm,
                            showReviewSettingsScreen: $showReviewSettingsScreen
                        )
                    }
                    .applyColoredNavigationBarStyle(backgroundGradientColors: Tab.kata.backgroundGradientColors)
                }
            }
            .navigationTitle("Kata Review")
            .onAppear {
                if !vm.isGuestUser() {
                    Task {
                        isLoading = true
                        await vm.checkForFlashcards()
                        if vm.shouldReset {
                            vm.resetAllValues()
                            vm.shouldReset = false
                        }
                        isLoading = false
                    }
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    return ReviewOverviewScreen(vm: ReviewViewModel(databaseManager: MockDatabaseManager()), defaultButtonAction: {})
}
#endif
