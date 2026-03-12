//
//  MainTabContainerView.swift
//  Crarfarslormor Noxren
//
//  Created by Boranko Ydan on 12.03.2026.
//

import SwiftUI

struct MainTabContainerView: View {
    enum Tab: CaseIterable {
        case explore
        case compete
        case profile
    }

    @State private var selectedTab: Tab = .explore

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case .explore:
                    HomeView()
                case .compete:
                    CompeteView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack(spacing: 10) {
                tabButton(.explore, title: "Explore", icon: "globe.europe.africa.fill")
                tabButton(.compete, title: "Compete", icon: "flag.checkered.2.crossed")
                tabButton(.profile, title: "Profile", icon: "person.crop.circle.fill")
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 12)
            .background(
                LinearGradient(
                    colors: [Color.appSurface.opacity(0.98), Color.appBackground.opacity(0.96)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(Color.appAccent.opacity(0.24))
                    .frame(height: 1)
            }
            .shadow(color: Color.black.opacity(0.35), radius: 14, x: 0, y: -4)
        }
        .appScreenBackground()
    }

    private func tabButton(_ tab: Tab, title: String, icon: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(selectedTab == tab ? Color.appPrimary : Color.appTextSecondary)
            .frame(maxWidth: .infinity, minHeight: 50)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedTab == tab ? Color.appPrimary.opacity(0.16) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}
