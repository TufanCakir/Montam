//
//  BattleHUDFactory.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SpriteKit

enum BattleHUDFactory {
    static func healthBar(for unit: BattleUnit) -> SKNode {
        let root = SKNode()
        root.name = "healthBar"
        root.zPosition = 900

        let visibleWidth = unit.node.frame.width
        let width: CGFloat = max(min(visibleWidth * 0.48, 82), 50)
        let height: CGFloat = 5
        let badgeRadius: CGFloat = 11

        let badge = SKShapeNode(circleOfRadius: badgeRadius)
        badge.fillColor = SKColor.black.withAlphaComponent(0.72)
        badge.strokeColor = unit.side == .player ? .cyan : .systemOrange
        badge.lineWidth = 1.6
        badge.position = CGPoint(x: -width / 2 - badgeRadius - 4, y: 0)
        root.addChild(badge)

        let levelLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        levelLabel.text = "\(unit.level)"
        levelLabel.fontSize = 9
        levelLabel.fontColor = .white
        levelLabel.verticalAlignmentMode = .center
        levelLabel.horizontalAlignmentMode = .center
        badge.addChild(levelLabel)

        let back = SKShapeNode(
            rectOf: CGSize(width: width, height: height),
            cornerRadius: 2
        )
        back.fillColor = SKColor.black.withAlphaComponent(0.65)
        back.strokeColor = .clear
        back.position = CGPoint(x: 4, y: 0)
        root.addChild(back)

        let currentWidth =
            width * CGFloat(unit.currentHP) / CGFloat(max(unit.maxHP, 1))
        let front = SKShapeNode(
            rectOf: CGSize(width: currentWidth, height: height),
            cornerRadius: 2
        )
        front.fillColor = unit.side == .player ? .green : .red
        front.strokeColor = .clear
        front.position = CGPoint(x: 4 - (width - currentWidth) / 2, y: 0)
        root.addChild(front)

        return root
    }
}
