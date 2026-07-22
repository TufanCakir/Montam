//
//  BattleHUDFactory.swift
//  Monster Transorfmieren
//

import SpriteKit

enum BattleHUDFactory {
    static func stageNode(config: BattleConfigData, currentWaveIndex: Int, sceneSize: CGSize) -> SKNode {
        let root = SKNode()
        root.name = "stageHUD"
        root.zPosition = 850
        root.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 44)

        let panelSize = CGSize(width: min(sceneSize.width - 64, 210), height: 54)
        let back = SKShapeNode(rectOf: panelSize, cornerRadius: 12)
        back.fillColor = SKColor.black.withAlphaComponent(0.5)
        back.strokeColor = .cyan
        back.lineWidth = 1.5
        root.addChild(back)

        let dotCount = max(config.waves.count, 1)
        let dotSpacing = min(panelSize.width / CGFloat(dotCount + 1), 28)
        let firstX = -dotSpacing * CGFloat(dotCount - 1) / 2

        for index in 0..<dotCount {
            let dot = SKShapeNode(circleOfRadius: index == currentWaveIndex ? 5.5 : 4)
            dot.fillColor = index <= currentWaveIndex ? .systemYellow : SKColor.white.withAlphaComponent(0.32)
            dot.strokeColor = index == currentWaveIndex ? .white : .clear
            dot.lineWidth = 1
            dot.position = CGPoint(x: firstX + CGFloat(index) * dotSpacing, y: 9)
            root.addChild(dot)
        }

        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text = "Stage \(currentWaveIndex + 1)"
        label.fontSize = 15
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -8)
        root.addChild(label)

        let subtitle = SKLabelNode(fontNamed: "AvenirNext-Bold")
        subtitle.text = config.waves[currentWaveIndex].isBossWave ? "Boss" : "Welle"
        subtitle.fontSize = 10
        subtitle.fontColor = .cyan
        subtitle.verticalAlignmentMode = .center
        subtitle.position = CGPoint(x: 0, y: -22)
        root.addChild(subtitle)

        return root
    }

    static func healthBar(for unit: BattleUnit) -> SKNode {
        let root = SKNode()
        root.name = "healthBar"
        root.position = CGPoint(x: 0, y: unit.node.size.height * 0.58)
        root.zPosition = 20

        let width: CGFloat = unit.node.size.width * 0.72
        let height: CGFloat = 5
        let back = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 2)
        back.fillColor = SKColor.black.withAlphaComponent(0.65)
        back.strokeColor = .clear
        root.addChild(back)

        let currentWidth = width * CGFloat(unit.currentHP) / CGFloat(max(unit.maxHP, 1))
        let front = SKShapeNode(rectOf: CGSize(width: currentWidth, height: height), cornerRadius: 2)
        front.fillColor = unit.side == .player ? .green : .red
        front.strokeColor = .clear
        front.position = CGPoint(x: -(width - currentWidth) / 2, y: 0)
        root.addChild(front)

        return root
    }
}
