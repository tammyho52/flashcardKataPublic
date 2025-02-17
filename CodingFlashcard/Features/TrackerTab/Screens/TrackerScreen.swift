//
//  TrackerView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct TrackerScreen: View {
    @ObservedObject var vm: TrackerViewModel
    @State private var isLoading: Bool = false
    
    let defaultButtonAction: () -> Void
    
    var body: some View {
        NavigationStack {
            Group {
                if vm.isGuestUser() {
                    GuestDefaultScreen(
                        guestViewType: .tracker,
                        buttonAction: vm.navigateToSignInWithoutAccount
                    )
                    .applyColoredNavigationBarStyle(backgroundGradientColors: Tab.tracker.backgroundGradientColors, disableBackgroundColor: true)
                } else if isLoading {
                    FullScreenProgressScreen()
                        .applyColoredNavigationBarStyle(backgroundGradientColors: Tab.tracker.backgroundGradientColors, disableBackgroundColor: true)
                        .edgesIgnoringSafeArea(.bottom)
                } else {
                    TrackerSummaryView(vm: vm)
                        .applyColoredNavigationBarStyle(backgroundGradientColors: Tab.tracker.backgroundGradientColors)
                }
            }
            .navigationTitle("Tracker")
            .onAppear {
                if !vm.isGuestUser() {
                    Task {
                        isLoading = true
                        await vm.checkForReviewSessionSummaries()
                        if vm.hasReviewSessionSummaries {
                            try await vm.loadTrackerSummaryViewData()
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
    TrackerScreen(vm: TrackerViewModel(databaseManager: MockDatabaseManager()), defaultButtonAction: {})
}
#endif
