//
//  ChapterSelectionViewModel.swift
//  Night Devourer
//
//  Created by Tufan Cakir on 08.06.26.
//

import Foundation

@Observable
final class ChapterSelectionViewModel {
    private(set) var chapters: [StoryChapter] = []
    var selectedChapter: StoryChapter?

    init() {
        load()
    }

    func load() {
        chapters = GameContentStore.loadChapters()
        selectedChapter = selectedChapter ?? chapters.first
    }

    func select(_ chapter: StoryChapter) {
        selectedChapter = chapter
    }

    func battleConfig(for chapter: StoryChapter) -> BattleConfig {
        GameContentStore.makeBattleConfig(for: chapter)
    }
}
