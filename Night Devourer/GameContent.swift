//
//  GameContent.swift
//  Night Devourer
//
//  Created by Tufan Cakir on 08.06.26.
//

import Foundation

struct StoryChapterCatalog: Decodable {
    let chapters: [StoryChapter]
}

struct CharacterCatalog: Decodable {
    let characters: [GameCharacter]
}

struct StoryChapter: Identifiable, Decodable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let previewImage: String
    let backgroundImage: String
    let enemyIds: [String]
    let reward: ChapterReward
    let drops: [CurrencyDrop]
}

struct ChapterReward: Decodable, Equatable {
    let xp: Int
    let coins: Int
    let crystals: Int
    let ruby: Int
    let saphir: Int
    let smaragd: Int
    let diamond: Int
}

struct CurrencyDrop: Decodable, Equatable {
    let currency: String
    let min: Int
    let max: Int
}

struct GameCharacter: Identifiable, Decodable, Equatable {
    let id: String
    let name: String
    let assetName: String
    let role: CharacterRole
    let baseHealth: Int
    let baseDamage: Int
}

enum CharacterRole: String, Decodable, Equatable {
    case player
    case enemy
}

struct BattleConfig: Equatable {
    let chapter: StoryChapter
    let player: GameCharacter
    let enemies: [GameCharacter]

    var backgroundImage: String { chapter.backgroundImage }
    var targetEnemyCount: Int { max(1, enemies.count) }

    static let fallback = BattleConfig(
        chapter: StoryChapter(
            id: "fallback",
            title: "Verlassene Gasse",
            subtitle: "Story 1-1",
            previewImage: "nd_bg_1",
            backgroundImage: "nd_bg_1",
            enemyIds: ["wrapped_scout", "wrapped_scout", "wrapped_brute"],
            reward: ChapterReward(
                xp: 135,
                coins: 240,
                crystals: 6,
                ruby: 1,
                saphir: 0,
                smaragd: 0,
                diamond: 0
            ),
            drops: []
        ),
        player: GameCharacter(
            id: "player_night_devourer",
            name: "Night Devourer",
            assetName: "nightt_devourer",
            role: .player,
            baseHealth: 733,
            baseDamage: 34
        ),
        enemies: [
            GameCharacter(
                id: "wrapped_scout",
                name: "Wrapped Scout",
                assetName: "things",
                role: .enemy,
                baseHealth: 90,
                baseDamage: 12
            )
        ]
    )
}

enum GameContentStore {
    static func loadChapters() -> [StoryChapter] {
        load(StoryChapterCatalog.self, resource: "StoryChapters")?.chapters
            ?? BattleConfig.fallback.chapter.asArray
    }

    static func loadCharacters() -> [GameCharacter] {
        load(CharacterCatalog.self, resource: "Characters")?.characters ?? [
            BattleConfig.fallback.player
        ] + BattleConfig.fallback.enemies
    }

    static func makeBattleConfig(for chapter: StoryChapter) -> BattleConfig {
        let characters = loadCharacters()
        let player =
            characters.first(where: { $0.role == .player })
            ?? BattleConfig.fallback.player
        let enemies = chapter.enemyIds.compactMap { enemyId in
            characters.first(where: { $0.id == enemyId })
        }

        return BattleConfig(
            chapter: chapter,
            player: player,
            enemies: enemies.isEmpty ? BattleConfig.fallback.enemies : enemies
        )
    }

    private static func load<T: Decodable>(_ type: T.Type, resource: String)
        -> T?
    {
        guard
            let url = Bundle.main.url(
                forResource: resource,
                withExtension: "json"
            )
        else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }
}

extension StoryChapter {
    fileprivate var asArray: [StoryChapter] { [self] }
}
