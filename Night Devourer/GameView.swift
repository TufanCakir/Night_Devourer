//
//  GameView.swift
//  Night Devourer
//
//  Created by Tufan Cakir on 07.06.26.
//

import SpriteKit
import SwiftUI

struct GameView: View {
    let saveSlot: SaveSlot?
    let onVictory: (BattleResult) -> Void

    @State private var scene = NightGameScene()

    init(
        saveSlot: SaveSlot? = nil,
        onVictory: @escaping (BattleResult) -> Void = { _ in }
    ) {
        self.saveSlot = saveSlot
        self.onVictory = onVictory
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            SpriteView(scene: scene, options: [.allowsTransparency])
                .ignoresSafeArea()

            GameActionButton(
                title: "Schleichen",
                systemImage: "eye.slash.fill",
                isPrimary: true
            ) {
                scene.sneak()
            }
            .frame(width: 230)
            .padding(.bottom, 92)
        }
        .onAppear {
            scene.scaleMode = .resizeFill
            scene.setSaveSlot(saveSlot)
            scene.onVictory = onVictory
        }
    }
}

private struct GameActionButton: View {
    let title: String
    let systemImage: String
    var isPrimary = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            StaticBandageSurface(isActive: isPrimary, compact: true) {
                HStack(spacing: 8) {
                    Image(systemName: systemImage)
                        .font(.system(size: 13, weight: .bold))
                    Text(title.uppercased())
                        .font(.system(size: 12, weight: .black, design: .serif))
                        .tracking(0.9)
                }
                .foregroundStyle(
                    isPrimary
                        ? Color.white
                        : Color(red: 0.13, green: 0.12, blue: 0.11)
                )
            }
            .frame(height: 46)
        }
        .buttonStyle(.plain)
    }
}

final class NightGameScene: SKScene {
    private let worldNode = SKNode()
    private let frontLayer = SKNode()
    private let roadLayer = SKNode()
    private let bandageLayer = SKNode()
    private let playerNode = SKSpriteNode(imageNamed: "nightt_devourer")
    private let enemyImageName = "things"
    private lazy var enemyNode = SKSpriteNode(imageNamed: enemyImageName)
    private let statusLabel = SKLabelNode(fontNamed: "Georgia-Bold")

    private var isSneaking = false
    private var isResolvingAttack = false
    private var defeatedEnemies = 0
    private let targetEnemyCount = 3
    private var lastUpdateTime: TimeInterval = 0
    private var enemyDepth: CGFloat = 0.46
    private let roadSpeed: CGFloat = 0.42
    private let enemySpeed: CGFloat = 0.065
    private var saveSlot: SaveSlot?
    var onVictory: ((BattleResult) -> Void)?

    func setSaveSlot(_ saveSlot: SaveSlot?) {
        self.saveSlot = saveSlot

        if let saveSlot {
            setStatus(saveSlot.name.uppercased())
        }
    }

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        view.preferredFramesPerSecond = 60
        view.ignoresSiblingOrder = true

        if worldNode.parent == nil {
            addChild(worldNode)
            worldNode.addChild(frontLayer)
            worldNode.addChild(roadLayer)
            worldNode.addChild(bandageLayer)
            configureBackgrounds()
            configureRoad()
            configureBandageLanes()
            configurePlayer()
            configureEnemy()
            configureStatusLabel()
        }

        layoutScene()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        layoutScene()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        let touchedNodes = nodes(at: location)

        if let bandage = touchedNodes.first(where: {
            $0.name == "attackBandage"
        }) as? SKShapeNode {
            bandageAttack(using: bandage)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        guard size.width > 0, size.height > 0 else { return }
        guard defeatedEnemies < targetEnemyCount else { return }

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }

        let deltaTime = min(CGFloat(currentTime - lastUpdateTime), 1 / 30)
        lastUpdateTime = currentTime

        updateRoadDepth(deltaTime: deltaTime)
        updateEnemyDepth(deltaTime: deltaTime)
    }

    func sneak() {
        guard !isResolvingAttack else { return }
        isSneaking = true

        playerNode.removeAction(forKey: "sneak")
        playerNode.run(
            .group([
                .fadeAlpha(to: 0.62, duration: 0.18),
                .scale(to: playerScale * 0.96, duration: 0.18),
            ]),
            withKey: "sneak"
        )

        setStatus("SCHLEICHEN")
        layoutBandageLanes()
    }

    private func bandageAttack(using bandage: SKShapeNode) {
        guard !isResolvingAttack else { return }

        guard isSneaking else {
            setStatus("ERST SCHLEICHEN")
            pulseBandageWarning(bandage)
            return
        }

        guard enemyDepth > 0.50 else {
            setStatus("WARTEN")
            pulseBandageWarning(bandage)
            return
        }

        isResolvingAttack = true
        isSneaking = false
        layoutBandageLanes()
        consumeBandage(bandage)
        performSuccessfulAttack()
    }

    private func consumeBandage(_ bandage: SKShapeNode) {
        bandage.removeAllActions()
        bandage.run(
            .sequence([
                .group([
                    .scale(to: 1.35, duration: 0.10),
                    .fadeOut(withDuration: 0.10),
                ]),
                .wait(forDuration: 0.35),
                .run { [weak self, weak bandage] in
                    bandage?.setScale(1)
                    bandage?.alpha = self?.isSneaking == true ? 0.94 : 0.58
                },
            ])
        )
    }

    private func pulseBandageWarning(_ bandage: SKShapeNode) {
        bandage.removeAction(forKey: "warning")
        bandage.run(
            .sequence([
                .colorize(with: .red, colorBlendFactor: 0.55, duration: 0.08),
                .colorize(withColorBlendFactor: 0, duration: 0.16),
            ]),
            withKey: "warning"
        )
    }

    private func configureBackgrounds() {
        makeBackground(
            imageName: "nd_bg_1",
            in: frontLayer,
            zPosition: -35,
            alpha: 1.0
        )
    }

    private func makeBackground(
        imageName: String,
        in layer: SKNode,
        zPosition: CGFloat,
        alpha: CGFloat
    ) {
        layer.zPosition = zPosition

        let node = SKSpriteNode(imageNamed: imageName)
        node.name = "background"
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        node.alpha = alpha
        layer.addChild(node)
    }

    private func configureRoad() {
        roadLayer.zPosition = -10

        for index in 0..<9 {
            let stripe = SKShapeNode()
            stripe.name = "roadStripe"
            stripe.strokeColor = SKColor(
                red: 0.78,
                green: 0.76,
                blue: 0.68,
                alpha: 0.12
            )
            stripe.lineWidth = 1.2
            stripe.alpha = CGFloat(9 - index) / 12
            roadLayer.addChild(stripe)
        }

        for index in 0..<7 {
            let depthMark = SKShapeNode()
            depthMark.name = "depthMark"
            depthMark.strokeColor = SKColor(
                red: 0.72,
                green: 0.70,
                blue: 0.63,
                alpha: 0.12
            )
            depthMark.lineWidth = 1.0
            depthMark.alpha = CGFloat(index + 2) / 12
            depthMark.userData = ["progress": CGFloat(index + 1) / 8]
            roadLayer.addChild(depthMark)
        }
    }

    private func configureBandageLanes() {
        bandageLayer.zPosition = 12

        for index in 0..<9 {
            let bandage = SKShapeNode()
            bandage.name = "attackBandage"
            bandage.fillColor = SKColor(
                red: 0.78,
                green: 0.76,
                blue: 0.68,
                alpha: 0.86
            )
            bandage.strokeColor = SKColor(
                red: 0.05,
                green: 0.045,
                blue: 0.04,
                alpha: 0.78
            )
            bandage.lineWidth = 1.5
            bandage.userData = [
                "depth": CGFloat(0.42 + Double(index % 3) * 0.10),
                "side": CGFloat([-0.52, 0, 0.52][index / 3]),
            ]
            bandageLayer.addChild(bandage)
        }
    }

    private func configurePlayer() {
        playerNode.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        playerNode.alpha = 0.82
        playerNode.zPosition = 10
        worldNode.addChild(playerNode)
    }

    private func configureEnemy() {
        enemyNode.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        enemyNode.alpha = 0.86
        enemyNode.zPosition = 6
        worldNode.addChild(enemyNode)
    }

    private func configureStatusLabel() {
        statusLabel.text = "SCHLEICHE DICH AN"
        statusLabel.fontSize = 15
        statusLabel.fontColor = SKColor(
            red: 0.88,
            green: 0.86,
            blue: 0.78,
            alpha: 0.82
        )
        statusLabel.zPosition = 30
        statusLabel.horizontalAlignmentMode = .center
        worldNode.addChild(statusLabel)
    }

    private func layoutScene() {
        guard size.width > 0, size.height > 0 else { return }

        layoutBackground(layer: frontLayer)
        layoutRoad()
        layoutBandageLanes()

        playerNode.setScale(playerScale)
        playerNode.position = CGPoint(
            x: size.width * 0.5,
            y: size.height * 0.005
        )

        layoutEnemy()

        statusLabel.position = CGPoint(
            x: size.width * 0.5,
            y: size.height * 0.60
        )
    }

    private func layoutBackground(layer: SKNode) {
        let nodes = layer.children.compactMap { $0 as? SKSpriteNode }
        let targetHeight = size.height * 1.04

        for node in nodes {
            let scale = max(
                size.width / node.textureSize.width,
                targetHeight / node.textureSize.height
            )
            node.size = CGSize(
                width: node.textureSize.width * scale,
                height: node.textureSize.height * scale
            )
            node.xScale = abs(node.xScale)
            node.yScale = abs(node.yScale)
            node.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        }
    }

    private func layoutRoad() {
        let horizon = CGPoint(x: size.width * 0.5, y: size.height * 0.60)
        let bottomY = size.height * 0.08
        let bottomHalfWidth = size.width * 0.52

        let stripes = roadLayer.children.filter { $0.name == "roadStripe" }
            .compactMap { $0 as? SKShapeNode }
        for (index, stripe) in stripes.enumerated() {
            let offset = CGFloat(index - 4) / 4
            let bottomX = size.width * 0.5 + offset * bottomHalfWidth
            let horizonX = horizon.x + offset * size.width * 0.035

            let path = CGMutablePath()
            path.move(to: CGPoint(x: horizonX, y: horizon.y))
            path.addLine(to: CGPoint(x: bottomX, y: bottomY))
            stripe.path = path
        }

        let marks = roadLayer.children.filter { $0.name == "depthMark" }
            .compactMap { $0 as? SKShapeNode }
        for mark in marks {
            let progress = mark.userData?["progress"] as? CGFloat ?? 0.1
            layoutDepthMark(mark, progress: progress)
        }
    }

    private func updateRoadDepth(deltaTime: CGFloat) {
        updateDepthNodes(named: "depthMark", deltaTime: deltaTime) {
            [weak self] node, progress in
            self?.layoutDepthMark(node, progress: progress)
        }
    }

    private func updateDepthNodes(
        named name: String,
        deltaTime: CGFloat,
        layout: (SKShapeNode, CGFloat) -> Void
    ) {
        let nodes = roadLayer.children.filter { $0.name == name }.compactMap {
            $0 as? SKShapeNode
        }

        for node in nodes {
            let currentProgress = node.userData?["progress"] as? CGFloat ?? 0
            var nextProgress = currentProgress + deltaTime * roadSpeed

            if nextProgress > 1 {
                nextProgress -= 1
            }

            node.userData?["progress"] = nextProgress
            layout(node, nextProgress)
        }
    }

    private func layoutDepthMark(_ mark: SKShapeNode, progress: CGFloat) {
        let curved = progress * progress
        let left = roadPoint(depth: progress, side: -0.68)
        let right = roadPoint(depth: progress, side: 0.68)

        let path = CGMutablePath()
        path.move(to: left)
        path.addLine(to: right)

        mark.path = path
        mark.lineWidth = 0.8 + curved * 2.4
        mark.alpha = 0.12 + curved * 0.30
        mark.zPosition = curved * 7 + 0.5
    }

    private func roadPoint(depth: CGFloat, side: CGFloat) -> CGPoint {
        let curved = depth * depth
        let horizon = CGPoint(x: size.width * 0.5, y: size.height * 0.66)
        let frontY = size.height * 0.20
        let halfWidth = size.width * (0.035 + curved * 0.47)
        let y = horizon.y - curved * (horizon.y - frontY)

        return CGPoint(
            x: horizon.x + side * halfWidth,
            y: y
        )
    }

    private func layoutBandageLanes() {
        let bandages = bandageLayer.children.filter {
            $0.name == "attackBandage"
        }.compactMap { $0 as? SKShapeNode }

        for (index, bandage) in bandages.enumerated() {
            let depth = bandage.userData?["depth"] as? CGFloat ?? 0.5
            let side = bandage.userData?["side"] as? CGFloat ?? 0
            let center = roadPoint(depth: depth, side: side)
            let curved = depth * depth
            let width = size.width * (0.13 + curved * 0.14)
            let height = width * 0.28
            let tilt = CGFloat(index % 2 == 0 ? -1 : 1) * width * 0.10

            let rect = CGRect(
                x: -width * 0.5,
                y: -height * 0.5,
                width: width,
                height: height
            )
            bandage.path = bandagePath(in: rect, tilt: tilt)
            bandage.position = center
            bandage.alpha = isSneaking ? 0.94 : 0.58
            bandage.zPosition = 2 + curved * 9
        }
    }

    private func bandagePath(in rect: CGRect, tilt: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: rect.minX + 8, y: rect.midY + tilt * 0.10))
        path.addLine(
            to: CGPoint(x: rect.minX + rect.width * 0.18, y: rect.minY + 2)
        )
        path.addLine(
            to: CGPoint(
                x: rect.maxX - rect.width * 0.12,
                y: rect.minY + abs(tilt) * 0.06
            )
        )
        path.addLine(to: CGPoint(x: rect.maxX - 4, y: rect.midY + tilt * 0.08))
        path.addLine(
            to: CGPoint(x: rect.maxX - rect.width * 0.16, y: rect.maxY - 2)
        )
        path.addLine(
            to: CGPoint(
                x: rect.minX + rect.width * 0.12,
                y: rect.maxY - abs(tilt) * 0.05
            )
        )
        path.closeSubpath()
        return path
    }

    private func updateEnemyDepth(deltaTime: CGFloat) {
        guard !isResolvingAttack else { return }

        enemyDepth += deltaTime * enemySpeed

        if enemyDepth > 0.66 {
            enemyDepth = 0.66
            let warning = isSneaking ? "JETZT" : "ZU NAH"
            if statusLabel.text != warning {
                setStatus(warning)
            }
        }

        layoutEnemy()
    }

    private func layoutEnemy() {
        let horizon = CGPoint(x: size.width * 0.5, y: size.height * 0.72)
        let near = CGPoint(x: size.width * 0.5, y: size.height * 0.49)
        let curved = enemyDepth * enemyDepth
        let x = horizon.x + (near.x - horizon.x) * curved
        let y = horizon.y + (near.y - horizon.y) * curved
        let scale = enemyScale * (0.42 + curved * 0.54)

        enemyNode.position = CGPoint(x: x, y: y)
        enemyNode.setScale(scale)
        enemyNode.alpha = 0.35 + curved * 0.65
        enemyNode.zPosition = 4 + curved * 5
    }

    private func performSuccessfulAttack() {
        setStatus("HINTERHALT")

        let lunge = SKAction.group([
            .moveBy(x: 0, y: size.height * 0.06, duration: 0.14),
            .scale(to: playerScale * 1.08, duration: 0.14),
        ])
        lunge.timingMode = .easeOut

        let returnMove = SKAction.group([
            .move(
                to: CGPoint(x: size.width * 0.5, y: size.height * 0.005),
                duration: 0.22
            ),
            .scale(to: playerScale, duration: 0.22),
            .fadeAlpha(to: 0.70, duration: 0.22),
        ])
        returnMove.timingMode = .easeInEaseOut

        let enemyDefeat = SKAction.sequence([
            .group([
                .fadeOut(withDuration: 0.18),
                .scale(to: enemyScale * 0.72, duration: 0.18),
            ]),
            .run { [weak self] in
                self?.advanceAfterDefeat()
            },
        ])

        playerNode.run(.sequence([lunge, returnMove]))
        enemyNode.run(enemyDefeat)
    }

    private func performFailedAttack() {
        setStatus("ZU LAUT")

        let flash = SKAction.sequence([
            .colorize(with: .red, colorBlendFactor: 0.55, duration: 0.08),
            .colorize(withColorBlendFactor: 0, duration: 0.18),
            .wait(forDuration: 0.22),
            .run { [weak self] in
                self?.isResolvingAttack = false
                self?.isSneaking = false
                self?.layoutBandageLanes()
                self?.setStatus("ERST SCHLEICHEN")
            },
        ])

        playerNode.run(flash)
    }

    private func advanceAfterDefeat() {
        defeatedEnemies += 1
        pulseForwardFeedback()

        if defeatedEnemies >= targetEnemyCount {
            finishBattle()
        } else {
            spawnNextEnemy()
            setStatus("RUNDE \(defeatedEnemies + 1)")
        }
    }

    private func finishBattle() {
        isResolvingAttack = true
        setStatus("VICTORY")

        run(
            .sequence([
                .wait(forDuration: 0.65),
                .run { [weak self] in
                    guard let self else { return }
                    self.onVictory?(
                        BattleResult.rewards(for: self.defeatedEnemies)
                    )
                },
            ])
        )
    }

    private func pulseForwardFeedback() {
        let duration: TimeInterval = 0.35

        for node in frontLayer.children.compactMap({ $0 as? SKSpriteNode }) {
            let pulse = SKAction.sequence([
                .moveBy(
                    x: 0,
                    y: -size.height * 0.006,
                    duration: duration * 0.45
                ),
                .moveBy(
                    x: 0,
                    y: size.height * 0.006,
                    duration: duration * 0.55
                ),
            ])
            pulse.timingMode = .easeInEaseOut
            node.run(pulse)
        }
    }

    private func hideEnemyForDepthSpawn() {
        enemyDepth = 0.34
        layoutEnemy()
    }

    private func spawnNextEnemy() {
        enemyNode.removeAllActions()
        hideEnemyForDepthSpawn()
        isResolvingAttack = false
        setStatus("ZIEL \(defeatedEnemies + 1)")
    }

    private func setStatus(_ text: String) {
        statusLabel.text = text
        statusLabel.removeAction(forKey: "pulse")
        statusLabel.run(
            .sequence([
                .fadeAlpha(to: 1, duration: 0.08),
                .wait(forDuration: 0.45),
                .fadeAlpha(to: 0.78, duration: 0.28),
            ]),
            withKey: "pulse"
        )
    }

    private var playerScale: CGFloat {
        min(size.width / 620, size.height / 980) * 0.38
    }

    private var enemyScale: CGFloat {
        min(size.width / 620, size.height / 980) * 0.30
    }

}

extension SKSpriteNode {
    fileprivate var textureSize: CGSize {
        texture?.size() ?? CGSize(width: 1, height: 1)
    }
}

#Preview {
    GameView()
}
