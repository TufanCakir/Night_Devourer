//
//  ChapterSelectionView.swift
//  Night Devourer
//
//  Created by Tufan Cakir on 08.06.26.
//

import SwiftUI

struct ChapterSelectionView: View {
    @State private var viewModel = ChapterSelectionViewModel()

    let onStart: (BattleConfig) -> Void
    let onBack: () -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 12) {
                Spacer(minLength: geometry.size.height * 0.07)

                NightTitle(compact: true)
                    .scaleEffect(0.82)

                StaticBandageSurface(isActive: true) {
                    Text("STORY CHAPTER")
                        .font(.system(size: 15, weight: .black, design: .serif))
                        .tracking(1.5)
                        .foregroundStyle(Color.white)
                }
                .frame(width: min(geometry.size.width - 56, 300), height: 44)

                TabView(
                    selection: Binding(
                        get: {
                            viewModel.selectedChapter?.id ?? viewModel.chapters
                                .first?.id ?? ""
                        },
                        set: { id in
                            if let chapter = viewModel.chapters.first(where: {
                                $0.id == id
                            }) {
                                viewModel.select(chapter)
                            }
                        }
                    )
                ) {
                    ForEach(viewModel.chapters) { chapter in
                        ChapterCard(
                            chapter: chapter,
                            isSelected: viewModel.selectedChapter == chapter
                        )
                        .padding(.horizontal, 22)
                        .tag(chapter.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .frame(height: min(geometry.size.height * 0.34, 280))

                ChapterGrid(
                    chapters: viewModel.chapters,
                    selectedChapter: viewModel.selectedChapter,
                    onSelect: viewModel.select
                )
                .frame(height: 70)
                .padding(.horizontal, 20)

                HStack(spacing: 12) {
                    Button(action: onBack) {
                        ChapterActionLabel(title: "Zurueck", isActive: false)
                    }
                    .buttonStyle(.plain)

                    Button {
                        if let chapter = viewModel.selectedChapter {
                            onStart(viewModel.battleConfig(for: chapter))
                        }
                    } label: {
                        ChapterActionLabel(title: "Start", isActive: true)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 26)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private struct ChapterCard: View {
    let chapter: StoryChapter
    let isSelected: Bool

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(chapter.previewImage)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .overlay(.black.opacity(0.28))

            LinearGradient(
                colors: [.black.opacity(0.0), .black.opacity(0.82)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(chapter.subtitle.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .serif))
                    .tracking(1.2)
                    .foregroundStyle(NightTheme.bone.opacity(0.76))

                Text(chapter.title.uppercased())
                    .font(.system(size: 20, weight: .black, design: .serif))
                    .tracking(1.2)
                    .foregroundStyle(NightTheme.bone)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)

                HStack(spacing: 10) {
                    RewardBadge(title: "XP", value: chapter.reward.xp)
                    RewardBadge(title: "Coins", value: chapter.reward.coins)
                    RewardBadge(title: "Gegner", value: chapter.enemyIds.count)
                }
            }
            .padding(14)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isSelected
                        ? NightTheme.bone.opacity(0.74)
                        : NightTheme.bone.opacity(0.20),
                    lineWidth: isSelected ? 2 : 1
                )
        )
    }
}

private struct RewardBadge: View {
    let title: String
    let value: Int

    var body: some View {
        StaticBandageSurface(isActive: false, compact: true) {
            Text("\(title.uppercased()) \(value)")
                .font(.system(size: 9, weight: .black, design: .serif))
                .tracking(0.7)
                .foregroundStyle(Color(red: 0.13, green: 0.12, blue: 0.11))
                .padding(.horizontal, 8)
        }
        .frame(width: 82, height: 28)
    }
}

private struct ChapterGrid: View {
    let chapters: [StoryChapter]
    let selectedChapter: StoryChapter?
    let onSelect: (StoryChapter) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(chapters) { chapter in
                    Button {
                        onSelect(chapter)
                    } label: {
                        Image(chapter.previewImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 78, height: 54)
                            .clipped()
                            .overlay(
                                .black.opacity(
                                    selectedChapter == chapter ? 0.05 : 0.45
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(
                                        selectedChapter == chapter
                                            ? NightTheme.bone
                                            : NightTheme.bone.opacity(0.22),
                                        lineWidth: selectedChapter == chapter
                                            ? 2 : 1
                                    )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

private struct ChapterActionLabel: View {
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
        .frame(height: 42)
    }
}

#Preview {
    ZStack {
        NightBackground()
        ChapterSelectionView(onStart: { _ in }, onBack: {})
    }
}
