//
//  ProgressOverlayModifier.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct ProgressOverlayModifier: ViewModifier {
    @Binding var isPresented: Bool
    var progressOverlayType: ProgressOverlayType
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isPresented)
            Color.clear
                .background(.ultraThinMaterial)
            if isPresented {
                VStack {
                    ProgressView()
                        .controlSize(.large)
                        .tint(Color.customPrimary)
                        .padding(.bottom, 10)
                    Text(progressOverlayType.message)
                        .foregroundStyle(Color.customPrimary)
                        .fontWeight(.semibold)
                        .font(.customTitle3)
                }
            }
        }
    }
}

enum ProgressOverlayType {
    case saving
    case loading
    
    var message: String {
        switch self {
        case .saving:
            return "Saving..."
        case .loading:
            return "Loading..."
        }
    }
}
    
extension View {
    func progressOverlay(isPresented: Binding<Bool>, progressOverlayType: ProgressOverlayType) -> some View {
        self.modifier(ProgressOverlayModifier(isPresented: isPresented, progressOverlayType: progressOverlayType))
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        VStack {
            Color.red
                .frame(width: 100, height: 100)
            Color.blue
                .frame(width: 100, height: 100)
        }
        .progressOverlay(isPresented: .constant(true), progressOverlayType: .loading)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("Save")
            }
        }
    }
}
#endif
