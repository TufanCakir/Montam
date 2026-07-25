//
//  GameScene.swift
//  Montam
//
//  Created by Tufan Cakir on 27.02.26.
//

import SpriteKit

final class GameScene: SKScene {

    private var battleConfig: BattleConfigData?
    private var backgrounds: [BackgroundData] = []
    private var monsters: [MonsterData] = []
    private var tamers: [TamerData] = []
    private var enemies: [EnemyData] = []
    private let musicPlayer = BattleMusicPlayer.shared

    private var skyNode: SKNode?
    private var worldNode: SKNode?
    private var battleCamera: SKCameraNode?
    private var currentBackgroundData: BackgroundData?
    private var fadeNode: SKSpriteNode?
    private var playerUnits: [BattleUnit] = []
    private var supportUnits: [BattleUnit] = []
    private var enemyUnits: [BattleUnit] = []
    private var supporterUnits: [BattleUnit] = []
    private var selectedMonsters: [RuntimeOwnedMonster] = []
    private var selectedTamers: [RuntimeOwnedTamer] = []
    private var selectedSupporters: [RuntimeOwnedSupporter] = []
    private var currentWaveIndex = 0
    private var globalStage = 1
    private var currentBackgroundIndex = 0
    private var completedFightCount = 0
    private var didStartBattle = false
    private var eventData: EventData?
    var onStageChanged: ((BattleStageState) -> Void)?
    var onStageCompleted: ((Int) -> Void)?
    var onBattleWon: ((BattleWaveReward) -> Void)?
    var onBossBattleWon: (() -> Void)?

    func configureEvent(_ event: EventData?) {
        eventData = event
    }

    func configure(
        selectedMonsters: [RuntimeOwnedMonster],
        selectedTamers: [RuntimeOwnedTamer],
        selectedSupporters: [RuntimeOwnedSupporter]
    ) {
        self.selectedMonsters = selectedMonsters
        self.selectedTamers = selectedTamers
        self.selectedSupporters = selectedSupporters

        guard didStartBattle else {
            return
        }

        didStartBattle = false
        startIfReady()
    }

    func updateRuntimeSelection(
        selectedMonsters: [RuntimeOwnedMonster],
        selectedTamers: [RuntimeOwnedTamer],
        selectedSupporters: [RuntimeOwnedSupporter]
    ) {
        self.selectedMonsters = selectedMonsters
        self.selectedTamers = selectedTamers
        self.selectedSupporters = selectedSupporters
    }

    func updateProgressStage(_ stage: Int) {
        globalStage = max(stage, 1)
        publishStageState(config: battleConfig)
    }

    override func didMove(to view: SKView) {
        scaleMode = .resizeFill
        anchorPoint = .zero
        loadBattleData()
        startMusicIfNeeded()
        startIfReady()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        applyBattleCamera()
        installCurrentEnvironment()
        layoutFadeNode()
    }

    private func loadBattleData() {
        battleConfig = JSONDataLoader.load(
            "battleConfig",
            as: BattleConfigData.self
        )
        backgrounds =
            JSONDataLoader.load("background", as: [BackgroundData].self) ?? []
        monsters = JSONDataLoader.load("monster", as: [MonsterData].self) ?? []
        tamers = JSONDataLoader.load("tamer", as: [TamerData].self) ?? []
        enemies = JSONDataLoader.load("enemy", as: [EnemyData].self) ?? []
        let musicFiles =
            (JSONDataLoader.load("music", as: [MusicData].self) ?? []).map(
                \.file
            )
        musicPlayer.configure(fileNames: musicFiles)

        if let eventData {
            battleConfig = battleConfig?.configuredForEvent(eventData)
        }
    }

    private func startIfReady() {
        guard !didStartBattle, battleConfig != nil, size != .zero else {
            return
        }

        didStartBattle = true
        removeAllChildren()
        skyNode = nil
        worldNode = nil
        battleCamera = nil
        currentBackgroundData = nil
        playerUnits.removeAll()
        supportUnits.removeAll()
        supporterUnits.removeAll()
        enemyUnits.removeAll()
        currentWaveIndex = 0
        currentBackgroundIndex = 0
        completedFightCount = 0
        setupBattleCamera()
        setupFadeNode()
        startWave(at: currentWaveIndex)
    }

    private func setupBattleCamera() {
        let cameraNode = SKCameraNode()
        cameraNode.name = "battleCamera"
        cameraNode.zPosition = 2_000
        battleCamera = cameraNode
        camera = cameraNode
        addChild(cameraNode)
        applyBattleCamera()
    }

    private func applyBattleCamera() {
        guard let battleCamera else {
            return
        }

        let zoom = max(battleConfig?.cameraZoom ?? 1, 0.25)
        battleCamera.xScale = zoom
        battleCamera.yScale = zoom
        battleCamera.position = CGPoint(
            x: size.width / 2 + (battleConfig?.cameraXOffset ?? 0),
            y: size.height / 2 + (battleConfig?.cameraYOffset ?? 0)
        )
    }

    private func startWave(at index: Int) {
        guard let config = battleConfig else {
            return
        }

        enemyUnits.forEach { $0.node.removeFromParent() }
        enemyUnits.removeAll()
        removeNodes(named: "healthBar")
        removeNodes(named: "reward")

        let wave = config.waves[index]
        if currentBackgroundData == nil {
            showBackground(at: currentBackgroundIndex)
        }
        publishStageState(config: config)

        if playerUnits.isEmpty {
            spawnPlayers(config: config)
        } else {
            refreshPlayerStats(config: config)
        }

        spawnEnemies(wave: wave, config: config)
        refreshHealthBars()
        runEntrance(config: config, includePlayers: playerUnitsStartedOffscreen)
        { [weak self] in
            self?.runCombatLoop()
        }
    }

    private var playerUnitsStartedOffscreen: Bool {
        playerUnits.contains { $0.node.position.x < 0 }
    }

    private func showBackground(at index: Int) {
        guard let config = battleConfig else {
            return
        }

        let backgroundKey =
            config.backgroundSequence.indices.contains(index)
            ? config.backgroundSequence[index]
            : backgrounds.first?.id

        guard let backgroundKey else {
            return
        }

        currentBackgroundData =
            backgroundData(for: backgroundKey) ?? backgrounds.first
        installCurrentEnvironment()
    }

    private func installCurrentEnvironment() {
        guard let currentBackgroundData, let config = battleConfig,
            size != .zero
        else {
            return
        }

        skyNode?.removeFromParent()
        worldNode?.removeFromParent()

        let world = SKNode()
        world.name = "world"
        world.zPosition = -100
        world.position = .zero

        let worldWidth = max(
            size.width * (config.worldWidthMultiplier ?? 2.8),
            size.width
        )
        let worldSize = CGSize(width: worldWidth, height: size.height)

        if currentBackgroundData.resolvedBackgroundImageName == nil {
            let sky = ImageEnvironmentNodes.backgroundNode(
                for: currentBackgroundData,
                size: size
            )
            sky.name = "sky"
            sky.zPosition = -120
            skyNode = sky
            addChild(sky)
        } else {
            let scrollingBackground = ImageEnvironmentNodes.backgroundNode(
                for: currentBackgroundData,
                size: worldSize
            )
            scrollingBackground.zPosition = 0
            world.addChild(scrollingBackground)
        }

        let groundHeight = max(size.height * config.groundYRatio, 80)
        let ground = ImageEnvironmentNodes.groundNode(
            for: currentBackgroundData,
            size: worldSize,
            groundHeight: groundHeight
        )
        ground.zPosition = 10
        world.addChild(ground)

        worldNode = world
        addChild(world)
    }

    private func backgroundData(for key: String) -> BackgroundData? {
        backgrounds.first { data in
            data.id == key || data.resolvedBackgroundImageName == key
        }
    }

    private func setupFadeNode() {
        let node = SKSpriteNode(color: .black, size: size)
        node.name = "fade"
        node.alpha = 0
        node.zPosition = 1_000
        fadeNode = node
        addChild(node)
        layoutFadeNode()
    }

    private func layoutFadeNode() {
        let zoom = max(battleConfig?.cameraZoom ?? 1, 1)
        fadeNode?.size = CGSize(
            width: size.width * zoom,
            height: size.height * zoom
        )
        fadeNode?.position = battleCamera?.position
            ?? CGPoint(x: size.width / 2, y: size.height / 2)
    }

    private func publishStageState(config: BattleConfigData?) {
        guard let config,
            config.waves.indices.contains(currentWaveIndex)
        else {
            return
        }

        let state = BattleStageState(
            stageNumber: globalStage,
            currentWaveIndex: currentWaveIndex,
            totalWaves: config.waves.count,
            isBossWave: config.waves[currentWaveIndex].isBossWave
        )
        DispatchQueue.main.async { [weak self] in
            self?.onStageChanged?(state)
        }
    }

    private func spawnPlayers(config: BattleConfigData) {
        let configuredMonsters =
            selectedMonsters.isEmpty
            ? config.playerMonsters
            : selectedMonsters.map {
                BattleUnitConfig(
                    id: $0.monsterId,
                    level: $0.level,
                    xp: $0.xp,
                    maxXP: $0.maxXP,
                    slot: 0,
                    hpMultiplier: nil,
                    scaleMultiplier: nil,
                    imageName: $0.imageName
                )
            }

        let configuredTamers =
            selectedTamers.isEmpty
            ? config.supportTamers
            : selectedTamers.map {
                BattleUnitConfig(
                    id: $0.tamerId,
                    level: $0.level,
                    slot: 0,
                    hpMultiplier: nil,
                    scaleMultiplier: nil
                )
            }

        let factory = unitFactory(config: config)

        playerUnits = factory.playerUnits(from: configuredMonsters)
        supportUnits = factory.supportUnits(from: configuredTamers)
        supporterUnits = factory.supporterUnits(from: selectedSupporters)

        let bonusUnits = supportUnits + supporterUnits
        let attackBonus = bonusUnits.reduce(0) { $0 + $1.attackBonus }
        let defenseBonus = bonusUnits.reduce(0) { $0 + $1.defenseBonus }
        let healthBonus = bonusUnits.reduce(0) { $0 + $1.healthBonus }

        for index in playerUnits.indices {
            playerUnits[index].attack = Int(
                Double(playerUnits[index].attack) * (1 + attackBonus)
            )

            playerUnits[index].defense = Int(
                Double(playerUnits[index].defense) * (1 + defenseBonus)
            )

            playerUnits[index].maxHP = Int(
                Double(playerUnits[index].maxHP) * (1 + healthBonus)
            )

            playerUnits[index].currentHP = playerUnits[index].maxHP
        }

        (playerUnits + supportUnits + supporterUnits).forEach { unit in
            unit.node.removeFromParent()
            addChild(unit.node)
        }

        movePlayersToStart(config: config)
    }

    private func refreshPlayerStats(config: BattleConfigData) {

        let factory = unitFactory(config: config)

        supporterUnits.forEach {
            $0.node.removeFromParent()
        }

        supporterUnits = factory.supporterUnits(from: selectedSupporters)

        supporterUnits.forEach {
            addChild($0.node)
        }

        let configuredMonsters =
            selectedMonsters.isEmpty
            ? config.playerMonsters
            : selectedMonsters.map {
                BattleUnitConfig(
                    id: $0.monsterId,
                    level: $0.level,
                    xp: $0.xp,
                    maxXP: $0.maxXP,
                    slot: 0,
                    hpMultiplier: nil,
                    scaleMultiplier: nil,
                    imageName: $0.imageName
                )
            }

        let configuredTamers =
            selectedTamers.isEmpty
            ? config.supportTamers
            : selectedTamers.map {
                BattleUnitConfig(
                    id: $0.tamerId,
                    level: $0.level,
                    slot: 0,
                    hpMultiplier: nil,
                    scaleMultiplier: nil
                )
            }

        let refreshedSupport = factory.supportStats(from: configuredTamers)

        let attackBonus =
            refreshedSupport.reduce(0) { $0 + $1.attackBonus }
            + supporterUnits.reduce(0) { $0 + $1.attackBonus }
        let defenseBonus =
            refreshedSupport.reduce(0) { $0 + $1.defenseBonus }
            + supporterUnits.reduce(0) { $0 + $1.defenseBonus }
        let healthBonus =
            refreshedSupport.reduce(0) { $0 + $1.healthBonus }
            + supporterUnits.reduce(0) { $0 + $1.healthBonus }

        for index in playerUnits.indices {

            guard
                let unitConfig = configuredMonsters.first(where: {
                    $0.id == playerUnits[index].id
                }),
                let stats = factory.monsterStats(from: unitConfig)
            else {
                continue
            }

            playerUnits[index].level = stats.level
            playerUnits[index].xp = unitConfig.xp ?? 0
            playerUnits[index].maxXP = unitConfig.maxXP ?? 1

            playerUnits[index].attack = Int(
                Double(stats.attack) * (1 + attackBonus)
            )

            playerUnits[index].defense = Int(
                Double(stats.defense) * (1 + defenseBonus)
            )

            playerUnits[index].maxHP = Int(
                Double(stats.maxHP) * (1 + healthBonus)
            )

            playerUnits[index].currentHP = playerUnits[index].maxHP
            playerUnits[index].node.alpha = 1
        }

        movePlayersToStart(config: config)
    }

    private func movePlayersToStart(config: BattleConfigData) {
        let groundY = size.height * config.groundYRatio
        let monsterSpacing = max(size.width * 0.095, 46)
        let supportSpacing = max(size.width * 0.1, 44)

        for (index, unit) in playerUnits.enumerated() {
            unit.node.position = CGPoint(
                x: -config.edgeXPadding - CGFloat(index) * monsterSpacing,
                y: groundedY(for: unit, groundY: groundY)
                    + formationYOffset(index: index, count: playerUnits.count)
            )
            unit.node.position = positionWithOffsets(
                unit.node.position,
                unit: unit
            )
            unit.node.zPosition = zPosition(for: unit, index: index)
        }
        
        for (index, unit) in supporterUnits.enumerated() {
            unit.node.position = CGPoint(
                x: -config.edgeXPadding - CGFloat(index) * supportSpacing,
                y: groundedY(for: unit, groundY: groundY)
                    - max(size.height * 0.08, 60)
            )

            unit.node.position = positionWithOffsets(
                unit.node.position,
                unit: unit
            )

            unit.node.zPosition = zPosition(for: unit, index: index)
        }

        for (index, unit) in supportUnits.enumerated() {
            unit.node.position = CGPoint(
                x: -config.edgeXPadding - CGFloat(index) * supportSpacing,
                y: groundedY(for: unit, groundY: groundY)
            )
            unit.node.position = positionWithOffsets(
                unit.node.position,
                unit: unit
            )
            unit.node.zPosition = CGFloat(10 + index)
        }
    }

    private func spawnEnemies(wave: BattleWaveData, config: BattleConfigData) {
        let scaledWave = waveScaledForCurrentTeam(wave)
        enemyUnits = unitFactory(config: config).enemyUnits(from: scaledWave)
        enemyUnits.forEach { addChild($0.node) }

        let groundY = size.height * config.groundYRatio
        let spacing = max(size.width * 0.16, 72)

        for (index, unit) in enemyUnits.enumerated() {
            unit.node.position = CGPoint(
                x: size.width + config.edgeXPadding + CGFloat(index) * spacing,
                y: groundedY(for: unit, groundY: groundY)
                    + formationYOffset(index: index, count: enemyUnits.count)
            )
            unit.node.position = positionWithOffsets(
                unit.node.position,
                unit: unit
            )
            unit.node.zPosition = zPosition(for: unit, index: index)
        }
    }

    private func runEntrance(
        config: BattleConfigData,
        includePlayers: Bool,
        completion: @escaping () -> Void
    ) {
        let groundY = size.height * config.groundYRatio
        let playerSpacing = max(size.width * 0.095, 46)
        let enemySpacing = max(size.width * 0.16, 72)
        let supportSpacing = max(size.width * 0.1, 44)

        var actions: [SKAction] = []

        if includePlayers {
            for (index, unit) in playerUnits.enumerated() {
                let target = CGPoint(
                    x: size.width * 0.22 + CGFloat(index) * playerSpacing,
                    y: groundedY(for: unit, groundY: groundY)
                        + formationYOffset(
                            index: index,
                            count: playerUnits.count
                        )
                )
                let adjustedTarget = positionWithOffsets(target, unit: unit)
                actions.append(
                    .run {
                        unit.node.run(
                            .move(
                                to: adjustedTarget,
                                duration: config.walkDuration
                            )
                        )
                    }
                )
            }
            
            for (index, unit) in supporterUnits.enumerated() {

            let target = CGPoint(
                    x: size.width * 0.34 + CGFloat(index) * supportSpacing,
                    y: groundedY(for: unit, groundY: groundY)
                        - max(size.height * 0.06, 46)
                )

                let adjusted = positionWithOffsets(target, unit: unit)

                actions.append(
                    .run {
                        unit.node.run(
                            .move(
                                to: adjusted,
                                duration: config.walkDuration
                            )
                        )
                    }
                )
            }

            for (index, unit) in supportUnits.enumerated() {
                let target = CGPoint(
                    x: size.width * 0.1 + CGFloat(index) * supportSpacing,
                    y: groundedY(for: unit, groundY: groundY)
                        + max(size.height * 0.018, 14)
                )
                let adjustedTarget = positionWithOffsets(target, unit: unit)
                actions.append(
                    .run {
                        unit.node.run(
                            .move(
                                to: adjustedTarget,
                                duration: config.walkDuration
                            )
                        )
                    }
                )
            }
        }

        for (index, unit) in enemyUnits.enumerated() {
            let target = CGPoint(
                x: size.width * 0.86 - CGFloat(index) * enemySpacing,
                y: groundedY(for: unit, groundY: groundY)
                    + formationYOffset(index: index, count: enemyUnits.count)
            )
            let adjustedTarget = positionWithOffsets(target, unit: unit)
            actions.append(
                .run {
                    unit.node.run(
                        .move(to: adjustedTarget, duration: config.walkDuration)
                    )
                }
            )
        }

        run(
            .sequence(
                actions + [
                    .wait(forDuration: config.walkDuration), .run(completion),
                ]
            )
        )
    }

    private func groundedY(for unit: BattleUnit, groundY: CGFloat) -> CGFloat {
        let visibleHeight = unit.node.size.height * abs(unit.node.yScale)
        let transparentPaddingCompensation = max(visibleHeight * 0.08, 10)
        let groundAdjustment = max(size.height * 0.012, 12)
        return groundY - transparentPaddingCompensation - groundAdjustment
    }

    private func waveScaledForCurrentTeam(_ wave: BattleWaveData)
        -> BattleWaveData
    {
        let playerLevel = max(playerUnits.map(\.level).max() ?? 1, 1)
        let enemyLevelFloor = max(playerLevel - 1, 1)
        let hpBonus = 1 + Double(max(playerLevel - 1, 0)) * 0.1

        return BattleWaveData(
            backgroundIndex: wave.backgroundIndex,
            isBossWave: wave.isBossWave,
            xpReward: wave.xpReward,
            enemies: wave.enemies.map { enemy in
                let level = max(enemy.level ?? 1, enemyLevelFloor)
                let multiplier = (enemy.hpMultiplier ?? 1) * hpBonus
                return enemy.with(level: level, hpMultiplier: multiplier)
            }
        )
    }

    private func formationYOffset(index: Int, count: Int) -> CGFloat {
        guard count > 1 else {
            return 0
        }

        let depthSpacing = max(size.height * 0.022, 16)
        let centeredIndex = CGFloat(index) - CGFloat(count - 1) / 2
        return centeredIndex * depthSpacing
    }

    private func positionWithOffsets(_ position: CGPoint, unit: BattleUnit)
        -> CGPoint
    {
        CGPoint(
            x: position.x + CGFloat(unit.xOffset) * 0.1,
            y: position.y + CGFloat(unit.yOffset) * 0.1
        )
    }

    private func zPosition(for unit: BattleUnit, index: Int) -> CGFloat {
        40 + unit.node.position.y * 0.01 + CGFloat(unit.zOffset) * 0.1
            + CGFloat(index)
    }

    private func runCombatLoop() {
        guard let config = battleConfig else {
            return
        }

        guard BattleCombatSystem.hasAliveUnit(in: playerUnits) else {
            endBattle()
            return
        }

        guard BattleCombatSystem.hasAliveUnit(in: enemyUnits) else {
            completeWave(config: config)
            return
        }

        playerAttack()
        enemyAttack()
        refreshHealthBars()

        run(
            .sequence([
                .wait(forDuration: config.attackInterval),
                .run { [weak self] in self?.runCombatLoop() },
            ])
        )
    }

    private func playerAttack() {
        let livingEnemies = enemyUnits.filter(\.isAlive)

        for (index, unit) in playerUnits.filter(\.isAlive).enumerated() {
            guard !livingEnemies.isEmpty,
                let target = livingEnemies[safe: index % livingEnemies.count]
            else {
                return
            }

            animateAttack(attacker: unit, target: target)
            applyDamageAndAnimateDefeat(from: unit, to: target)
        }
    }

    private func enemyAttack() {
        let livingPlayers = playerUnits.filter(\.isAlive)

        for (index, unit) in enemyUnits.filter(\.isAlive).enumerated() {
            guard !livingPlayers.isEmpty,
                let target = livingPlayers[safe: index % livingPlayers.count]
            else {
                return
            }

            animateAttack(attacker: unit, target: target)
            applyDamageAndAnimateDefeat(from: unit, to: target)
        }
    }

    private func animateAttack(attacker: BattleUnit, target: BattleUnit) {
        let originalPosition = attacker.node.position
        let direction: CGFloat = attacker.side == .player ? 1 : -1
        let lunge = CGPoint(
            x: originalPosition.x + 24 * direction,
            y: originalPosition.y
        )

        attacker.node.run(
            .sequence([
                .move(to: lunge, duration: 0.12),
                .move(to: originalPosition, duration: 0.16),
            ])
        )

        target.node.run(
            .sequence([
                .colorize(with: .red, colorBlendFactor: 0.45, duration: 0.08),
                .colorize(withColorBlendFactor: 0, duration: 0.12),
            ])
        )
    }

    private func applyDamageAndAnimateDefeat(
        from attacker: BattleUnit,
        to target: BattleUnit
    ) {
        let result = BattleCombatSystem.applyDamage(from: attacker, to: target)

        if result.didDefeatTarget {
            target.node.run(
                .sequence([
                    .fadeOut(withDuration: 0.25),
                    .removeFromParent(),
                ])
            )
        }
    }

    private func completeWave(config: BattleConfigData) {
        let wave = config.waves[currentWaveIndex]
        let reward = battleReward(for: wave, config: config)
        completedFightCount += 1
        globalStage += 1
        onStageCompleted?(globalStage)
        onBattleWon?(reward)

        if wave.isBossWave {
            showBossVictory(
                rewards: config.rewards,
                reward: reward
            )
            onBossBattleWon?()
            currentWaveIndex = 0
            resetPlayerHealth()
            run(
                .sequence([
                    .wait(forDuration: 1.65),
                    .run { [weak self] in
                        self?.advanceEnvironmentAfterFight(config: config) {
                            [weak self] in
                            self?.removeRewardsAfterDelay()
                            self?.startWave(at: 0)
                        }
                    },
                ])
            )
            return
        }

        showWaveReward(reward)
        currentWaveIndex = min(currentWaveIndex + 1, config.waves.count - 1)
        resetPlayerHealth()
        advanceEnvironmentAfterFight(config: config) { [weak self] in
            self?.startWave(at: self?.currentWaveIndex ?? 0)
        }
    }

    private func battleReward(
        for wave: BattleWaveData,
        config: BattleConfigData
    ) -> BattleWaveReward {
        let rewards = config.rewards
        let coinChance =
            wave.isBossWave
            ? rewards.bossCoinDropChance ?? rewards.coinDropChance ?? 0.85
            : rewards.coinDropChance ?? 0.85
        let crystalChance =
            wave.isBossWave
            ? rewards.bossCrystalDropChance ?? rewards.crystalDropChance ?? 0.18
            : rewards.crystalDropChance ?? 0.04
        let bitChance =
            wave.isBossWave
            ? rewards.bossBitDropChance ?? rewards.bitDropChance ?? 0.08
            : rewards.bitDropChance ?? 0.015

        return BattleWaveReward(
            xp: wave.xpReward ?? 0,
            coins: roll(chance: coinChance) ? rewards.coins : 0,
            crystals: roll(chance: crystalChance) ? rewards.crystals : 0,
            bits: roll(chance: bitChance) ? rewards.bits ?? 0 : 0
        )
    }

    private func roll(chance: Double) -> Bool {
        Double.random(in: 0...1) < min(max(chance, 0), 1)
    }

    private func advanceEnvironmentAfterFight(
        config: BattleConfigData,
        completion: @escaping () -> Void
    ) {
        let threshold = max(config.backgroundTransitionFightCount ?? 3, 1)
        let shouldChangeBackground = completedFightCount.isMultiple(
            of: threshold
        )

        guard shouldChangeBackground else {
            scrollBackgroundToEdge(config: config, completion: completion)
            return
        }

        currentBackgroundIndex = nextBackgroundIndex(config: config)
        fadeToBackground(config: config, completion: completion)
    }

    private func nextBackgroundIndex(config: BattleConfigData) -> Int {
        guard !config.backgroundSequence.isEmpty else {
            return 0
        }

        return (currentBackgroundIndex + 1) % config.backgroundSequence.count
    }

    private func resetPlayerHealth() {
        for index in playerUnits.indices {
            playerUnits[index].currentHP = playerUnits[index].maxHP
            playerUnits[index].node.alpha = 1
        }
    }

    private func scrollBackgroundToEdge(
        config: BattleConfigData,
        completion: @escaping () -> Void
    ) {
        guard let worldNode else {
            completion()
            return
        }

        let maxOffset = max(
            size.width * ((config.worldWidthMultiplier ?? 2.8) - 1),
            0
        )
        let nextX = max(
            worldNode.position.x - size.width
                * (config.worldScrollStepRatio ?? 0.42),
            -maxOffset
        )

        worldNode.run(
            .sequence([
                .moveTo(x: nextX, duration: config.walkDuration),
                .run(completion),
            ])
        )

        for unit in playerUnits + supportUnits + supporterUnits
        where unit.node.parent != nil {
            unit.node.run(
                .sequence([
                    .moveBy(
                        x: size.width * 0.08,
                        y: 0,
                        duration: config.walkDuration * 0.5
                    ),
                    .moveBy(
                        x: -size.width * 0.04,
                        y: 0,
                        duration: config.walkDuration * 0.5
                    ),
                ])
            )
        }
    }

    private func fadeToBackground(
        config: BattleConfigData,
        completion: @escaping () -> Void
    ) {
        fadeNode?.run(
            .sequence([
                .fadeIn(withDuration: config.fadeDuration),
                .wait(forDuration: 0.35),
                .run { [weak self] in

                    guard let self else { return }

                    self.playerUnits.forEach { $0.node.removeFromParent() }
                    self.supportUnits.forEach { $0.node.removeFromParent() }
                    self.supporterUnits.forEach { $0.node.removeFromParent() }
                    self.enemyUnits.forEach { $0.node.removeFromParent() }

                    self.playerUnits.removeAll()
                    self.supportUnits.removeAll()
                    self.supporterUnits.removeAll()
                    self.enemyUnits.removeAll()

                    self.showBackground(at: self.currentBackgroundIndex)

                    completion()
                },
                .fadeOut(withDuration: config.fadeDuration)
            ])
        )
    }
    
    private func endBattle() {

        guard let config = battleConfig else {
            return
        }

        fadeNode?.run(
            .sequence([
                .fadeIn(withDuration: config.fadeDuration),
                .wait(forDuration: 0.35),
                .run { [weak self] in

                    guard let self else { return }

                    self.currentWaveIndex = 0

                    self.playerUnits.forEach { $0.node.removeFromParent() }
                    self.supportUnits.forEach { $0.node.removeFromParent() }
                    self.supporterUnits.forEach { $0.node.removeFromParent() }
                    self.enemyUnits.forEach { $0.node.removeFromParent() }

                    self.playerUnits.removeAll()
                    self.supportUnits.removeAll()
                    self.supporterUnits.removeAll()
                    self.enemyUnits.removeAll()

                    self.startWave(at: 0)
                },
                .fadeOut(withDuration: config.fadeDuration)
            ])
        )
    }

    private func removeRewardsAfterDelay() {
        run(
            .sequence([
                .wait(forDuration: 0.8),
                .run { [weak self] in
                    self?.removeNodes(named: "reward")
                },
            ])
        )
    }

    private func showBossVictory(
        rewards: BattleRewardConfig,
        reward: BattleWaveReward
    ) {
        let container = BattleRewardHUDFactory.bossVictoryNode(
            rewards: rewards,
            reward: reward,
            sceneSize: size
        )
        addChild(container)
        container.run(BattleRewardHUDFactory.presentationAction())
    }

    private func showWaveReward(_ reward: BattleWaveReward) {
        let container = BattleRewardHUDFactory.waveRewardNode(
            reward: reward,
            sceneSize: size
        )
        addChild(container)
        container.run(BattleRewardHUDFactory.presentationAction())
    }

    private func startMusicIfNeeded() {
        musicPlayer.startIfNeeded()
    }

    private func refreshHealthBars() {
        removeNodes(named: "healthBar")

        for unit in playerUnits + enemyUnits
        where unit.node.parent != nil && unit.isAlive {
            let healthBar = BattleHUDFactory.healthBar(for: unit)
            healthBar.position = healthBarPosition(for: unit)
            addChild(healthBar)
        }
    }

    private func healthBarPosition(for unit: BattleUnit) -> CGPoint {
        return CGPoint(
            x: unit.node.frame.midX,
            y: unit.node.frame.maxY + 12
        )
    }

    private func unitFactory(config: BattleConfigData) -> BattleUnitFactory {
        BattleUnitFactory(
            monsters: monsters,
            tamers: tamers,
            enemies: enemies,
            sceneSize: size,
            battleConfig: config
        )
    }

    private func removeNodes(named name: String) {
        enumerateChildNodes(withName: "//\(name)") { node, _ in
            node.removeFromParent()
        }
    }
}

extension Array {
    fileprivate subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
