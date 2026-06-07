//
//  MenüVie.swift
//  Night Devourer
//
//  Created by Tufan Cakir on 07.06.26.
//

import SwiftUI

struct MenüVie: View {
    @Binding var selectedItem: String

    private let menuItems = [
        "Fortsetzen", "Neues Spiel", "Optionen", "Verlassen",
    ]

    init(selectedItem: Binding<String> = .constant("Neues Spiel")) {
        self._selectedItem = selectedItem
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("nightt_devourer")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: min(geometry.size.width * 0.68, 600),
                        height: geometry.size.height * 1.02
                    )
                    .opacity(0.78)
                    .shadow(color: .black.opacity(0.9), radius: 42, y: 30)
                    .offset(
                        x: geometry.size.width > 760
                            ? geometry.size.width * 0.21 : 0,
                        y: geometry.size.height * 0.06
                    )
                    .allowsHitTesting(false)

                VStack(
                    alignment: geometry.size.width > 760 ? .leading : .center,
                    spacing: 26
                ) {
                    NightTitle()

                    VStack(spacing: 15) {
                        ForEach(menuItems, id: \.self) { item in
                            BandageButton(
                                title: item,
                                isSelected: selectedItem == item
                            ) {
                                selectedItem = item
                            }
                        }
                    }
                    .frame(width: min(geometry.size.width - 48, 340))
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: menuAlignment(for: geometry.size)
                )
                .padding(.horizontal, geometry.size.width > 760 ? 72 : 24)
                .padding(.vertical, 38)
                .offset(y: geometry.size.width > 760 ? -44 : -24)
            }
        }
    }

    private func menuAlignment(for size: CGSize) -> Alignment {
        size.width > 760 ? .leading : .center
    }
}

#Preview {
    ZStack {
        NightBackground()
        MenüVie()
    }
}
