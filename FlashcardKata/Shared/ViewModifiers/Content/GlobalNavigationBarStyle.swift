//
//  GlobalNavigationBarStyle.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Custom view modifiers for setting navigation bar style with clear and colored backgrounds and applies tint to navigation bar buttons.

import SwiftUI

struct ClearGlobalNavigationBarStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.hidden, for: .tabBar)
            .toolbar(.hidden, for: .tabBar)
            .navigationBarBackButtonHidden()
            .padding(.bottom, 20)
            .ignoresSafeArea(.keyboard)
            .tint(Color.customSecondary)
    }
}

struct ColoredGlobalNavigationBarStyle: ViewModifier {
    @ScaledMetric var verticalTabBarOffset = 65
    @ScaledMetric var verticalTabBarOffsetAdjustment: CGFloat = 10 // Adjust for rounded tab
    let navigationBarBackground: Color
    let backgroundGradientPrimaryColor: Color
    let backgroundGradientSecondaryColor: Color
    let disableBackgroundColor: Bool
    
    var bottomPadding: CGFloat {
        return disableBackgroundColor ? 20 : verticalTabBarOffset - verticalTabBarOffsetAdjustment
    }

    func body(content: Content) -> some View {
        content
            .toolbarBackground(navigationBarBackground.opacity(0.25), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.hidden, for: .tabBar)
            .toolbar(.hidden, for: .tabBar)
            .navigationBarBackButtonHidden()
            .padding(.bottom, bottomPadding)
            .background(
                LinearGradient(
                    colors: disableBackgroundColor
                    ? [Color.clear]
                    : [backgroundGradientPrimaryColor.opacity(0.1), backgroundGradientSecondaryColor.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .ignoresSafeArea(.keyboard)
            .tint(Color.customSecondary)
    }
}

extension ColoredGlobalNavigationBarStyle {
    init(backgroundGradientColors: BackgroundGradientColors, disableBackgroundColor: Bool) {
        self.navigationBarBackground = backgroundGradientColors.navigationBarBackground
        self.backgroundGradientPrimaryColor = backgroundGradientColors.backgroundGradientPrimaryColor
        self.backgroundGradientSecondaryColor = backgroundGradientColors.backgroundGradientSecondaryColor
        self.disableBackgroundColor = disableBackgroundColor
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    NavigationStack {
        List {
            //Empty
        }
        .navigationTitle("Test Title")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Test") {}
            }
        }
        .scrollContentBackground(.hidden)
        .modifier(ColoredGlobalNavigationBarStyle(
            navigationBarBackground: .blue,
            backgroundGradientPrimaryColor: .blue,
            backgroundGradientSecondaryColor: .white,
            disableBackgroundColor: false
        ))
    }
}

#Preview {
    NavigationStack {
        List {
            //Empty
        }
        .navigationTitle("Test Title")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Test") {}
            }
        }
        .scrollContentBackground(.hidden)
        .modifier(ClearGlobalNavigationBarStyle())
    }
}
#endif
