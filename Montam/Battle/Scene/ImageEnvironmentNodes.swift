//
//  ImageEnvironmentNodes.swift
//  Montam
//
//  Created by Tufan Cakir on 24.07.26.
//

import SpriteKit
import UIKit

enum ImageEnvironmentNodes {
    static func worldBackgroundNode(
        for data: BackgroundData,
        size: CGSize
    ) -> SKNode {
        guard let imageName = data.resolvedBackgroundImageName else {
            return fallbackBackgroundNode(size: size)
        }

        let node = SKSpriteNode(texture: texture(named: imageName))
        node.name = "background"
        node.anchorPoint = .zero
        node.size = CGSize(width: size.width, height: size.height * 1.08)
        node.position = .zero
        return node
    }

    static func backgroundNode(for data: BackgroundData, size: CGSize) -> SKNode
    {
        guard let imageName = data.resolvedSkyImageName else {
            return fallbackBackgroundNode(size: size)
        }

        let node = SKSpriteNode(texture: texture(named: imageName))
        node.name = "background"
        node.size = size
        node.position = CGPoint(x: size.width / 2, y: size.height / 2)
        return node
    }

    static func groundNode(
        for data: BackgroundData,
        size: CGSize,
        groundHeight: CGFloat
    ) -> SKNode {
        guard
            let imageName = data.resolvedGroundImageName
                ?? data.resolvedBackgroundImageName
        else {
            return SKNode()
        }

        let root = SKNode()
        root.name = "ground"

        let node = SKSpriteNode(texture: texture(named: imageName))
        node.name = "groundImage"
        node.anchorPoint = .zero
        node.size = CGSize(width: size.width, height: groundHeight)
        node.position = .zero
        root.addChild(node)

        return root
    }

    private static func fallbackBackgroundNode(size: CGSize) -> SKNode {
        let node = SKSpriteNode(
            color: SKColor(red: 0.03, green: 0.06, blue: 0.16, alpha: 1),
            size: size
        )
        node.name = "background"
        node.position = CGPoint(x: size.width / 2, y: size.height / 2)
        return node
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
}
