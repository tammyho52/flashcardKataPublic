//
//  ReviewSetupView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct ReviewModeSelectionView: View {
    @Binding var selectedReviewMode: ReviewMode
    
    let navigateToReviewSettingsView: () -> Void
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        List {
            Section {
                LazyVGrid(columns: columns) {
                    ForEach(ReviewMode.allCases) { reviewMode in
                        Button(action: {
                            selectedReviewMode = reviewMode
                            navigateToReviewSettingsView()
                        }) {
                            ReviewModeTile(
                                symbolName: reviewMode.symbolName,
                                description: reviewMode.description
                            )
                            .overlay(alignment: .topTrailing) {
                                Image(systemName: "arrow.up.right")
                                    .font(.title2)
                                    .padding(10)
                                    .foregroundStyle(Color.customSecondary.opacity(0.7))
                                    .padding(5)
                                    .fontWeight(.semibold)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            } header: {
                SectionHeaderTitle(text: "Study Modes")
            }
            .listSectionSeparator(.hidden)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.inset)
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ReviewModeSelectionView(
            selectedReviewMode: .constant(.practice),
            navigateToReviewSettingsView: {}
        )
        .navigationTitle("Review")
    }
}
#endif
