//
//  CalendarView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Displays a high-level summary of the user's daily review progress.

import SwiftUI

struct TrackerSummaryView: View {
    @ObservedObject var viewModel: TrackerViewModel
    @State private var accountCreationDate: Date = Date()
    @State private var isLoading: Bool = false

    var body: some View {
        List {
            HStack {
                SectionHeaderTitle(text: "Daily Summary")
                Spacer()
                // Sets date for view, allowing dates from account creation date to today.
                DatePicker(
                    "Date",
                    selection: $viewModel.date,
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
                if viewModel.chartItems.isEmpty {
                    if isDateToday(for: viewModel.date) {
                        // Sets below text if date is today.
                        Text("Start a Kata Review to see your progress!")
                            .font(.customHeadline)
                    } else {
                        // Sets below text if date is in the past.
                        Text("No Kata Reviews were completed on this date.")
                            .font(.customHeadline)
                    }
                } else {
                    HStack {
                        Spacer()
                        DecksStudiedChart(chartItems: $viewModel.chartItems)
                        Spacer()
                    }
                }
            }
            .listRowSeparator(.hidden)
            .listSectionSeparator(.hidden)
            .listRowBackground(Color.clear)

            ReviewSessionStatisticsGrid(chartItems: $viewModel.chartItems)
                .listRowSeparator(.hidden)
                .listSectionSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .listStyle(.inset)
        .lineSpacing(0)
        .scrollContentBackground(.hidden)
        .applyOverlayProgressScreen(isViewDisabled: $isLoading)
        .onAppear {
            Task {
                // Sets date for date picker if available.
                if let creationDate = UserDefaults.standard.value(forKey: "accountCreationDate") as? Date {
                    accountCreationDate = creationDate
                }
            }
        }
        .onChange(of: viewModel.date) {
            // Reloads data for selected date.
            loadData()
        }
    }

    private func loadData() {
        isLoading = true
        Task {
            try await viewModel.loadTrackerSummaryViewData()
            isLoading = false
        }
    }

    private func isDateToday(for date: Date) -> Bool {
        Calendar.current.startOfDay(for: date) == Calendar.current.startOfDay(for: Date())
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        TrackerSummaryView(viewModel: TrackerViewModel(databaseManager: MockDatabaseManager()))
            .navigationTitle("Tracker")
            .applyColoredNavigationBarStyle(backgroundGradientColors: Tab.tracker.backgroundGradientColors)
    }
}
#endif
