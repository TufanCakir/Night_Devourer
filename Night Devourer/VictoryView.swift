//
//  VictoryView.swift
//  Night Devourer
//
//  Created by Tufan Cakir on 07.06.26.
//

import SwiftUI

struct BattleResult: Equatable {
    let defeatedEnemies: Int
    let xp: Int
    let coins: Int
    let crystals: Int
    let ruby: Int
    let saphir: Int
    let smaragd: Int
    let diamond: Int

    static func rewards(for defeatedEnemies: Int) -> BattleResult {
        BattleResult(
            defeatedEnemies: defeatedEnemies,
            xp: defeatedEnemies * 45,
            coins: defeatedEnemies * 80,
            crystals: max(1, defeatedEnemies * 2),
            ruby: defeatedEnemies >= 3 ? 1 : 0,
            saphir: defeatedEnemies >= 4 ? 1 : 0,
            smaragd: defeatedEnemies >= 5 ? 1 : 0,
            diamond: defeatedEnemies >= 6 ? 1 : 0
        )
    }

    static func rewards(for defeatedEnemies: Int, chapter: StoryChapter)
        -> BattleResult
    {
        BattleResult(
            defeatedEnemies: defeatedEnemies,
            xp: chapter.reward.xp,
            coins: chapter.reward.coins,
            crystals: chapter.reward.crystals,
            ruby: chapter.reward.ruby,
            saphir: chapter.reward.saphir,
            smaragd: chapter.reward.smaragd,
            diamond: chapter.reward.diamond
        )
    }
}

struct VictoryView: View {
    let result: BattleResult
    let onContinue: () -> Void
    let onMenu: () -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 18) {
                Spacer(minLength: geometry.size.height * 0.13)

                NightTitle(compact: true)

                StaticBandageSurface(isActive: true) {
                    Text("VICTORY")
                        .font(.system(size: 22, weight: .black, design: .serif))
                        .tracking(1.8)
                        .foregroundStyle(Color.white)
                }
                .frame(width: min(geometry.size.width - 44, 340), height: 58)

                VStack(spacing: 10) {
                    RewardRow(
                        title: "Gegner",
                        value: result.defeatedEnemies,
                        systemImage: "flame.fill",
                        tint: NightTheme.driedBlood
                    )
                    RewardRow(
                        title: "XP",
                        value: result.xp,
                        systemImage: "star.fill",
                        tint: Color(red: 0.82, green: 0.78, blue: 0.45)
                    )
                    RewardRow(
                        title: "Coins",
                        value: result.coins,
                        systemImage: "circle.hexagongrid.fill",
                        tint: Color(red: 0.94, green: 0.78, blue: 0.32)
                    )
                    RewardRow(
                        title: "Crystals",
                        value: result.crystals,
                        systemImage: "diamond.fill",
                        tint: Color(red: 0.44, green: 0.83, blue: 1.0)
                    )
                    RewardRow(
                        title: "Ruby",
                        value: result.ruby,
                        systemImage: "suit.diamond.fill",
                        tint: Color(red: 0.86, green: 0.08, blue: 0.12)
                    )
                    RewardRow(
                        title: "Saphir",
                        value: result.saphir,
                        systemImage: "drop.fill",
                        tint: Color(red: 0.18, green: 0.39, blue: 0.95)
                    )
                    RewardRow(
                        title: "Smaragd",
                        value: result.smaragd,
                        systemImage: "leaf.fill",
                        tint: Color(red: 0.10, green: 0.68, blue: 0.34)
                    )
                    RewardRow(
                        title: "Diamond",
                        value: result.diamond,
                        systemImage: "sparkle",
                        tint: Color(red: 0.76, green: 0.94, blue: 1.0)
                    )
                }
                .padding(.horizontal, 24)

                HStack(spacing: 12) {
                    Button(action: onMenu) {
                        VictoryButtonLabel(title: "Menu", isActive: false)
                    }
                    .buttonStyle(.plain)

                    Button(action: onContinue) {
                        VictoryButtonLabel(title: "Weiter", isActive: true)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                Spacer(minLength: 28)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private struct RewardRow: View {
    let title: String
    let value: Int
    let systemImage: String
    let tint: Color

    var body: some View {
        StaticBandageSurface(isActive: value > 0, compact: true) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(tint)
                    .frame(width: 24)

                Text(title.uppercased())
                    .font(.system(size: 12, weight: .black, design: .serif))
                    .tracking(0.9)

                Spacer(minLength: 0)

                Text(value.formatted())
                    .font(.system(size: 14, weight: .black, design: .serif))
            }
            .foregroundStyle(
                value > 0
                    ? Color.white : Color(red: 0.13, green: 0.12, blue: 0.11)
            )
            .padding(.horizontal, 20)
        }
        .frame(height: 44)
    }
}

private struct VictoryButtonLabel: View {
    let title: String
    let isActive: Bool

    var body: some View {
        StaticBandageSurface(isActive: isActive, compact: true) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .black, design: .serif))
                .tracking(1.1)
                .foregroundStyle(
                    isActive
                        ? Color.white
                        : Color(red: 0.13, green: 0.12, blue: 0.11)
                )
        }
        .frame(height: 44)
    }
}

#Preview {
    ZStack {
        NightBackground()
        VictoryView(
            result: .rewards(for: 3),
            onContinue: {},
            onMenu: {}
        )
    }
}
