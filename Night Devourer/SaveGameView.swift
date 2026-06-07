//
//  SaveGameView.swift
//  Night Devourer
//
//  Created by Tufan Cakir on 07.06.26.
//

import SwiftUI

struct SaveSlot: Identifiable, Equatable {
    let id: UUID
    var name: String
    var level: Int
    var stage: String
    var lastPlayed: Date

    init(
        id: UUID = UUID(),
        name: String,
        level: Int = 1,
        stage: String = "Story 1-1",
        lastPlayed: Date = .now
    ) {
        self.id = id
        self.name = name
        self.level = level
        self.stage = stage
        self.lastPlayed = lastPlayed
    }
}

struct SaveGameView: View {
    @Binding var saves: [SaveSlot]

    let onLoad: (SaveSlot) -> Void
    let onBack: () -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 18) {
                Spacer(minLength: geometry.size.height * 0.14)

                NightTitle(compact: true)

                StaticBandageSurface(isActive: true) {
                    Text("SPIELSTAENDE")
                        .font(.system(size: 18, weight: .black, design: .serif))
                        .tracking(1.4)
                        .foregroundStyle(Color.white)
                }
                .frame(width: min(geometry.size.width - 44, 340), height: 54)

                ScrollView {
                    VStack(spacing: 12) {
                        Button {
                            createSave()
                        } label: {
                            SaveSlotRow(
                                title: "Neuen Spielstand erstellen",
                                subtitle: "Beginnt eine neue Story",
                                systemImage: "plus.circle.fill",
                                isActive: true
                            )
                        }
                        .buttonStyle(.plain)

                        ForEach(
                            saves.sorted(by: { $0.lastPlayed > $1.lastPlayed })
                        ) { save in
                            Button {
                                load(save)
                            } label: {
                                SaveSlotRow(
                                    title: save.name,
                                    subtitle:
                                        "Level \(save.level) - \(save.stage)",
                                    systemImage: "play.fill",
                                    isActive: false
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 120)
                }

                Button {
                    onBack()
                } label: {
                    StaticBandageSurface(isActive: false, compact: true) {
                        Text("ZURUECK")
                            .font(
                                .system(
                                    size: 12,
                                    weight: .black,
                                    design: .serif
                                )
                            )
                            .tracking(1.1)
                            .foregroundStyle(
                                Color(red: 0.13, green: 0.12, blue: 0.11)
                            )
                    }
                    .frame(width: 180, height: 42)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 92)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func createSave() {
        let save = SaveSlot(name: "Spielstand \(saves.count + 1)")
        saves.append(save)
        onLoad(save)
    }

    private func load(_ save: SaveSlot) {
        if let index = saves.firstIndex(where: { $0.id == save.id }) {
            saves[index].lastPlayed = .now
            onLoad(saves[index])
        } else {
            onLoad(save)
        }
    }
}

private struct SaveSlotRow: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let isActive: Bool

    var body: some View {
        StaticBandageSurface(isActive: isActive, compact: true) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .bold))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title.uppercased())
                        .font(.system(size: 13, weight: .black, design: .serif))
                        .tracking(0.9)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    Text(subtitle.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .serif))
                        .tracking(0.7)
                        .opacity(0.68)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .foregroundStyle(
                isActive
                    ? Color.white : Color(red: 0.13, green: 0.12, blue: 0.11)
            )
            .padding(.horizontal, 22)
        }
        .frame(height: 58)
    }
}

#Preview {
    ZStack {
        NightBackground()
        SaveGameView(
            saves: .constant([
                SaveSlot(name: "Spielstand 1", level: 3, stage: "Story 1-4"),
                SaveSlot(name: "Spielstand 2", level: 8, stage: "Boss 2"),
            ]),
            onLoad: { _ in },
            onBack: {}
        )
    }
}
