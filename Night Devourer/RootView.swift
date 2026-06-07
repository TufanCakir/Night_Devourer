//
//  RootView.swift
//  Night Devourer
//
//  Created by Tufan Cakir on 07.06.26.
//

import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case menu
    case saves
    case game
    case victory
    case loadout
    case shrine
    case settings

    var id: String { rawValue }

    static let footerTabs: [AppTab] = [.menu, .loadout, .shrine, .settings]

    var title: String {
        switch self {
        case .menu:
            "Menu"
        case .saves:
            "Spielstaende"
        case .game:
            "Game"
        case .victory:
            "Victory"
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
        case .saves:
            "folder.fill"
        case .game:
            "figure.walk"
        case .victory:
            "trophy.fill"
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
    @State private var saves: [SaveSlot] = []
    @State private var activeSave: SaveSlot?
    @State private var battleResult = BattleResult.rewards(for: 0)

    var body: some View {
        ZStack {
            NightBackground()

            currentView
                .animation(.easeInOut(duration: 0.22), value: selection)

            if selection != .game && selection != .victory {
                VStack(spacing: 0) {
                    GlobalBandageHeader(currentTab: selection)
                    Spacer()
                    GlobalBandageFooter(selection: $selection)
                }
            }
        }
    }

    @ViewBuilder
    private var currentView: some View {
        switch selection {
        case .menu:
            MenüVie(selectedItem: $selectedMenuItem) { item in
                if item == "Neues Spiel" {
                    selection = .saves
                } else if item == "Fortsetzen" {
                    continueLatestSave()
                }
            }
            .transition(.opacity.combined(with: .offset(y: 12)))
        case .saves:
            SaveGameView(
                saves: $saves,
                onLoad: { save in
                    activeSave = save
                    selection = .game
                },
                onBack: {
                    selection = .menu
                }
            )
            .transition(.opacity.combined(with: .offset(y: 12)))
        case .game:
            GameView(
                saveSlot: activeSave,
                onVictory: { result in
                    battleResult = result
                    applyBattleResult(result)
                    selection = .victory
                }
            )
            .transition(.opacity.combined(with: .offset(y: 12)))
        case .victory:
            VictoryView(
                result: battleResult,
                onContinue: {
                    selection = .saves
                },
                onMenu: {
                    selection = .menu
                }
            )
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

    private func continueLatestSave() {
        if let latestSave = saves.max(by: { $0.lastPlayed < $1.lastPlayed }) {
            activeSave = latestSave
            selection = .game
        } else {
            selection = .saves
        }
    }

    private func applyBattleResult(_ result: BattleResult) {
        guard let activeSave,
            let index = saves.firstIndex(where: { $0.id == activeSave.id })
        else {
            return
        }

        saves[index].lastPlayed = .now
        saves[index].level += max(1, result.xp / 120)
        self.activeSave = saves[index]
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
