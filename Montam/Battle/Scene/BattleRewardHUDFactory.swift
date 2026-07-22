//
//  BattleRewardHUDFactory.swift
//  Monster Transorfmieren
//

import SpriteKit

enum BattleRewardHUDFactory {
    static func bossVictoryNode(rewards: BattleRewardConfig, xpReward: Int, sceneSize: CGSize) -> SKNode {
        let container = SKNode()
        container.name = "reward"
        container.zPosition = 900
        container.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.62)

        let panel = SKShapeNode(rectOf: CGSize(width: min(sceneSize.width - 44, 360), height: 132), cornerRadius: 18)
        panel.fillColor = SKColor.black.withAlphaComponent(0.72)
        panel.strokeColor = .cyan
        panel.lineWidth = 2
        container.addChild(panel)

        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "Boss besiegt!"
        title.fontSize = 24
        title.position = CGPoint(x: 0, y: 34)
        container.addChild(title)

        let subtitle = SKLabelNode(fontNamed: "AvenirNext-Bold")
        subtitle.text = "Du hast gewonnen"
        subtitle.fontSize = 15
        subtitle.fontColor = .cyan
        subtitle.position = CGPoint(x: 0, y: 11)
        container.addChild(subtitle)

        addRewardIcon("exp", text: "+\(xpReward)", x: -108, to: container)
        addRewardIcon(rewards.coinIcon, text: "+\(rewards.coins)", x: 0, to: container)
        addRewardIcon(rewards.crystalIcon, text: "+\(rewards.crystals)", x: 108, to: container)

        container.setScale(0.75)
        container.alpha = 0
        return container
    }

    static func presentationAction() -> SKAction {
        .sequence([
            .group([
                .fadeIn(withDuration: 0.18),
                .scale(to: 1, duration: 0.18)
            ]),
            .wait(forDuration: 1.1),
            .fadeOut(withDuration: 0.25)
        ])
    }

    private static func addRewardIcon(_ resourceId: String, text: String, x: CGFloat, to node: SKNode) {
        let icon = rewardNode(for: resourceId)
        icon.position = CGPoint(x: x - 24, y: -20)
        node.addChild(icon)

        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text = text
        label.fontSize = 17
        label.horizontalAlignmentMode = .left
        label.position = CGPoint(x: x, y: -27)
        node.addChild(label)
    }

    private static func rewardNode(for resourceId: String) -> SKNode {
        let id = resourceId.replacingOccurrences(of: "icon_", with: "")

        switch id {
        case "coin":
            let node = SKShapeNode(circleOfRadius: 14)
            node.fillColor = SKColor(red: 0.08, green: 0.76, blue: 1, alpha: 1)
            node.strokeColor = .white
            node.lineWidth = 2
            return node
        case "crystal":
            let node = SKShapeNode(path: crystalPath(radius: 16))
            node.fillColor = SKColor(red: 0.25, green: 1, blue: 0.58, alpha: 1)
            node.strokeColor = .white
            node.lineWidth = 2
            return node
        default:
            let node = SKShapeNode(circleOfRadius: 14)
            node.fillColor = .systemYellow
            node.strokeColor = .cyan
            node.lineWidth = 2
            return node
        }
    }

    private static func crystalPath(radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: radius))
        path.addLine(to: CGPoint(x: radius, y: radius * 0.3))
        path.addLine(to: CGPoint(x: radius * 0.7, y: -radius))
        path.addLine(to: CGPoint(x: -radius * 0.7, y: -radius))
        path.addLine(to: CGPoint(x: -radius, y: radius * 0.3))
        path.closeSubpath()
        return path
    }
}
