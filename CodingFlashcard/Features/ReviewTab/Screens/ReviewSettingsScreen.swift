//
//  ReviewSettingsScreen.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct ReviewSettingsScreen: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: ReviewViewModel
    @State private var showSelectDecksView: Bool = false
    @State private var startStudySession: Bool = false
    @Binding var showReviewSettingsScreen: Bool
    
    var body: some View {
        NavigationStack {
            List {
                ReviewSettingsSections(
                    showSelectDeckView: $showSelectDecksView,
                    reviewSettings: $vm.reviewSettings,
                    clearSelectedFlashcardIDs: vm.clearSelectedFlashcardIDs
                )
                .listRowBackground(Color.clear)
                
                if vm.reviewMode == .target {
                    Section("Target Mode") {
                        labeledTargetModeCorrectPicker
                    }
                    .listSectionSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                
                if vm.reviewMode == .timed {
                    Section("Timed Mode") {
                        labeledTimedModePicker
                    }
                    .listSectionSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.inset)
            .scrollContentBackground(.hidden)
            .navigationTitle("Review Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .applyColoredNavigationBarStyle(backgroundGradientColors: Tab.kata.backgroundGradientColors)
            .sheet(isPresented: $showSelectDecksView) {
                ReviewSelectDecksView(vm: vm, showSelectDecksView: $showSelectDecksView)
                    .presentationDragIndicator(.visible)
            }
            .fullScreenCover(isPresented: $startStudySession) {
                ReviewSessionScreen(vm: vm, exitAction: exitToReviewOverviewScreen)
            }
            .toolbar {
                toolbarBackButton() {
                    dismiss()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        startStudySession = true
                        vm.reviewSessionSummary.startDate = Date()
                    } label: {
                        Image(systemName: "play.fill")
                            .fontWeight(.semibold)
                            .font(.title3)
                            .tint(Color.customSecondary)
                    }
                    .disabled(isStartStudySessionDisabled)
                }
            }
        }
    }
    
    private func exitToReviewOverviewScreen() {
        Task {
            startStudySession = false
            while startStudySession == true {
                await Task.yield()
            }
            await MainActor.run {
                showReviewSettingsScreen = false
            }
        }
    }
    
    var labeledTargetModeCorrectPicker: some View {
        HStack {
            Label {
                Text("Maximum Target Correct Count")
            } icon: {
                Image(systemName: vm.reviewMode.symbolName)
                    .foregroundStyle(DesignConstants.Colors.iconSecondary)
            }
            Spacer()
            Picker("Maximum Target Count", selection: $vm.reviewSettings.targetCorrectCount) {
                ForEach(Array(stride(from: 10, to: 101, by: 10)), id: \.self) { number in
                    Text("\(number)").tag(number)
                }
            }
            .labelsHidden()
        }
    }
    
    var labeledTimedModePicker: some View {
        HStack {
            Label {
                Text("Maximum Kata Review Time")
            } icon: {
                Image(systemName: vm.reviewMode.symbolName)
                    .foregroundStyle(DesignConstants.Colors.iconSecondary)
            }
            Spacer()
            Picker("Maximum Kata Review Time", selection: $vm.reviewSettings.sessionTime) {
                ForEach(SessionTime.allCases) { sessionTime in
                    Text("\(sessionTime.rawValue)").tag(sessionTime)
                }
            }
            .labelsHidden()
        }
    }
    
    private var isStartStudySessionDisabled: Bool {
        return vm.reviewSettings.selectedFlashcardMode == .custom && vm.reviewSettings.selectedFlashcardIDs.isEmpty
    }
}

#if DEBUG
#Preview {
    let vm: ReviewViewModel = {
        let vm = ReviewViewModel(databaseManager: MockDatabaseManager())
        vm.reviewSettings.selectedFlashcardIDs = Set(Flashcard.sampleFlashcardArray.map(\.id))
        return vm
    }()
    
    ReviewSettingsScreen(vm: vm, showReviewSettingsScreen: .constant(true))
}
#endif
