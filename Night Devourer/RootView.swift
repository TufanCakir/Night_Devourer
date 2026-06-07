//
//  RootView.swift
//  Night Devourer
//
//  Created by Tufan Cakir on 07.06.26.
//

import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case menu
    case loadout
    case shrine
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .menu:
            "Menu"
        case .loadout:
            "Loadout"
        case .shrine:
            "Shrine"
        case .settings:
            "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .menu:
            "moon.fill"
        case .loadout:
            "shield.lefthalf.filled"
        case .shrine:
            "flame.fill"
        case .settings:
            "gearshape.fill"
        }
    }
}

struct RootView: View {
    @State private var selection: AppTab = .menu
    @State private var selectedMenuItem = "Neues Spiel"

    var body: some View {
        ZStack {
            NightBackground()

            currentView
                .animation(.easeInOut(duration: 0.22), value: selection)

            VStack(spacing: 0) {
                GlobalBandageHeader(currentTab: selection)
                Spacer()
                GlobalBandageFooter(selection: $selection)
            }
        }
    }

    @ViewBuilder
    private var currentView: some View {
        switch selection {
        case .menu:
            MenüVie(selectedItem: $selectedMenuItem)
                .transition(.opacity.combined(with: .offset(y: 12)))
        case .loadout:
            PlaceholderTabView(
                title: "Loadout",
                subtitle: "Bandagen, Relikte und Schattenausruestung"
            )
            .transition(.opacity.combined(with: .offset(y: 12)))
        case .shrine:
            PlaceholderTabView(
                title: "Shrine",
                subtitle: "Opfergaben und dunkle Verbesserungen"
            )
            .transition(.opacity.combined(with: .offset(y: 12)))
        case .settings:
            PlaceholderTabView(
                title: "Settings",
                subtitle: "Audio, Anzeige und Steuerung"
            )
            .transition(.opacity.combined(with: .offset(y: 12)))
        }
    }
}

private struct PlaceholderTabView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 18) {
            NightTitle()
                .scaleEffect(0.72)

            BandageButton(title: title, isSelected: true) {}
                .frame(width: 320)

            Text(subtitle.uppercased())
                .font(.system(size: 12, weight: .semibold, design: .serif))
                .tracking(1.4)
                .foregroundStyle(NightTheme.bone.opacity(0.72))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    RootView()
}
