//
//  BattleRewardHUDFactory.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SpriteKit
import UIKit

enum BattleRewardHUDFactory {
    static func bossVictoryNode(
        rewards: BattleRewardConfig,
        reward: BattleWaveReward,
        sceneSize: CGSize
    ) -> SKNode {
        let container = SKNode()
        container.name = "reward"
        container.zPosition = 900
        container.position = CGPoint(
            x: sceneSize.width / 2,
            y: sceneSize.height * 0.62
        )

        let panel = SKShapeNode(
            rectOf: CGSize(width: min(sceneSize.width - 48, 330), height: 108),
            cornerRadius: 14
        )
        panel.fillColor = SKColor.black.withAlphaComponent(0.72)
        panel.strokeColor = .cyan
        panel.lineWidth = 2
        container.addChild(panel)

        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "Boss besiegt!"
        title.fontSize = 20
        title.position = CGPoint(x: 0, y: 27)
        container.addChild(title)

        let subtitle = SKLabelNode(fontNamed: "AvenirNext-Bold")
        subtitle.text = "Du hast gewonnen"
        subtitle.fontSize = 13
        subtitle.fontColor = .cyan
        subtitle.position = CGPoint(x: 0, y: 8)
        container.addChild(subtitle)

        addRewardIcon("exp", text: "+\(reward.xp)", x: -114, to: container)
        addRewardIcon(
            rewards.coinIcon,
            text: "+\(reward.coins)",
            x: -38,
            to: container
        )
        addRewardIcon(
            rewards.crystalIcon,
            text: "+\(reward.crystals)",
            x: 38,
            to: container
        )
        addRewardIcon(
            rewards.bitIcon ?? "bit",
            text: "+\(reward.bits)",
            x: 114,
            to: container
        )

        container.setScale(0.75)
        container.alpha = 0
        return container
    }

    static func waveRewardNode(reward: BattleWaveReward, sceneSize: CGSize)
        -> SKNode
    {
        let container = SKNode()
        container.name = "reward"
        container.zPosition = 900
        container.position = CGPoint(
            x: sceneSize.width / 2,
            y: sceneSize.height * 0.72
        )

        let panel = SKShapeNode(
            rectOf: CGSize(width: min(sceneSize.width - 80, 260), height: 48),
            cornerRadius: 12
        )
        panel.fillColor = SKColor.black.withAlphaComponent(0.62)
        panel.strokeColor = SKColor.cyan.withAlphaComponent(0.5)
        panel.lineWidth = 1.2
        container.addChild(panel)

        var x: CGFloat = -90
        addRewardIcon("exp", text: "+\(reward.xp)", x: x, to: container)
        x += 62
        if reward.coins > 0 {
            addRewardIcon("coin", text: "+\(reward.coins)", x: x, to: container)
            x += 62
        }
        if reward.crystals > 0 {
            addRewardIcon(
                "crystal",
                text: "+\(reward.crystals)",
                x: x,
                to: container
            )
            x += 62
        }
        if reward.bits > 0 {
            addRewardIcon("bit", text: "+\(reward.bits)", x: x, to: container)
        }

        container.setScale(0.82)
        container.alpha = 0
        return container
    }

    static func presentationAction() -> SKAction {
        .sequence([
            .group([
                .fadeIn(withDuration: 0.18),
                .scale(to: 1, duration: 0.18),
            ]),
            .wait(forDuration: 1.1),
            .fadeOut(withDuration: 0.25),
            .removeFromParent(),
        ])
    }

    private static func addRewardIcon(
        _ resourceId: String,
        text: String,
        x: CGFloat,
        to node: SKNode
    ) {
        let icon = rewardNode(for: resourceId)
        icon.position = CGPoint(x: x - 18, y: -22)
        node.addChild(icon)

        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text = text
        label.fontSize = 14
        label.horizontalAlignmentMode = .left
        label.position = CGPoint(x: x, y: -27)
        node.addChild(label)
    }

    private static func rewardNode(for resourceId: String) -> SKNode {
        let id = resourceId.replacingOccurrences(of: "icon_", with: "")

        if let imageName = resourceImageName(for: resourceId)
            ?? resourceImageName(for: id)
        {
            let texture = texture(named: imageName)
            let node = SKSpriteNode(texture: texture)
            node.size = CGSize(width: 24, height: 24)
            return node
        }

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
        case "bit", "bits":
            let node = SKShapeNode(circleOfRadius: 14)
            node.fillColor = SKColor(red: 0.08, green: 0.66, blue: 1, alpha: 1)
            node.strokeColor = .white
            node.lineWidth = 2
            let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
            label.text = "bit"
            label.fontSize = 9
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            node.addChild(label)
            return node
        default:
            let node = SKShapeNode(circleOfRadius: 14)
            node.fillColor = .systemYellow
            node.strokeColor = .cyan
            node.lineWidth = 2
            return node
        }
    }

    private static func resourceImageName(for resourceId: String) -> String? {
        let normalized = GameCurrency.iconId(for: resourceId)
        guard
            let url = Bundle.main.url(
                forResource: "gameVisual",
                withExtension: "json"
            ),
            let data = try? Data(contentsOf: url),
            let catalog = try? JSONDecoder().decode(
                GameVisualCatalogData.self,
                from: data
            )
        else {
            return nil
        }

        return catalog.resources.first {
            $0.id == resourceId || $0.id == normalized
        }?.imageName
    }

    private static func texture(named imageName: String) -> SKTexture {
        let cachedURL = RemoteContentService.cachedAssetURL(named: imageName)
        if FileManager.default.fileExists(atPath: cachedURL.path()),
            let image = UIImage(contentsOfFile: cachedURL.path())
        {
            return SKTexture(image: image)
        }

        return SKTexture(image: placeholderImage())
    }

    private static func placeholderImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(
            size: CGSize(width: 32, height: 32)
        )
        return renderer.image { context in
            UIColor.clear.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 32, height: 32))
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
