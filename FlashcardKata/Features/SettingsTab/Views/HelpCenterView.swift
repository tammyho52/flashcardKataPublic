//
//  HelpCenterView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  This view displays a list of frequently asked questions (FAQs) fetched from a remote JSON source.

import SwiftUI

/// This view displays the Help Center containing frequently asked questions and answers.
struct HelpCenterView: View {
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss

    @MainActor @State private var isLoading: Bool = false
    @State private var faqArray: [FAQ] = []
    @State private var errorMessage: String?

    let jsonURL = ContentConstants.ContentStrings.faqJSONURL

    // MARK: - Body
    var body: some View {
        Group {
            // Display a loading screen while fetching data
            if isLoading {
                FullScreenProgressScreen()
                    .edgesIgnoringSafeArea(.bottom)
            // Display an error toast if fetching data fails
            } else if let errorMessage {
                ToastView(style: .error, message: errorMessage, onCancelTapped: { dismiss() })
            // Display the FAQ list if data is successfully fetched
            } else {
                List(faqArray) { faq in
                    FAQItemView(faq: faq)
                }
                .navigationTitle("Help Center")
                .navigationBarTitleDisplayMode(.inline)
                .scrollIndicators(.hidden)
            }
        }
        .toolbar {
            toolbarBackButton {
                dismiss()
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            isLoading = true
            Task {
                defer { isLoading = false }
                do {
                    faqArray = try await fetchURLData(from: jsonURL)
                } catch {
                    if let appError = error as? AppError {
                        errorMessage = appError.message
                    } else {
                        errorMessage = "The Help Center is currently unavailable."
                    }
                    reportError(error)
                }
            }
        }
    }
}

// MARK: - Private Views
/// A view representing a single FAQ item with its question and answer.
private struct FAQItemView: View {
    let faq: FAQ

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(faq.questionText)
                .font(.customHeadline)
            
            Text(faq.answerText)
                .font(.customSubheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    NavigationStack {
        HelpCenterView()
    }
}
#endif
