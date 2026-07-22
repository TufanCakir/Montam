//
//  GeneratedEnvironmentNodes.swift
//  Montam
//
//  Created by Tufan Cakir on 21.07.26.
//

import SpriteKit
import UIKit

enum GeneratedEnvironmentNodes {
    static func backgroundNode(for data: BackgroundData, size: CGSize) -> SKNode
    {
        if let imageName = data.resolvedBackgroundImageName {
            let node = SKSpriteNode(texture: texture(named: imageName))
            node.name = "background"
            node.size = size
            node.position = CGPoint(x: size.width / 2, y: size.height / 2)
            return node
        }

        let root = SKNode()
        root.name = "background"

        let sky = SKSpriteNode(
            texture: gradientTexture(
                size: size,
                topColor: SKColor(hex: data.skyTopColor)
                    ?? SKColor(red: 0.08, green: 0.18, blue: 0.38, alpha: 1),
                bottomColor: SKColor(hex: data.skyBottomColor)
                    ?? SKColor(red: 0.54, green: 0.78, blue: 0.95, alpha: 1)
            )
        )
        sky.size = size
        sky.position = CGPoint(x: size.width / 2, y: size.height / 2)
        root.addChild(sky)

        addSkyDetails(to: root, data: data, size: size)
        return root
    }

    static func groundNode(
        for data: BackgroundData,
        size: CGSize,
        groundHeight: CGFloat
    ) -> SKNode {
        let root = SKNode()
        root.name = "ground"

        if data.resolvedBackgroundImageName != nil {
            return root
        }

        if let imageName = data.resolvedGroundImageName {
            let ground = SKSpriteNode(texture: texture(named: imageName))
            ground.size = CGSize(width: size.width, height: groundHeight)
            ground.anchorPoint = CGPoint(x: 0.5, y: 0)
            ground.position = CGPoint(x: size.width / 2, y: 0)
            root.addChild(ground)
            return root
        }

        let ground = SKSpriteNode(
            texture: gradientTexture(
                size: CGSize(width: size.width, height: groundHeight),
                topColor: SKColor(hex: data.groundTopColor) ?? .brown,
                bottomColor: SKColor(hex: data.groundBottomColor) ?? .black
            )
        )
        ground.size = CGSize(width: size.width, height: groundHeight)
        ground.anchorPoint = CGPoint(x: 0.5, y: 0)
        ground.position = CGPoint(x: size.width / 2, y: 0)
        root.addChild(ground)

        addGroundDetails(
            to: root,
            data: data,
            size: size,
            groundHeight: groundHeight
        )
        return root
    }

    private static func texture(named imageName: String) -> SKTexture {
        let cachedURL = RemoteContentService.cachedAssetURL(named: imageName)
        if FileManager.default.fileExists(atPath: cachedURL.path()),
            let image = UIImage(contentsOfFile: cachedURL.path())
        {
            return SKTexture(image: image)
        }

        return SKTexture(imageNamed: imageName)
    }

    private static func addSkyDetails(
        to root: SKNode,
        data: BackgroundData,
        size: CGSize
    ) {
        let accent = SKColor(hex: data.accentColor) ?? .cyan

        switch data.proceduralStyle ?? "mountains" {
        case "pixel_night_city", "pixel_night_towers", "pixel_start_night_city":
            addPixelNightTowers(to: root, accent: accent, size: size)
            addPixelParticles(to: root, accent: accent, size: size)
        case "pixel_rooftop_city", "pixel_skyline", "pixel_city":
            addPixelSkyline(to: root, accent: accent, size: size)
            addPixelParticles(to: root, accent: accent, size: size)
        case "pixel_city_mix":
            addPixelNightTowers(to: root, accent: accent, size: size)
            addPixelSkyline(to: root, accent: accent, size: size)
            addPixelParticles(to: root, accent: accent, size: size)
        case "pixel_ocean":
            addPixelClouds(to: root, size: size)
            for index in 0..<4 {
                let path = mountainPath(
                    width: size.width,
                    height: CGFloat(140 + index * 38)
                )
                let node = SKShapeNode(path: path)
                node.fillColor = accent.withAlphaComponent(
                    0.12 + CGFloat(index) * 0.06
                )
                node.strokeColor = .clear
                node.position = CGPoint(x: 0, y: CGFloat(index * 22))
                root.addChild(node)
            }
        case "pixel_lava":
            addPixelParticles(to: root, accent: accent, size: size)
            for index in 0..<10 {
                let node = SKShapeNode(
                    rectOf: CGSize(width: 88 + index * 16, height: 10),
                    cornerRadius: 5
                )
                node.fillColor = accent.withAlphaComponent(0.28)
                node.strokeColor = .clear
                node.zRotation = CGFloat(index * 9 - 24) * .pi / 180
                node.position = CGPoint(
                    x: size.width * 0.5 + CGFloat(index * 47 - 190),
                    y: size.height * 0.64 + CGFloat(index * 23 - 135)
                )
                root.addChild(node)
            }
        case "pixel_ice":
            addPixelParticles(to: root, accent: accent, size: size)
            for index in 0..<4 {
                let path = mountainPath(
                    width: size.width,
                    height: CGFloat(150 + index * 44)
                )
                let node = SKShapeNode(path: path)
                node.fillColor = accent.withAlphaComponent(
                    0.12 + CGFloat(index) * 0.08
                )
                node.strokeColor = .clear
                node.position = CGPoint(x: 0, y: CGFloat(index * 26))
                root.addChild(node)
            }
        case "lava":
            for index in 0..<9 {
                let node = SKShapeNode(
                    rectOf: CGSize(width: 90 + index * 16, height: 18),
                    cornerRadius: 9
                )
                node.fillColor = accent.withAlphaComponent(0.22)
                node.strokeColor = .clear
                node.zRotation = CGFloat(index * 7 - 18) * .pi / 180
                node.position = CGPoint(
                    x: size.width * 0.5 + CGFloat(index * 43 - 180),
                    y: size.height * 0.62 + CGFloat(index * 21 - 110)
                )
                root.addChild(node)
            }
        case "ice":
            for index in 0..<24 {
                let side = CGFloat(8 + index % 5 * 5)
                let node = SKShapeNode(
                    rectOf: CGSize(width: side, height: side)
                )
                node.strokeColor = accent.withAlphaComponent(0.42)
                node.lineWidth = 1.2
                node.fillColor = .clear
                node.zRotation = CGFloat(index * 17) * .pi / 180
                node.position = CGPoint(
                    x: CGFloat(index * 31 % Int(size.width)),
                    y: CGFloat(index * 47 % Int(max(size.height, 1)))
                )
                root.addChild(node)
            }
        default:
            for index in 0..<4 {
                let path = mountainPath(
                    width: size.width,
                    height: CGFloat(150 + index * 44)
                )
                let node = SKShapeNode(path: path)
                node.fillColor = accent.withAlphaComponent(
                    0.12 + CGFloat(index) * 0.08
                )
                node.strokeColor = .clear
                node.position = CGPoint(x: 0, y: CGFloat(index * 26))
                root.addChild(node)
            }
        }
    }

    private static func addGroundDetails(
        to root: SKNode,
        data: BackgroundData,
        size: CGSize,
        groundHeight: CGFloat
    ) {
        switch data.groundStyle ?? "stone" {
        case "pixel_lava":
            addPixelGroundBlocks(
                to: root,
                size: size,
                groundHeight: groundHeight
            )
            for index in 0..<14 {
                let node = SKShapeNode(
                    rectOf: CGSize(width: 70 + index % 4 * 36, height: 8),
                    cornerRadius: 4
                )
                node.fillColor = .orange.withAlphaComponent(0.72)
                node.strokeColor = .clear
                node.position = CGPoint(
                    x: CGFloat(index * 41 % Int(size.width)),
                    y: CGFloat(index * 19 % Int(max(groundHeight, 1)))
                )
                root.addChild(node)
            }
        case "pixel_ice":
            addPixelGroundBlocks(
                to: root,
                size: size,
                groundHeight: groundHeight
            )
            for index in 0..<16 {
                let node = SKShapeNode(
                    rectOf: CGSize(width: 26 + index % 4 * 16, height: 8),
                    cornerRadius: 2
                )
                node.fillColor = .white.withAlphaComponent(0.32)
                node.strokeColor = .clear
                node.position = CGPoint(
                    x: CGFloat(index * 31 % Int(size.width)),
                    y: CGFloat(index * 23 % Int(max(groundHeight, 1)))
                )
                root.addChild(node)
            }
        case "pixel_sand":
            for index in 0..<26 {
                let node = SKShapeNode(
                    rectOf: CGSize(width: 10 + index % 5 * 8, height: 5),
                    cornerRadius: 1
                )
                node.fillColor = .white.withAlphaComponent(0.2)
                node.strokeColor = .clear
                node.position = CGPoint(
                    x: CGFloat(index * 29 % Int(size.width)),
                    y: CGFloat(index * 17 % Int(max(groundHeight, 1)))
                )
                root.addChild(node)
            }
        case "pixel_stone":
            addPixelGroundBlocks(
                to: root,
                size: size,
                groundHeight: groundHeight
            )
        case "lava":
            for index in 0..<12 {
                let node = SKShapeNode(
                    rectOf: CGSize(width: 70 + index % 4 * 34, height: 8),
                    cornerRadius: 4
                )
                node.fillColor = .orange.withAlphaComponent(0.5)
                node.strokeColor = .clear
                node.position = CGPoint(
                    x: CGFloat(index * 39 % Int(size.width)),
                    y: CGFloat(index * 17 % Int(max(groundHeight, 1)))
                )
                root.addChild(node)
            }
        case "ice":
            for index in 0..<16 {
                let node = SKShapeNode(
                    rectOf: CGSize(width: 28 + index % 4 * 14, height: 18),
                    cornerRadius: 3
                )
                node.fillColor = .clear
                node.strokeColor = .white.withAlphaComponent(0.35)
                node.lineWidth = 1
                node.zRotation = CGFloat(index * 11) * .pi / 180
                node.position = CGPoint(
                    x: CGFloat(index * 29 % Int(size.width)),
                    y: CGFloat(index * 19 % Int(max(groundHeight, 1)))
                )
                root.addChild(node)
            }
        case "sand":
            for index in 0..<18 {
                let node = SKShapeNode(circleOfRadius: CGFloat(2 + index % 4))
                node.fillColor = .white.withAlphaComponent(0.18)
                node.strokeColor = .clear
                node.position = CGPoint(
                    x: CGFloat(index * 23 % Int(size.width)),
                    y: CGFloat(index * 31 % Int(max(groundHeight, 1)))
                )
                root.addChild(node)
            }
        default:
            for index in 0..<10 {
                let node = SKShapeNode(
                    rectOf: CGSize(width: 70 + index % 3 * 22, height: 28),
                    cornerRadius: 6
                )
                node.fillColor = .clear
                node.strokeColor = .black.withAlphaComponent(0.18)
                node.lineWidth = 2
                node.position = CGPoint(
                    x: CGFloat(index * 42 % Int(size.width)),
                    y: CGFloat(index * 23 % Int(max(groundHeight, 1)))
                )
                root.addChild(node)
            }
        }
    }

    private static func addPixelSkyline(
        to root: SKNode,
        accent: SKColor,
        size: CGSize
    ) {
        let widths: [CGFloat] = [
            72, 118, 88, 62, 134, 82, 112, 76, 124, 68, 96, 104,
        ]
        let heights: [CGFloat] = [
            260, 390, 315, 460, 240, 350, 430, 285, 375, 225, 330, 405,
        ]

        for index in widths.indices {
            let building = SKNode()
            let body = SKShapeNode(
                rectOf: CGSize(width: widths[index], height: heights[index]),
                cornerRadius: 2
            )
            body.fillColor = SKColor(
                red: 0.08,
                green: 0.14,
                blue: 0.34,
                alpha: index.isMultiple(of: 2) ? 0.72 : 0.55
            )
            body.strokeColor = .clear
            building.addChild(body)

            let roof = SKShapeNode(
                path: trianglePath(width: widths[index], height: 42)
            )
            roof.fillColor =
                index.isMultiple(of: 2)
                ? SKColor(red: 0.88, green: 0.18, blue: 0.48, alpha: 0.72)
                : SKColor(red: 0.42, green: 0.2, blue: 0.72, alpha: 0.58)
            roof.strokeColor = .clear
            roof.position = CGPoint(x: 0, y: heights[index] / 2)
            building.addChild(roof)

            for row in 0..<6 {
                for column in 0..<2 {
                    let window = SKShapeNode(
                        rectOf: CGSize(width: 16, height: 24)
                    )
                    window.fillColor =
                        (row + column + index).isMultiple(of: 3)
                        ? .white.withAlphaComponent(0.38)
                        : accent.withAlphaComponent(0.15)
                    window.strokeColor = .clear
                    window.position = CGPoint(
                        x: CGFloat(column == 0 ? -14 : 14),
                        y: heights[index] / 2 - 44 - CGFloat(row * 40)
                    )
                    building.addChild(window)
                }
            }

            building.position = CGPoint(
                x: CGFloat(index) / CGFloat(max(widths.count - 1, 1))
                    * size.width,
                y: heights[index] / 2
            )
            root.addChild(building)
        }
    }

    private static func addPixelNightTowers(
        to root: SKNode,
        accent: SKColor,
        size: CGSize
    ) {
        let widths: [CGFloat] = [
            86, 132, 92, 64, 120, 82, 104, 74, 116, 70, 98,
        ]
        let heights: [CGFloat] = [
            420, 540, 360, 610, 300, 470, 565, 350, 510, 280, 390,
        ]
        let xOffsets: [CGFloat] = [-20, 0, 14, -8, 20, -12, 8, 16, -18, 8, 24]
        let yOffsets: [CGFloat] = [
            20, -12, 32, -40, 42, 8, -22, 34, -8, 44, 18,
        ]

        for index in widths.indices {
            let tower = SKShapeNode(
                rectOf: CGSize(width: widths[index], height: heights[index]),
                cornerRadius: 10
            )
            tower.fillColor = SKColor(
                red: 0.08,
                green: 0.11,
                blue: 0.24,
                alpha: index.isMultiple(of: 2) ? 0.9 : 0.72
            )
            tower.strokeColor = .clear
            tower.position = CGPoint(
                x: CGFloat(index) / CGFloat(max(widths.count - 1, 1))
                    * size.width + xOffsets[index],
                y: heights[index] / 2 - yOffsets[index]
            )
            root.addChild(tower)

            for row in 0..<8 {
                for column in 0..<3 {
                    let window = SKShapeNode(
                        rectOf: CGSize(width: 14, height: 20),
                        cornerRadius: 1
                    )
                    window.fillColor =
                        (row + column + index).isMultiple(of: 3)
                        ? SKColor.yellow.withAlphaComponent(0.72)
                        : accent.withAlphaComponent(0.16)
                    window.strokeColor = .clear
                    window.position = CGPoint(
                        x: tower.position.x - widths[index] / 2 + 22
                            + CGFloat(column * 27),
                        y: tower.position.y + heights[index] / 2 - 56
                            - CGFloat(row * 38)
                    )
                    root.addChild(window)
                }
            }
        }

        let shadow = SKShapeNode(rectOf: CGSize(width: size.width, height: 70))
        shadow.fillColor = .black.withAlphaComponent(0.16)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: size.width / 2, y: 35)
        root.addChild(shadow)
    }

    private static func addPixelClouds(to root: SKNode, size: CGSize) {
        for index in 0..<6 {
            let cloud = SKNode()
            for block in 0..<4 {
                let rect = SKShapeNode(
                    rectOf: CGSize(
                        width: 38 + block * 14,
                        height: 22 + block % 2 * 18
                    ),
                    cornerRadius: 8
                )
                rect.fillColor = .white.withAlphaComponent(0.32)
                rect.strokeColor = .clear
                rect.position = CGPoint(
                    x: CGFloat(block * 28),
                    y: CGFloat(block % 2 * 7)
                )
                cloud.addChild(rect)
            }
            cloud.position = CGPoint(
                x: CGFloat(index * 73 % Int(max(size.width, 1))),
                y: size.height - CGFloat(72 + index * 48)
            )
            root.addChild(cloud)
        }
    }

    private static func addPixelParticles(
        to root: SKNode,
        accent: SKColor,
        size: CGSize
    ) {
        let palette = [
            accent,
            SKColor(red: 1, green: 0.25, blue: 0.5, alpha: 1),
            SKColor.orange,
            SKColor.white,
        ]

        for index in 0..<34 {
            let node = SKShapeNode(
                rectOf: CGSize(
                    width: 5 + index % 4 * 4,
                    height: 16 + index % 3 * 7
                ),
                cornerRadius: 2
            )
            node.fillColor = palette[index % palette.count].withAlphaComponent(
                0.68
            )
            node.strokeColor = .clear
            node.zRotation = CGFloat(index * 17) * .pi / 180
            node.position = CGPoint(
                x: CGFloat(index * 47 % Int(max(size.width, 1))),
                y: CGFloat(index * 67 % Int(max(size.height, 1)))
            )
            root.addChild(node)
        }
    }

    private static func addPixelGroundBlocks(
        to root: SKNode,
        size: CGSize,
        groundHeight: CGFloat
    ) {
        for index in 0..<18 {
            let node = SKShapeNode(
                rectOf: CGSize(width: 58 + index % 4 * 24, height: 22),
                cornerRadius: 4
            )
            node.fillColor = .clear
            node.strokeColor = .black.withAlphaComponent(0.28)
            node.lineWidth = 2
            node.position = CGPoint(
                x: CGFloat(index * 43 % Int(size.width)),
                y: CGFloat(index * 21 % Int(max(groundHeight, 1)))
            )
            root.addChild(node)
        }
    }

    private static func trianglePath(width: CGFloat, height: CGFloat) -> CGPath
    {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: height / 2))
        path.addLine(to: CGPoint(x: width / 2, y: -height / 2))
        path.addLine(to: CGPoint(x: -width / 2, y: -height / 2))
        path.closeSubpath()
        return path
    }

    private static func mountainPath(width: CGFloat, height: CGFloat) -> CGPath
    {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: width * 0.18, y: height * 0.52))
        path.addLine(to: CGPoint(x: width * 0.34, y: 0))
        path.addLine(to: CGPoint(x: width * 0.52, y: height * 0.68))
        path.addLine(to: CGPoint(x: width * 0.72, y: 0))
        path.addLine(to: CGPoint(x: width * 0.88, y: height * 0.56))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.closeSubpath()
        return path
    }

    private static func gradientTexture(
        size: CGSize,
        topColor: SKColor,
        bottomColor: SKColor
    ) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            let colors = [topColor.cgColor, bottomColor.cgColor] as CFArray
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(
                colorsSpace: colorSpace,
                colors: colors,
                locations: [0, 1]
            )!
            cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: size.width / 2, y: 0),
                end: CGPoint(x: size.width / 2, y: size.height),
                options: []
            )
        }

        return SKTexture(image: image)
    }
}

extension SKColor {
    fileprivate convenience init?(hex: String?) {
        guard let hex else {
            return nil
        }

        let cleaned = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )
        guard cleaned.count == 6, let value = Int(cleaned, radix: 16) else {
            return nil
        }

        self.init(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}
