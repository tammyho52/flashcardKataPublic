//
//  ReviewSetupView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view that allows users to select a study mode for their review session.

import SwiftUI

/// A view for selecting a study mode, displayed as a grid of options.
struct ReviewModeSelectionView: View {
    // MARK: - Properties
    @Binding var selectedReviewMode: ReviewMode

    let navigateToReviewSettingsView: () -> Void
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    // MARK: - Body
    var body: some View {
        List {
            Section {
                LazyVGrid(columns: columns) {
                    ForEach(ReviewMode.allCases) { reviewMode in
                        Button {
                            selectedReviewMode = reviewMode
                            navigateToReviewSettingsView()
                        } label: {
                            ReviewModeTile(
                                symbolName: reviewMode.symbolName,
                                description: reviewMode.description
                            )
                            .overlay(alignment: .topTrailing) {
                                decorativeArrow
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("\(reviewMode.description)ReviewSessionButton")
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
    
    // MARK: - Private Views
    private var decorativeArrow: some View {
        Image(systemName: "arrow.up.right")
            .font(.title2)
            .padding(10)
            .foregroundStyle(Color.customSecondary.opacity(0.7))
            .padding(5)
            .fontWeight(.semibold)
    }
}

// MARK: - Preview
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
