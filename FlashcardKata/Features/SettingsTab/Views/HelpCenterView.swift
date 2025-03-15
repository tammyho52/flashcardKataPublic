//
//  FAQView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Displays the Help Center containing frequently asked questions & answers.

import SwiftUI

struct HelpCenterView: View {
    @Environment(\.dismiss) var dismiss

    @State private var isLoading: Bool = false
    @State private var faqArray: [FAQ] = []
    @State private var errorMessage: String?

    let jsonURL = ContentConstants.ContentStrings.faqJSONURL

    var body: some View {
        Group {
            if isLoading {
                FullScreenProgressScreen()
            } else if let errorMessage {
                ToastView(style: .error, message: errorMessage, onCancelTapped: { dismiss() })
            } else {
                List(faqArray) { faq in
                    FAQItemView(faq: faq)
                }
                .navigationTitle("Help Center")
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
            Task {
                do {
                    isLoading = true
                    faqArray = try await fetchURLData(from: jsonURL)
                    isLoading = false
                } catch {
                    handleFetchError(error)
                    isLoading = false
                }
            }
        }
    }

    private func handleFetchError(_ error: Error) {
        switch error {
        case let fetchError as FetchError:
            switch fetchError {
            case .networkError:
                errorMessage = "Network error. Please try again later."
            case .decodingError, .invalidURL:
                errorMessage = "The Help Center is currently unavailable."
            }
        default:
            errorMessage = "The Help Center is currently unavailable."
        }
    }
}

// View for displaying each FAQ item with the question & answer.
private struct FAQItemView: View {
    let faq: FAQ

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(faq.question)
                .font(.customHeadline)
            Text(faq.answer)
                .font(.customSubheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        HelpCenterView()
    }
}
#endif
