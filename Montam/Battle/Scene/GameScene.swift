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
    private let musicPlayer = BattleMusicPlayer()

    private var skyNode: SKNode?
    private var worldNode: SKNode?
    private var currentBackgroundData: BackgroundData?
    private var fadeNode: SKSpriteNode?
    private var stageHUDNode: SKNode?
    private var playerUnits: [BattleUnit] = []
    private var supportUnits: [BattleUnit] = []
    private var enemyUnits: [BattleUnit] = []
    private var selectedMonsters: [RuntimeOwnedMonster] = []
    private var selectedTamers: [RuntimeOwnedTamer] = []
    private var currentWaveIndex = 0
    private var currentBackgroundIndex = 0
    private var completedFightCount = 0
    private var didStartBattle = false
    private var eventData: EventData?
    var onBattleWon: ((Int) -> Void)?
    var onBossBattleWon: (() -> Void)?

    func configureEvent(_ event: EventData?) {
        eventData = event
    }

    func configure(
        selectedMonsters: [RuntimeOwnedMonster],
        selectedTamers: [RuntimeOwnedTamer]
    ) {
        self.selectedMonsters = selectedMonsters
        self.selectedTamers = selectedTamers

        guard didStartBattle else {
            return
        }

        didStartBattle = false
        startIfReady()
    }

    func updateRuntimeSelection(
        selectedMonsters: [RuntimeOwnedMonster],
        selectedTamers: [RuntimeOwnedTamer]
    ) {
        self.selectedMonsters = selectedMonsters
        self.selectedTamers = selectedTamers
    }

    override func didMove(to view: SKView) {
        scaleMode = .resizeFill
        anchorPoint = .zero
        loadBattleData()
        startMusicIfNeeded()
        startIfReady()
    }

    override func didChangeSize(_ oldSize: CGSize) {
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
        currentBackgroundData = nil
        playerUnits.removeAll()
        supportUnits.removeAll()
        enemyUnits.removeAll()
        currentWaveIndex = 0
        currentBackgroundIndex = 0
        completedFightCount = 0
        setupFadeNode()
        startWave(at: currentWaveIndex)
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
        updateStageHUD(config: config)

        if playerUnits.isEmpty {
            spawnPlayers(config: config)
        } else {
            refreshPlayerStats(config: config)
        }

        spawnEnemies(wave: wave, config: config)
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

        let sky = GeneratedEnvironmentNodes.backgroundNode(
            for: currentBackgroundData,
            size: size
        )
        sky.name = "sky"
        sky.zPosition = -120
        skyNode = sky
        addChild(sky)

        let world = SKNode()
        world.name = "world"
        world.zPosition = -100
        world.position = .zero

        let worldWidth = max(
            size.width * (config.worldWidthMultiplier ?? 2.8),
            size.width
        )
        let worldSize = CGSize(width: worldWidth, height: size.height)

        let groundHeight = max(size.height * config.groundYRatio, 80)
        let ground = GeneratedEnvironmentNodes.groundNode(
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
        fadeNode?.size = size
        fadeNode?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        updateStageHUD(config: battleConfig)
    }

    private func updateStageHUD(config: BattleConfigData?) {
        stageHUDNode?.removeFromParent()

        guard let config, size != .zero else {
            return
        }

        let root = BattleHUDFactory.stageNode(
            config: config,
            currentWaveIndex: currentWaveIndex,
            sceneSize: size
        )
        stageHUDNode = root
        addChild(root)
    }

    private func spawnPlayers(config: BattleConfigData) {
        let configuredMonsters =
            selectedMonsters.isEmpty
            ? config.playerMonsters
            : selectedMonsters.map {
                BattleUnitConfig(
                    id: $0.monsterId,
                    level: $0.level,
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

        let attackBonus = supportUnits.reduce(0) { $0 + $1.attackBonus }
        let defenseBonus = supportUnits.reduce(0) { $0 + $1.defenseBonus }
        let healthBonus = supportUnits.reduce(0) { $0 + $1.healthBonus }

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

        (playerUnits + supportUnits).forEach { addChild($0.node) }
        movePlayersToStart(config: config)
    }

    private func refreshPlayerStats(config: BattleConfigData) {
        let configuredMonsters =
            selectedMonsters.isEmpty
            ? config.playerMonsters
            : selectedMonsters.map {
                BattleUnitConfig(
                    id: $0.monsterId,
                    level: $0.level,
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
        let refreshedSupport = factory.supportStats(from: configuredTamers)

        let attackBonus = refreshedSupport.reduce(0) { $0 + $1.attackBonus }
        let defenseBonus = refreshedSupport.reduce(0) { $0 + $1.defenseBonus }
        let healthBonus = refreshedSupport.reduce(0) { $0 + $1.healthBonus }

        for index in playerUnits.indices {
            guard
                let unitConfig = configuredMonsters.prefix(
                    config.maxPlayerMonsters
                ).first(where: { $0.id == playerUnits[index].id }),
                let stats = factory.monsterStats(from: unitConfig)
            else {
                continue
            }

            playerUnits[index].level = stats.level
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
    }

    private func movePlayersToStart(config: BattleConfigData) {
        let groundY = size.height * config.groundYRatio
        let monsterSpacing = max(size.width * 0.11, 48)
        let supportSpacing = max(size.width * 0.08, 36)

        for (index, unit) in playerUnits.enumerated() {
            unit.node.position = CGPoint(
                x: -config.edgeXPadding - CGFloat(index) * monsterSpacing,
                y: groundedY(for: unit, groundY: groundY)
            )
            unit.node.zPosition = CGFloat(20 + index)
        }

        for (index, unit) in supportUnits.enumerated() {
            unit.node.position = CGPoint(
                x: -config.edgeXPadding - CGFloat(index) * supportSpacing,
                y: groundedY(for: unit, groundY: groundY)
            )
            unit.node.zPosition = CGFloat(10 + index)
        }
    }

    private func spawnEnemies(wave: BattleWaveData, config: BattleConfigData) {
        enemyUnits = unitFactory(config: config).enemyUnits(from: wave)
        enemyUnits.forEach { addChild($0.node) }

        let groundY = size.height * config.groundYRatio
        let spacing = max(size.width * 0.11, 46)

        for (index, unit) in enemyUnits.enumerated() {
            unit.node.position = CGPoint(
                x: size.width + config.edgeXPadding + CGFloat(index) * spacing,
                y: groundedY(for: unit, groundY: groundY)
            )
            unit.node.zPosition = CGFloat(30 + index)
        }
    }

    private func runEntrance(
        config: BattleConfigData,
        includePlayers: Bool,
        completion: @escaping () -> Void
    ) {
        let groundY = size.height * config.groundYRatio
        let playerSpacing = max(size.width * 0.13, 58)
        let enemySpacing = max(size.width * 0.13, 58)
        let supportSpacing = max(size.width * 0.08, 36)

        var actions: [SKAction] = []

        if includePlayers {
            for (index, unit) in playerUnits.enumerated() {
                let target = CGPoint(
                    x: size.width * 0.28 + CGFloat(index) * playerSpacing,
                    y: groundedY(for: unit, groundY: groundY)
                )
                actions.append(
                    .run {
                        unit.node.run(
                            .move(to: target, duration: config.walkDuration)
                        )
                    }
                )
            }

            for (index, unit) in supportUnits.enumerated() {
                let target = CGPoint(
                    x: size.width * 0.18 + CGFloat(index) * supportSpacing,
                    y: groundedY(for: unit, groundY: groundY)
                )
                actions.append(
                    .run {
                        unit.node.run(
                            .move(to: target, duration: config.walkDuration)
                        )
                    }
                )
            }
        }

        for (index, unit) in enemyUnits.enumerated() {
            let target = CGPoint(
                x: size.width * 0.72 - CGFloat(index) * enemySpacing,
                y: groundedY(for: unit, groundY: groundY)
            )
            actions.append(
                .run {
                    unit.node.run(
                        .move(to: target, duration: config.walkDuration)
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
        let transparentPaddingCompensation = max(visibleHeight * 0.045, 4)
        return groundY - transparentPaddingCompensation
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
        for unit in playerUnits where unit.isAlive {
            guard let target = BattleCombatSystem.firstAliveUnit(in: enemyUnits)
            else {
                return
            }

            animateAttack(attacker: unit, target: target)
            applyDamageAndAnimateDefeat(from: unit, to: target)
        }
    }

    private func enemyAttack() {
        for unit in enemyUnits where unit.isAlive {
            guard
                let target = BattleCombatSystem.firstAliveUnit(in: playerUnits)
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
        completedFightCount += 1
        onBattleWon?(wave.xpReward ?? 0)

        if wave.isBossWave {
            showBossVictory(
                rewards: config.rewards,
                xpReward: wave.xpReward ?? 0
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

        currentWaveIndex = min(currentWaveIndex + 1, config.waves.count - 1)
        resetPlayerHealth()
        advanceEnvironmentAfterFight(config: config) { [weak self] in
            self?.startWave(at: self?.currentWaveIndex ?? 0)
        }
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

        for unit in playerUnits + supportUnits where unit.node.parent != nil {
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
                    self?.playerUnits.forEach { $0.node.removeFromParent() }
                    self?.supportUnits.forEach { $0.node.removeFromParent() }
                    self?.enemyUnits.forEach { $0.node.removeFromParent() }
                    self?.playerUnits.removeAll()
                    self?.supportUnits.removeAll()
                    self?.enemyUnits.removeAll()
                    self?.showBackground(at: self?.currentBackgroundIndex ?? 0)
                    completion()
                },
                .fadeOut(withDuration: config.fadeDuration),
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
                    self?.currentWaveIndex = 0
                    self?.playerUnits.forEach { $0.node.removeFromParent() }
                    self?.supportUnits.forEach { $0.node.removeFromParent() }
                    self?.enemyUnits.forEach { $0.node.removeFromParent() }
                    self?.playerUnits.removeAll()
                    self?.supportUnits.removeAll()
                    self?.enemyUnits.removeAll()
                    self?.startWave(at: 0)
                },
                .fadeOut(withDuration: config.fadeDuration),
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

    private func showBossVictory(rewards: BattleRewardConfig, xpReward: Int) {
        let container = BattleRewardHUDFactory.bossVictoryNode(
            rewards: rewards,
            xpReward: xpReward,
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

        for unit in playerUnits + enemyUnits where unit.node.parent != nil {
            unit.node.addChild(BattleHUDFactory.healthBar(for: unit))
        }
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
