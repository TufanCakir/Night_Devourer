//
//  BandageUI.swift
//  Night Devourer
//
//  Created by Tufan Cakir on 07.06.26.
//

import SwiftUI

struct NightBackground: View {
    private let particles: [DustParticle] = DustParticle.makeField(count: 64)

    var body: some View {
        ZStack {
            NightTheme.deepBlack

            RadialGradient(
                colors: [
                    Color(red: 0.19, green: 0.20, blue: 0.19).opacity(0.74),
                    Color.black.opacity(0.98),
                ],
                center: .center,
                startRadius: 40,
                endRadius: 740
            )

            ForEach(particles) { particle in
                Circle()
                    .fill(NightTheme.bone.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .position(x: particle.x, y: particle.y)
            }
        }
        .ignoresSafeArea()
    }
}

struct NightTitle: View {
    var compact = false

    var body: some View {
        VStack(alignment: .center, spacing: compact ? -2 : 2) {
            Text("NIGHT")
                .font(
                    .system(
                        size: compact ? 22 : 54,
                        weight: .black,
                        design: .serif
                    )
                )
            Text("DEVOURER")
                .font(
                    .system(
                        size: compact ? 24 : 58,
                        weight: .black,
                        design: .serif
                    )
                )
        }
        .foregroundStyle(NightTheme.titleGradient)
        .shadow(
            color: NightTheme.driedBlood.opacity(0.35),
            radius: compact ? 7 : 14
        )
        .padding(.bottom, 50)
    }
}

struct NightLogoMark: View {
    var body: some View {
        Image("nd_logo")
            .resizable()
            .scaledToFit()
            .frame(width: 92, height: 92)
            .shadow(color: .black.opacity(0.75), radius: 18, y: 8)
            .shadow(color: NightTheme.driedBlood.opacity(0.32), radius: 10)
    }
}

struct StaticBandageSurface<Content: View>: View {
    let isActive: Bool
    var compact = false
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            TornBandageShape()
                .fill(NightTheme.bandageGradient)
                .shadow(
                    color: .black.opacity(0.75),
                    radius: compact ? 8 : 14,
                    y: compact ? 5 : 8
                )

            TornBandageShape()
                .stroke(Color.black.opacity(0.72), lineWidth: 1.3)

            BandageThreads()
                .stroke(Color.black.opacity(0.27), lineWidth: compact ? 0.8 : 1)
                .padding(.horizontal, compact ? 12 : 18)

            if isActive {
                Rectangle()
                    .fill(NightTheme.driedBlood.opacity(0.72))
                    .frame(height: compact ? 1.5 : 2)
                    .blur(radius: 0.5)
                    .padding(.horizontal, compact ? 20 : 32)
                    .offset(y: compact ? 9 : 12)
            }

            content
        }
    }
}

struct GlobalBandageHeader: View {
    let currentTab: AppTab

    @State private var showsCurrencies = false

    private let coins = 1240
    private let crystals = 86
    private let level = 12
    private let xpProgress = 0.62

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                ResourceChip(
                    systemImage: "circle.hexagongrid.fill",
                    value: coins,
                    tint: Color(red: 0.94, green: 0.78, blue: 0.32)
                )
                ResourceChip(
                    systemImage: "diamond.fill",
                    value: crystals,
                    tint: Color(red: 0.44, green: 0.83, blue: 1.0)
                )

                Spacer(minLength: 8)

                Button {
                    showsCurrencies = true
                } label: {
                    StaticBandageSurface(isActive: true, compact: true) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.white)
                    }
                    .frame(width: 54, height: 32)
                }
                .buttonStyle(.plain)
            }

            StaticBandageSurface(isActive: false, compact: true) {
                HStack(spacing: 10) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(
                            Color(red: 0.13, green: 0.12, blue: 0.11)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("LEVEL \(level)")
                            .font(
                                .system(
                                    size: 11,
                                    weight: .black,
                                    design: .serif
                                )
                            )
                            .tracking(0.8)

                        XPBar(progress: xpProgress)
                    }
                    .foregroundStyle(Color(red: 0.13, green: 0.12, blue: 0.11))

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 22)
            }
            .frame(height: 42)
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
        .padding(.bottom, 12)
        .background(
            LinearGradient(
                colors: [.black.opacity(0.82), .black.opacity(0.0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)
        )
        .sheet(isPresented: $showsCurrencies) {
            CurrencyOverviewSheet()
        }
    }
}

private struct ResourceChip: View {
    let systemImage: String
    let value: Int
    let tint: Color

    var body: some View {
        StaticBandageSurface(isActive: false, compact: true) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(tint)
                Text(value.formatted())
                    .font(.system(size: 12, weight: .black, design: .serif))
                    .foregroundStyle(Color(red: 0.13, green: 0.12, blue: 0.11))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .padding(.horizontal, 14)
        }
        .frame(minWidth: 96, maxWidth: 124, minHeight: 32, maxHeight: 32)
    }
}

private struct XPBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.black.opacity(0.55))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                NightTheme.driedBlood,
                                NightTheme.bone.opacity(0.82),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: geometry.size.width * min(max(progress, 0), 1)
                    )
            }
        }
        .frame(height: 6)
        .overlay(
            Capsule()
                .stroke(Color.black.opacity(0.38), lineWidth: 1)
        )
    }
}

private struct CurrencyOverviewSheet: View {
    private let currencies: [CurrencyBalance] = [
        CurrencyBalance(
            name: "Coins",
            value: 1240,
            systemImage: "circle.hexagongrid.fill",
            tint: Color(red: 0.94, green: 0.78, blue: 0.32)
        ),
        CurrencyBalance(
            name: "Crystals",
            value: 86,
            systemImage: "diamond.fill",
            tint: Color(red: 0.44, green: 0.83, blue: 1.0)
        ),
        CurrencyBalance(
            name: "Ruby",
            value: 14,
            systemImage: "suit.diamond.fill",
            tint: Color(red: 0.86, green: 0.08, blue: 0.12)
        ),
        CurrencyBalance(
            name: "Saphir",
            value: 9,
            systemImage: "drop.fill",
            tint: Color(red: 0.18, green: 0.39, blue: 0.95)
        ),
        CurrencyBalance(
            name: "Smaragd",
            value: 6,
            systemImage: "leaf.fill",
            tint: Color(red: 0.10, green: 0.68, blue: 0.34)
        ),
        CurrencyBalance(
            name: "Diamond",
            value: 2,
            systemImage: "sparkle",
            tint: Color(red: 0.76, green: 0.94, blue: 1.0)
        ),
    ]

    var body: some View {
        ZStack {
            NightBackground()

            VStack(alignment: .leading, spacing: 18) {
                StaticBandageSurface(isActive: true) {
                    Text("WAEHRUNGEN")
                        .font(.system(size: 18, weight: .black, design: .serif))
                        .tracking(1.5)
                        .foregroundStyle(Color.white)
                }
                .frame(height: 54)

                VStack(spacing: 10) {
                    ForEach(currencies) { currency in
                        CurrencyRow(currency: currency)
                    }
                }
            }
            .padding(24)
        }
        .presentationBackground(.black)
        .presentationDetents([.medium])
    }
}

private struct CurrencyBalance: Identifiable {
    let id = UUID()
    let name: String
    let value: Int
    let systemImage: String
    let tint: Color
}

private struct CurrencyRow: View {
    let currency: CurrencyBalance

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: currency.systemImage)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(currency.tint)
                .frame(width: 30)

            Text(currency.name.uppercased())
                .font(.system(size: 13, weight: .bold, design: .serif))
                .tracking(1.0)
                .foregroundStyle(Color(red: 0.13, green: 0.12, blue: 0.11))

            Spacer()

            Text(currency.value.formatted())
                .font(.system(size: 15, weight: .black, design: .serif))
                .foregroundStyle(Color(red: 0.13, green: 0.12, blue: 0.11))
                .padding(.horizontal)
                .padding()
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
        .background {
            StaticBandageSurface(isActive: false, compact: true) {
                EmptyView()
            }
        }
    }
}

struct GlobalBandageFooter: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 10) {
            ForEach(AppTab.allCases) { tab in
                BandageTabButton(
                    title: tab.title,
                    systemImage: tab.systemImage,
                    isSelected: selection == tab
                ) {
                    selection = tab
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.black.opacity(0.0), .black.opacity(0.88)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
        )
    }
}

struct BandageButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovering = false

    init(title: String, isSelected: Bool = false, action: @escaping () -> Void)
    {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            StaticBandageSurface(isActive: isHovering || isSelected) {
                Text(title.uppercased())
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .tracking(1.6)
                    .foregroundStyle(
                        isHovering || isSelected
                            ? Color.white
                            : Color(red: 0.12, green: 0.11, blue: 0.10)
                    )
                    .shadow(
                        color: isHovering || isSelected
                            ? .black.opacity(0.82) : .clear,
                        radius: 4
                    )
                    .offset(y: isHovering || isSelected ? -3 : 0)
            }
            .frame(height: 56)
            .scaleEffect(isHovering || isSelected ? 1.035 : 1)
            .animation(.easeOut(duration: 0.18), value: isHovering)
            .animation(.easeOut(duration: 0.18), value: isSelected)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

private struct BandageTabButton: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            StaticBandageSurface(
                isActive: isSelected || isHovering,
                compact: true
            ) {
                HStack(spacing: 7) {
                    Image(systemName: systemImage)
                        .font(.system(size: 13, weight: .semibold))
                    Text(title.uppercased())
                        .font(.system(size: 11, weight: .bold, design: .serif))
                        .tracking(0.9)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                .foregroundStyle(
                    isSelected || isHovering
                        ? Color.white
                        : Color(red: 0.13, green: 0.12, blue: 0.11)
                )
                .offset(y: isSelected ? -2 : 0)
            }
            .frame(height: 44)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

private struct TornBandageLabel: View {
    let text: String
    let isActive: Bool

    var body: some View {
        StaticBandageSurface(isActive: isActive, compact: true) {
            Text(text.uppercased())
                .font(.system(size: 12, weight: .bold, design: .serif))
                .tracking(1.2)
                .foregroundStyle(Color.white)
                .offset(y: -1)
        }
        .frame(height: 42)
    }
}

private struct DustParticle: Identifiable {
    let id: Int
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double

    static func makeField(count: Int) -> [DustParticle] {
        var field: [DustParticle] = []

        for index in 0..<count {
            let xPosition = CGFloat((index * 47) % 1000)
            let yPosition = CGFloat((index * 83) % 760)
            let particleSize = CGFloat(1 + (index % 3))
            let particleOpacity = Double(12 + (index % 18)) / 100

            field.append(
                DustParticle(
                    id: index,
                    x: xPosition,
                    y: yPosition,
                    size: particleSize,
                    opacity: particleOpacity
                )
            )
        }

        return field
    }
}

private struct TornBandageShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX + 18, y: rect.minY + 9))
        path.addLine(to: CGPoint(x: rect.minX + 74, y: rect.minY + 2))
        path.addLine(to: CGPoint(x: rect.midX - 18, y: rect.minY + 8))
        path.addLine(to: CGPoint(x: rect.midX + 44, y: rect.minY + 3))
        path.addLine(to: CGPoint(x: rect.maxX - 14, y: rect.minY + 11))
        path.addLine(to: CGPoint(x: rect.maxX - 32, y: rect.midY - 2))
        path.addLine(to: CGPoint(x: rect.maxX - 8, y: rect.maxY - 10))
        path.addLine(to: CGPoint(x: rect.midX + 38, y: rect.maxY - 3))
        path.addLine(to: CGPoint(x: rect.midX - 22, y: rect.maxY - 8))
        path.addLine(to: CGPoint(x: rect.minX + 26, y: rect.maxY - 3))
        path.addLine(to: CGPoint(x: rect.minX + 8, y: rect.midY + 4))
        path.closeSubpath()

        return path
    }
}

private struct BandageThreads: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.midY - 12))
        path.addLine(to: CGPoint(x: rect.midX - 28, y: rect.midY - 5))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY - 10))

        path.move(to: CGPoint(x: rect.minX + 22, y: rect.midY + 9))
        path.addLine(to: CGPoint(x: rect.midX + 18, y: rect.midY + 2))
        path.addLine(to: CGPoint(x: rect.maxX - 8, y: rect.midY + 8))

        path.move(to: CGPoint(x: rect.minX + 46, y: rect.minY + 11))
        path.addLine(to: CGPoint(x: rect.minX + 88, y: rect.maxY - 9))

        path.move(to: CGPoint(x: rect.maxX - 78, y: rect.minY + 12))
        path.addLine(to: CGPoint(x: rect.maxX - 112, y: rect.maxY - 10))

        return path
    }
}

#Preview {
    RootView()
}
