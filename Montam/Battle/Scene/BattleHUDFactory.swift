//
//  BattleHUDFactory.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SpriteKit

enum BattleHUDFactory {
    static func healthBar(for unit: BattleUnit) -> BattleHealthBarNode {
        let healthBar = BattleHealthBarNode()
        healthBar.update(for: unit)
        return healthBar
    }
}

final class BattleHealthBarNode: SKNode {
    private let badge = SKShapeNode()
    private let progressRing = SKShapeNode()
    private let levelLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let back = SKShapeNode()
    private let front = SKShapeNode()
    private var barWidth: CGFloat = 0

    private let height: CGFloat = 5
    private let badgeRadius: CGFloat = 11

    override init() {
        super.init()
        name = "healthBar"
        zPosition = 900
        configureNodes()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureNodes()
    }

    func update(for unit: BattleUnit) {
        let width = max(min(unit.node.frame.width * 0.48, 82), 50)
        if abs(width - barWidth) > 0.5 {
            barWidth = width
            updateStaticGeometry()
        }

        let xpProgress = progress(current: unit.xp, maxValue: unit.maxXP)
        let ringPath = CGMutablePath()
        ringPath.addArc(
            center: .zero,
            radius: badgeRadius,
            startAngle: -.pi / 2,
            endAngle: -.pi / 2 + xpProgress * .pi * 2,
            clockwise: false
        )
        progressRing.path = ringPath
        progressRing.strokeColor = unit.side == .player ? .cyan : .systemOrange

        levelLabel.text = "\(unit.level)"

        let currentWidth =
            barWidth
            * progress(
                current: unit.currentHP,
                maxValue: unit.maxHP
            )
        front.path = barPath(width: currentWidth)
        front.fillColor = unit.side == .player ? .green : .red
    }

    private func configureNodes() {
        guard children.isEmpty else {
            return
        }

        badge.fillColor = SKColor.black.withAlphaComponent(0.72)
        badge.strokeColor = SKColor.white.withAlphaComponent(0.18)
        badge.lineWidth = 2
        addChild(badge)

        progressRing.lineWidth = 2.6
        progressRing.lineCap = .round
        progressRing.fillColor = .clear
        progressRing.zPosition = 1
        badge.addChild(progressRing)

        levelLabel.fontSize = 9
        levelLabel.fontColor = .white
        levelLabel.verticalAlignmentMode = .center
        levelLabel.horizontalAlignmentMode = .center
        levelLabel.zPosition = 2
        badge.addChild(levelLabel)

        back.fillColor = SKColor.black.withAlphaComponent(0.65)
        back.strokeColor = .clear
        addChild(back)

        front.strokeColor = .clear
        addChild(front)
    }

    private func updateStaticGeometry() {
        badge.path = CGPath(
            ellipseIn: CGRect(
                x: -badgeRadius,
                y: -badgeRadius,
                width: badgeRadius * 2,
                height: badgeRadius * 2
            ),
            transform: nil
        )
        badge.position = CGPoint(x: -barWidth / 2 - badgeRadius - 4, y: 0)
        back.path = barPath(width: barWidth)
    }

    private func barPath(width: CGFloat) -> CGPath {
        CGPath(
            roundedRect: CGRect(
                x: 4 - barWidth / 2,
                y: -height / 2,
                width: max(width, 0),
                height: height
            ),
            cornerWidth: 2,
            cornerHeight: 2,
            transform: nil
        )
    }

    private func progress(current: Int, maxValue: Int) -> CGFloat {
        min(max(CGFloat(current) / CGFloat(Swift.max(maxValue, 1)), 0), 1)
    }
}
