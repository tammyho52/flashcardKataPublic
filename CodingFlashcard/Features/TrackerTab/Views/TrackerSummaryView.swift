//
//  CalendarView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct TrackerSummaryView: View {
    @ObservedObject var vm: TrackerViewModel
    @State private var accountCreationDate: Date = Date()
    @State private var isLoading: Bool = false
    
    var body: some View {
        List {
            HStack {
                SectionHeaderTitle(text: "Daily Summary")
                Spacer()
                DatePicker("Date", selection: $vm.date, in: accountCreationDate...Date(), displayedComponents: [.date])
                    .labelsHidden()
            }
            .padding(.top, 10)
            .listRowSeparator(.hidden)
            .listSectionSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            TrackerStatisticsView(
                flashcardCount: vm.cardsLearnedCount,
                streakCount: vm.streakCount,
                timeStudied: vm.timeStudied
            )
            .listRowSeparator(.hidden)
            .listSectionSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            SectionHeaderTitle(text: "Kata Summary")
                .padding(.top, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Group {
                if vm.chartItems.isEmpty {
                    if isDateToday(for: vm.date) {
                        Text("Start a Kata Review to see your progress!")
                            .font(.customHeadline)
                    } else {
                        Text("No Kata Reviews were completed on this date.")
                            .font(.customHeadline)
                    }
                } else {
                    HStack {
                        Spacer()
                        DecksStudiedChart(chartItems: $vm.chartItems)
                        Spacer()
                    }
                }
            }
            .listRowSeparator(.hidden)
            .listSectionSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            ReviewSessionStatisticsGrid(chartItems: $vm.chartItems)
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
                if let creationDate = UserDefaults.standard.value(forKey: "accountCreationDate") as? Date {
                    accountCreationDate = creationDate
                }
            }
        }
        .onChange(of: vm.date) {
            loadData()
        }
    }
    
    private func loadData() {
        isLoading = true
        Task {
            try await vm.loadTrackerSummaryViewData()
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
        TrackerSummaryView(vm: TrackerViewModel(databaseManager: MockDatabaseManager()))
            .navigationTitle("Tracker")
            .applyColoredNavigationBarStyle(backgroundGradientColors: Tab.tracker.backgroundGradientColors)
    }
}
#endif
