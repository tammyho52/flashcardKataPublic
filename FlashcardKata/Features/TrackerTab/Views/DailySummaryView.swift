//
//  DailySummaryView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This view displays a summary of the user's daily progress, including
//  summary statistics (flashcards learned, streak, time studied) and deck reviewed charts.

import SwiftUI

/// This view displays a summary of the user's daily progress.
struct DailySummaryView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: TrackerViewModel
    @State private var accountCreationDate: Date = Date()
    @State private var isFirstAppear: Bool = true
    @MainActor @Binding var isLoading: Bool
    
    // MARK: - Body
    var body: some View {
        List {
            HStack {
                SectionHeaderTitle(text: "Daily Summary")
                Spacer()
                // Allows user to select a date from account creation date to today for the summary.
                DatePicker(
                    "Date",
                    selection: $viewModel.selectedDate,
                    in: accountCreationDate...Date(),
                    displayedComponents: [.date]
                )
                .labelsHidden()
            }
            .padding(.top, 10)
            .listRowSeparator(.hidden)
            .listSectionSeparator(.hidden)
            .listRowBackground(Color.clear)

            TrackerStatisticsView(
                flashcardCount: viewModel.cardsLearnedCount,
                streakCount: viewModel.streakCount,
                timeStudied: viewModel.timeStudied
            )
            .listRowSeparator(.hidden)
            .listSectionSeparator(.hidden)
            .listRowBackground(Color.clear)

            SectionHeaderTitle(text: "Kata Summary")
                .padding(.top, 5)
                .frame(maxWidth: .infinity, alignment: .leading)

            Group {
                // Sets default text if no decks were studied.
                if viewModel.chartItems.isEmpty {
                    if isDateToday(for: viewModel.selectedDate) {
                        // Sets below text if date is today.
                        Text("Start a Kata Review to see your progress!")
                            .font(.customHeadline)
                    } else {
                        // Sets below text if date is in the past.
                        Text("No Kata Reviews were completed on this date.")
                            .font(.customHeadline)
                    }
                // Displays chart if decks were studied.
                } else {
                    HStack {
                        Spacer()
                        DecksStudiedChart(chartItems: $viewModel.chartItems)
                        Spacer()
                    }
                    
                    ReviewSessionStatisticsGrid(chartItems: $viewModel.chartItems)
                        .listRowSeparator(.hidden)
                        .listSectionSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }
            .listRowSeparator(.hidden)
            .listSectionSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.inset)
        .lineSpacing(0)
        .scrollContentBackground(.hidden)
        .onAppear {
            if isFirstAppear {
                Task {
                    accountCreationDate = await viewModel.getAccountCreationDate()
                    isFirstAppear = false
                }
            }
        }
        .onChange(of: viewModel.selectedDate) {
            // Reloads data for new date selected.
            loadData()
        }
    }
    
    // MARK: - Private Methods
    private func loadData() {
        isLoading = true
        Task {
            await viewModel.loadTrackerSummaryViewData()
            isLoading = false
        }
    }

    /// Checks if the provided date is today.
    private func isDateToday(for date: Date) -> Bool {
        Calendar.current.startOfDay(for: date) == Calendar.current.startOfDay(for: Date())
    }
}

// MARK: - Preview
#if DEBUG

// Data available for selected date.
#Preview {
    let viewModel: TrackerViewModel = {
        let vm = TrackerViewModel(databaseManager: MockDatabaseManager())
        vm.cardsLearnedCount = 10
        vm.streakCount = 5
        vm.timeStudied = "1:30"
        vm.reviewSessionSummaries = ReviewSessionSummary.sampleArray
        vm.chartItems = ChartItem.sampleArray
        return vm
    }()
    
    DailySummaryView(
        viewModel: viewModel,
        isLoading: .constant(false)
    )
}

// No data available for selected date.
#Preview {
    DailySummaryView(
        viewModel: TrackerViewModel(databaseManager: MockDatabaseManager()),
        isLoading: .constant(false)
    )
}
#endif
