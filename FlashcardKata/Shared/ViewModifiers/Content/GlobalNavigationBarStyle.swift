//
//  GlobalNavigationBarStyle.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Custom view modifiers for setting navigation bar style with clear and colored backgrounds.

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
    }
}

struct ColoredGlobalNavigationBarStyle: ViewModifier {
    @ScaledMetric var verticalTabBarOffset = 65
    @ScaledMetric var verticalTabBarOffsetAdjustment: CGFloat = 10 // Adjust for rounded tab
    let navigationBarBackground: Color
    let backgroundGradientPrimaryColor: Color
    let backgroundGradientSecondaryColor: Color
    let disableBackgroundColor: Bool

    func body(content: Content) -> some View {
        content
            .toolbarBackground(navigationBarBackground.opacity(0.25), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.hidden, for: .tabBar)
            .toolbar(.hidden, for: .tabBar)
            .navigationBarBackButtonHidden()
            .edgesIgnoringSafeArea(.bottom)
            .padding(.bottom, verticalTabBarOffset - verticalTabBarOffsetAdjustment)
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

#if DEBUG
#Preview {
    NavigationStack {
        List {}
        .navigationTitle("Test Title")
        .scrollContentBackground(.hidden)
        .modifier(ColoredGlobalNavigationBarStyle(
            navigationBarBackground: .blue,
            backgroundGradientPrimaryColor: .blue,
            backgroundGradientSecondaryColor: .white,
            disableBackgroundColor: false
        ))
    }
}
#endif
