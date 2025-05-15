//
//  CustomTabBar.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Custom Tab Bar for the app allowing users to switch between tabs.

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    @ScaledMetric var verticalHeight = 65

    private var fillSymbol: String {
        selectedTab.symbol + ".fill"
    }

    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 2.5) {
                        Divider()
                            .frame(height: 2)
                            .background(tab == selectedTab ? DesignConstants.Colors.tabBarTint : Color.clear)
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                        Image(systemName: tab == selectedTab ? fillSymbol : tab.symbol)
                            .scaleEffect(tab == selectedTab ? 1.2 : 1)
                            .foregroundStyle(tab == selectedTab ? DesignConstants.Colors.tabBarTint : Color.gray)
                            .font(.system(size: 20))
                            .frame(width: 20, height: 20)
                        Text("\(tab.rawValue.capitalized)")
                            .font(.customCaption)
                            .kerning(-0.5)
                            .fontWeight(tab == selectedTab ? .bold : .semibold)
                            .foregroundStyle(tab == selectedTab ? DesignConstants.Colors.tabBarTint : Color.gray)
                            .frame(maxHeight: .infinity)
                    }
                }
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier("\(tab.rawValue)TabButton")
            }
        }
        .frame(height: verticalHeight)
        .padding(.horizontal, 10)
        .background(.ultraThinMaterial)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.15), radius: 5, y: 2)
        .padding(.horizontal, 10)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    ZStack {
        Color.blue
        CustomTabBar(selectedTab: .constant(.decks))
    }
}
#endif
