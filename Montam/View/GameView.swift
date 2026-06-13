//
//  GameView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Combine
import SwiftUI

struct GameView: View {
    @EnvironmentObject private var appModel: AppModel
    @StateObject private var battle = BattleViewModel()
    @State private var showsEventAttacks = false
    @State private var eventVictory: EventVictoryResult?

    var body: some View {
        VStack {
            battleContent
                .background {
                    BattleBackground(imageName: battle.battleBackgroundName)
                }
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    battle.attackEnemy()
                }
                .onAppear {
                    battle.configure(appModel: appModel) { result in
                        eventVictory = result
                    }
                }
                .onDisappear {
                    battle.saveLastSeen()
                }
                .task {
                    await battle.runAutoBattle()
                }
                .sheet(isPresented: $showsEventAttacks) {
                    eventAttackSheet
                        .presentationDetents([.medium])
                }
                .overlay {
                    if let drawnForm = battle.drawnForm {
                        summonCard(for: drawnForm)
                            .transition(.scale.combined(with: .opacity))
                            .zIndex(10)
                    }
                }
                .overlay {
                    if let message = battle.floatingMessage {
                        Text(message)
                            .font(
                                .system(
                                    size: 15,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(MontamPalette.gold)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(MontamPalette.panel)
                            .clipShape(MontamEvolutionShape())
                            .overlay(
                                MontamEvolutionShape()
                                    .stroke(MontamPalette.gold, lineWidth: 1.5)
                            )
                            .offset(y: -42)
                            .zIndex(12)
                    }
                }
                .overlay {
                    if let eventVictory {
                        EventVictoryView(result: eventVictory) {
                            self.eventVictory = nil
                            EventRuntime.shared.clear()
                            appModel.selectedLevelId = nil
                            appModel.selectedStoryChapter = nil
                            appModel.selectedBattleDifficulty = nil
                            appModel.appState = .home
                        }
                        .zIndex(20)
                    }
                }
        }
    }
    private var battleContent: some View {
        VStack(spacing: 0) {
            battleHeader

            Spacer()

            battleField

            if battle.isEventBattle {
                eventSkillButton
                    .padding(.top, 10)
            }

            Spacer()

            battleFooter
        }
        .padding(.horizontal, 18)
        .padding(.top, 48)
        .padding(.bottom, 18)
    }

    private var battleHeader: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Button {
                    battle.exitBattle()
                } label: {
                    Text("EXIT")
                        .font(
                            .system(size: 12, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white)
                        .frame(width: 78, height: 34)
                        .background(MontamPalette.panel)
                        .clipShape(MontamEvolutionShape())
                        .overlay(
                            MontamEvolutionShape()
                                .stroke(MontamPalette.gold, lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)

                Spacer()

                Text(
                    "COINS \(battle.montamCoins)  SAPHIRS \(battle.montamSaphirs)"
                )
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(MontamPalette.gold)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            }

            HStack(spacing: 10) {
                Rectangle()
                    .fill(MontamPalette.gold.opacity(0.70))
                    .frame(width: 82, height: 2)

                Rectangle()
                    .fill(MontamPalette.gold.opacity(0.32))
                    .frame(maxWidth: .infinity)
                    .frame(height: 2)
            }
        }
    }

    private var playerArea: some View {
        VStack(spacing: 10) {
            groundedMontamImage(name: battle.currentForm.assetName)
                .scaleEffect(battle.playerPulse ? 0.94 : 1.0)
                .animation(.snappy(duration: 0.12), value: battle.playerPulse)
                .offset(y: 100)

        }
    }

    private func groundedMontamImage(name: String) -> some View {
        ZStack(alignment: .bottom) {

            RemoteAssetImage(name: name)
                .scaledToFit()
        }
    }

    private var eventSkillButton: some View {
        Button {
            showsEventAttacks = true
        } label: {
            VStack(spacing: 2) {
                RemoteAssetImage(
                    name: battle.eventAttacks.first?.icon
                        ?? "skin_imperion_exalted_default"
                )
                .scaledToFit()
                .frame(width: 34, height: 28)

                Text("SKILL")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(MontamPalette.black)
            }
            .frame(width: 104, height: 56)
            .background(MontamPalette.gold)
            .clipShape(MontamEvolutionShape())
            .overlay(
                MontamEvolutionShape()
                    .stroke(MontamPalette.blue, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var battleField: some View {
        HStack(alignment: .center) {

            groundedMontamImage(
                name: battle.currentForm.assetName
            )
            .scaleEffect(0.65)
            .scaleEffect(x: -1, y: 1)
            .offset(x: -40, y: 200)

            Spacer()

            VStack(spacing: 0) {

                ProgressView(value: battle.enemyHealthRatio)
                    .progressViewStyle(.linear)
                    .tint(.red)
                    .frame(width: 140)
                    .scaleEffect(x: 1, y: 1.8)

                RemoteAssetImage(name: battle.enemyImageName)
                    .scaledToFit()
                    .scaleEffect(0.65)
            }
            .offset(x: 40, y: 200)
        }
        .padding(.horizontal, 30)
    }

    private var battleFooter: some View {
        VStack(spacing: 12) {
            HStack(spacing: 14) {
                Button {
                    battle.summonEvolutionCard()
                } label: {
                    RemoteAssetImage(name: battle.nextEvolutionForm.assetName)
                        .scaledToFit()
                        .frame(width: 52, height: 52)
                        .frame(width: 72, height: 72)
                        .background(
                            battle.canSummonEvolution
                                ? MontamPalette.gold
                                : MontamPalette.blue.opacity(0.45)
                        )
                        .clipShape(MontamEvolutionShape())
                        .overlay(
                            MontamEvolutionShape()
                                .stroke(
                                    battle.canSummonEvolution
                                        ? MontamPalette.blue
                                        : MontamPalette.gold.opacity(0.45),
                                    lineWidth: 2
                                )
                        )
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 8) {
                    Text("EVOLUTION ENERGY \(Int(battle.evolutionEnergy))%")
                        .font(
                            .system(size: 14, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white)

                    ProgressView(value: battle.evolutionEnergy / 100)
                        .progressViewStyle(.linear)
                        .tint(
                            battle.canSummonEvolution
                                ? MontamPalette.gold
                                : MontamPalette.blue
                        )
                        .scaleEffect(x: 1, y: 1.7, anchor: .center)

                    Text(
                        battle.canSummonEvolution
                            ? "EVOLUTION READY" : "ATTACK TO CHARGE"
                    )
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(
                        battle.canSummonEvolution
                            ? MontamPalette.gold
                            : MontamPalette.mutedText
                    )
                }
            }

            HStack(spacing: 12) {
                upgradeButton(
                    title: "ATK",
                    value:
                        "LV \(battle.attackLevel)  \(battle.attackUpgradeCost)",
                    tint: MontamPalette.gold
                ) {
                    battle.upgradeAttack()
                }

                upgradeButton(
                    title: "ENE",
                    value:
                        "LV \(battle.energyLevel)  \(battle.energyUpgradeCost)",
                    tint: MontamPalette.blue
                ) {
                    battle.upgradeEnergy()
                }
            }
        }
        .padding(14)
        .background(MontamPalette.panel.opacity(0.96))
        .overlay(
            Rectangle()
                .stroke(.white.opacity(0.10), lineWidth: 1)
        )
    }

    private var eventAttackSheet: some View {
        ZStack {
            MontamScreenBackground()

            VStack(alignment: .leading, spacing: 16) {
                Text("SPECIAL ATTACK")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(MontamPalette.gold)

                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 12
                ) {
                    ForEach(battle.eventAttacks.prefix(4)) { attack in
                        Button {
                            showsEventAttacks = false
                            battle.useEventAttack(attack)
                        } label: {
                            HStack(spacing: 10) {
                                RemoteAssetImage(name: attack.icon)
                                    .scaledToFit()
                                    .frame(width: 38, height: 38)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(attack.title.uppercased())
                                        .font(
                                            .system(
                                                size: 11,
                                                weight: .black,
                                                design: .rounded
                                            )
                                        )
                                        .foregroundStyle(.white)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.72)

                                    Text("PWR \(attack.power)")
                                        .font(
                                            .system(
                                                size: 10,
                                                weight: .black,
                                                design: .rounded
                                            )
                                        )
                                        .foregroundStyle(
                                            MontamPalette.gold
                                        )
                                }

                                Spacer(minLength: 0)
                            }
                            .padding(10)
                            .frame(height: 62)
                            .background(MontamPalette.panel)
                            .clipShape(
                                MontamEvolutionShape()
                            )
                            .overlay(
                                MontamEvolutionShape()
                                    .stroke(
                                        MontamPalette.blue,
                                        lineWidth: 1.5
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer()
            }
            .padding(22)
        }
    }

    private func upgradeButton(
        title: String,
        value: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(tint)

                Text(value)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .frame(height: 40)
            .background(MontamPalette.black)
            .clipShape(MontamEvolutionShape())
            .overlay(
                MontamEvolutionShape()
                    .stroke(tint, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func summonCard(for form: BattleEvolutionForm)
        -> some View
    {
        VStack(spacing: 12) {
            RemoteAssetImage(name: form.assetName)
                .scaledToFit()
                .frame(width: 116, height: 116)

            Text(form.title)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(MontamPalette.gold)

            Text(form == battle.currentForm ? "SAME FORM" : "EVOLUTION")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: 168, height: 224)
        .background(MontamPalette.panel)
        .clipShape(MontamCutRectangle(cut: 18))
        .overlay(
            MontamCutRectangle(cut: 18)
                .stroke(
                    form == battle.currentForm
                        ? MontamPalette.blue : MontamPalette.gold,
                    lineWidth: 3
                )
        )
    }
}

struct BattleEvolutionForm: Identifiable, Equatable, Hashable {
    let characterId: String
    let title: String
    let assetName: String
    let attackPower: Int
    let energyGain: Double
    let element: MontamElement
    let isFeral: Bool

    var id: String { characterId }

    init(character: Character) {
        characterId = character.id
        title = character.name.uppercased()
        assetName = SkinInventoryManager.shared.activeImage(for: character)
        attackPower = max(8, character.stats.attack / 7)
        energyGain = min(14, max(5, Double(character.stats.energyPower) / 10))
        element = MontamElement.parse(character.energyType)
        isFeral =
            character.id.localizedCaseInsensitiveContains("feral")
            || character.rarity == .common
    }

    private init(
        characterId: String,
        title: String,
        assetName: String,
        attackPower: Int,
        energyGain: Double,
        element: MontamElement,
        isFeral: Bool
    ) {
        self.characterId = characterId
        self.title = title
        self.assetName = assetName
        self.attackPower = attackPower
        self.energyGain = energyGain
        self.element = element
        self.isFeral = isFeral
    }

    static let fallbackFeral = BattleEvolutionForm(
        characterId: "character_montam_feral_cryon",
        title: "CRYON",
        assetName: "skin_cryon_feral_default",
        attackPower: 12,
        energyGain: 12,
        element: .fire,
        isFeral: true
    )
}

private struct BattleBackground: View {
    let imageName: String

    var body: some View {
        RemoteAssetImage(name: imageName)
            .scaledToFill()
            .overlay(
                LinearGradient(
                    colors: [
                        MontamPalette.black.opacity(0.26),
                        MontamPalette.black.opacity(0.10),
                        MontamPalette.black.opacity(0.38),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea()
    }
}

@MainActor
final class BattleViewModel: ObservableObject {

    @Published var currentForm: BattleEvolutionForm = .fallbackFeral
    @Published var nextEvolutionForm: BattleEvolutionForm = .fallbackFeral
    @Published var drawnForm: BattleEvolutionForm?
    @Published var evolutionEnergy = 0.0
    @Published var enemyHP = 150
    @Published var enemyMaxHP = 150
    @Published var stage = 1
    @Published var attackLevel = 1
    @Published var energyLevel = 1
    @Published var eventAttacks: [EventAttack] = []
    @Published var floatingMessage: String?
    @Published var playerPulse = false
    @Published var montamCoins = 0
    @Published var montamSaphirs = 0
    @Published var battleTitle: String?
    @Published var storyText: String?
    @Published var battleBackgroundName = "montam_bg_dark"
    @Published private var battleForms: [BattleEvolutionForm] = [
        .fallbackFeral
    ]

    private weak var appModel: AppModel?
    private var onEventVictory: ((EventVictoryResult) -> Void)?
    private var lastAttackTime: TimeInterval = 0
    private var eventKills = 0
    private var eventEnded = false
    private var configured = false

    private let attackLevelKey = "montam_idle_attack_level"
    private let energyLevelKey = "montam_idle_energy_level"
    private let lastSeenKey = "montam_idle_last_seen"

    var canSummonEvolution: Bool { evolutionEnergy >= 100 }
    var enemyHealthRatio: Double {
        enemyMaxHP == 0 ? 0 : Double(enemyHP) / Double(enemyMaxHP)
    }
    var attackUpgradeCost: Int { 40 + attackLevel * 28 }
    var energyUpgradeCost: Int { 35 + energyLevel * 24 }
    var isEventBattle: Bool {
        appModel?.selectedLevelId?.lowercased().contains("event") == true
            || EventRuntime.shared.activeEvent != nil
    }

    var isStoryBattle: Bool {
        appModel?.selectedStoryChapter != nil
    }

    var enemyImageName: String {
        if let event = EventRuntime.shared.activeEvent {
            return event.icon ?? "skin_imperion_exalted_default"
        }
        if let chapter = appModel?.selectedStoryChapter {
            return chapter.enemyImage
        }
        return "skin_imperion_exalted_default"
    }

    func configure(
        appModel: AppModel,
        onEventVictory: @escaping (EventVictoryResult) -> Void
    ) {
        self.appModel = appModel
        self.onEventVictory = onEventVictory
        guard !configured else { return }
        configured = true

        loadIdleProgress()
        loadBattleForms()
        configureStartingForm()
        eventAttacks = EventAttackLoader.load()
        battleTitle =
            EventRuntime.shared.activeEvent?.title
            ?? appModel.selectedStoryChapter?.title
        storyText =
            EventRuntime.shared.activeEvent?.storyText
            ?? appModel.selectedStoryChapter?.storyText
        battleBackgroundName =
            EventRuntime.shared.activeEvent?.battleBackground
            ?? appModel.selectedStoryChapter?.battleBackground
            ?? GameConfigManager.shared.config.homeBackgroundImage
            ?? "montam_bg_dark"
        rollNextEvolutionForm()
        claimOfflineRewards()
        spawnEnemy()
        refreshCurrencies()
    }

    func runAutoBattle() async {
        while !Task.isCancelled {
            try? await Task.sleep(
                nanoseconds: UInt64(autoAttackInterval * 1_000_000_000)
            )
            guard !Task.isCancelled, !isEventBattle, !isStoryBattle else {
                continue
            }
            attackEnemy(isAuto: true)
        }
    }

    func attackEnemy(isAuto: Bool = false) {
        let now = CACurrentMediaTime()
        guard isAuto || now - lastAttackTime > 0.12 else { return }
        lastAttackTime = now

        enemyHP = max(0, enemyHP - attackDamage)
        evolutionEnergy = min(100, evolutionEnergy + energyGain)
        pulsePlayer()

        if enemyHP == 0 {
            handleEnemyDefeated()
        }
    }

    func summonEvolutionCard() {
        guard canSummonEvolution else { return }
        guard !availableEvolutionForms.isEmpty else {
            showMessage("SUMMON FORMS FIRST")
            evolutionEnergy = 0
            return
        }

        let form = nextEvolutionForm
        drawnForm = form

        if form != currentForm {
            currentForm = form
            pulsePlayer()
        }

        rollNextEvolutionForm()
        evolutionEnergy = 0

        Task {
            try? await Task.sleep(nanoseconds: 850_000_000)
            if drawnForm == form {
                drawnForm = nil
            }
        }
    }

    func useEventAttack(_ attack: EventAttack) {
        enemyHP = max(0, enemyHP - attack.power)
        showMessage(attack.title.uppercased())

        if enemyHP == 0 {
            handleEnemyDefeated()
        }
    }

    func upgradeAttack() {
        guard MontamCoinsManager.shared.spend(attackUpgradeCost) else {
            showMessage("NOT ENOUGH COINS")
            return
        }

        attackLevel += 1
        saveIdleProgress()
        refreshCurrencies()
        showMessage("ATTACK LV \(attackLevel)")
    }

    func upgradeEnergy() {
        guard MontamCoinsManager.shared.spend(energyUpgradeCost) else {
            showMessage("NOT ENOUGH COINS")
            return
        }

        energyLevel += 1
        saveIdleProgress()
        refreshCurrencies()
        showMessage("ENERGY LV \(energyLevel)")
    }

    func exitBattle() {
        saveLastSeen()
        appModel?.selectedLevelId = nil
        appModel?.selectedStoryChapter = nil
        appModel?.selectedBattleDifficulty = nil
        EventRuntime.shared.clear()
        appModel?.appState = .home
    }

    func saveLastSeen() {
        UserDefaults.standard.set(
            Date().timeIntervalSince1970,
            forKey: lastSeenKey
        )
    }

    private func spawnEnemy() {
        enemyMaxHP = Int(
            Double(130 + stage * 35) * difficulty.enemyHpMultiplier
        )
        enemyHP = enemyMaxHP
    }

    private func handleEnemyDefeated() {
        grantKillRewards()

        if isEventBattle {
            eventKills += 1
            if eventKills >= eventTargetKills {
                finishEventBattle()
                return
            }
        } else if isStoryBattle {
            eventKills += 1
            if eventKills >= storyTargetKills {
                finishStoryBattle()
                return
            }
        }

        stage += 1
        spawnEnemy()
    }

    private func grantKillRewards() {
        let montamCoins = scaledReward(stageRewardCoins)
        MontamCoinsManager.shared.add(montamCoins)
        PassProgressManager.shared.addPointsToAllPasses(isEventBattle ? 12 : 5)

        if stage.isMultiple(of: 5) {
            MontamSaphirsManager.shared.add(scaledReward(1))
        }

        if isEventBattle {
            let reward = EventRuntime.shared.activeEvent?.rewards
            MontamContainersManager.shared.add(
                scaledReward(max(1, (reward?.montamContainers ?? 20) / 10))
            )
            if stage.isMultiple(of: 3) {
                MontamRubysManager.shared.add(
                    scaledReward(max(1, reward?.montamRubys ?? 1))
                )
            }
        }

        refreshCurrencies()
        showMessage("+\(montamCoins) COINS")
    }

    private func finishEventBattle() {
        guard !eventEnded else { return }
        eventEnded = true

        let event = EventRuntime.shared.activeEvent
        let reward = event?.rewards
        let medalDefinition = medalDefinition(for: reward?.medalId)
        let montamCoins = scaledReward(reward?.montamCoins ?? stageRewardCoins)
        let montamRubys = scaledReward(reward?.montamRubys ?? 0)
        let tokens = scaledReward(reward?.montamContainers ?? 0)
        let montamLiquid = scaledReward(reward?.montamLiquid ?? 0)
        let eggRewards = reward?.eggs ?? []
        let medals = reward?.medals ?? 0

        MontamCoinsManager.shared.add(montamCoins)
        MontamRubysManager.shared.add(montamRubys)
        MontamContainersManager.shared.add(tokens)
        MontamLiquidManager.shared.add(montamLiquid)

        for eggReward in eggRewards {
            EggInventoryManager.shared.add(
                eggReward.amount,
                eggId: eggReward.eggId
            )
        }

        if let medalId = reward?.medalId, medals > 0 {
            MontamMedalManager.shared.add(medals, medalId: medalId)
        }

        refreshCurrencies()
        onEventVictory?(
            EventVictoryResult(
                title: event?.title ?? "Event Clear",
                icon: event?.icon ?? enemyImageName,
                montamCoins: montamCoins,
                montamRubys: montamRubys,
                montamContainers: tokens,
                montamLiquid: montamLiquid,
                eggRewards: eggRewards,
                medalId: reward?.medalId,
                medalTitle: medalDefinition?.title,
                medalIcon: medalDefinition?.icon,
                medals: medals
            )
        )
    }

    private func finishStoryBattle() {
        guard !eventEnded else { return }
        eventEnded = true

        let chapter = appModel?.selectedStoryChapter
        let reward = chapter?.rewards
        let medalDefinition = medalDefinition(for: reward?.medalId)
        let montamCoins = scaledReward(reward?.montamCoins ?? stageRewardCoins)
        let montamRubys = scaledReward(reward?.montamRubys ?? 0)
        let montamSaphirs = scaledReward(reward?.montamSaphirs ?? 0)
        let tokens = scaledReward(reward?.montamContainers ?? 0)
        let montamLiquid = scaledReward(reward?.montamLiquid ?? 0)
        let eggRewards = reward?.eggs ?? []
        let medals = scaledReward(reward?.medals ?? 0)

        MontamCoinsManager.shared.add(montamCoins)
        MontamRubysManager.shared.add(montamRubys)
        MontamSaphirsManager.shared.add(montamSaphirs)
        MontamContainersManager.shared.add(tokens)
        MontamLiquidManager.shared.add(montamLiquid)

        for eggReward in eggRewards {
            EggInventoryManager.shared.add(
                scaledReward(eggReward.amount),
                eggId: eggReward.eggId
            )
        }

        if let medalId = reward?.medalId, medals > 0 {
            MontamMedalManager.shared.add(medals, medalId: medalId)
        }

        refreshCurrencies()
        onEventVictory?(
            EventVictoryResult(
                title: chapter?.title ?? "Story Clear",
                icon: chapter?.icon ?? enemyImageName,
                montamCoins: montamCoins,
                montamRubys: montamRubys,
                montamContainers: tokens,
                montamLiquid: montamLiquid,
                eggRewards: eggRewards,
                medalId: reward?.medalId,
                medalTitle: medalDefinition?.title,
                medalIcon: medalDefinition?.icon,
                medals: medals
            )
        )
    }

    private func medalDefinition(for medalId: String?) -> MontamMedalDefinition?
    {
        guard let medalId else { return nil }
        return UpgradeConfigLoader.load().medalDefinitions.first {
            $0.id == medalId
        }
    }

    private func rollNextEvolutionForm() {
        nextEvolutionForm =
            availableEvolutionForms.randomElement()
            ?? currentForm
    }

    private var availableEvolutionForms: [BattleEvolutionForm] {
        let ownedIds = Set(
            appModel?.teamManager.ownedCharacters.map(\.baseId) ?? []
        )
        return battleForms.filter { form in
            !form.isFeral && ownedIds.contains(form.characterId)
        }
    }

    private func loadBattleForms() {
        do {
            let characters: [Character] = try JSONLoader.load("characters")
            let forms = characters.map(BattleEvolutionForm.init(character:))
            battleForms = forms.isEmpty ? [.fallbackFeral] : forms
        } catch {
            print("Battle forms load failed:", error)
            battleForms = [.fallbackFeral]
        }
    }

    private func configureStartingForm() {
        let ownedIds = Set(
            appModel?.teamManager.ownedCharacters.map(\.baseId) ?? []
        )

        currentForm =
            battleForms.first {
                $0.isFeral && ownedIds.contains($0.characterId)
            }
            ?? battleForms.first {
                ownedIds.contains($0.characterId)
            }
            ?? battleForms.first {
                $0.isFeral
            }
            ?? .fallbackFeral

        nextEvolutionForm =
            availableEvolutionForms.randomElement()
            ?? currentForm
    }

    private var attackDamage: Int {
        let baseDamage = currentForm.attackPower + attackLevel * 4
        return Int(Double(baseDamage) * elementMultiplier)
    }

    private var elementMultiplier: Double {
        ElementSystem.multiplier(
            attacker: currentForm.element,
            defender: enemyElement
        )
    }

    private var enemyElement: MontamElement {
        MontamElement.parse(
            EventRuntime.shared.activeEvent?.enemyElement
                ?? appModel?.selectedStoryChapter?.enemyElement
        )
    }

    private var energyGain: Double {
        currentForm.energyGain + Double(energyLevel - 1) * 1.5
    }

    private var autoAttackInterval: TimeInterval {
        max(0.45, 1.35 - Double(attackLevel) * 0.04)
    }

    private var stageRewardCoins: Int {
        10 + stage * 3
    }

    private var eventTargetKills: Int {
        max(1, EventRuntime.shared.activeEvent?.targetStages ?? 5)
    }

    private var storyTargetKills: Int {
        max(1, appModel?.selectedStoryChapter?.targetStages ?? 5)
    }

    private var difficulty: BattleDifficulty {
        appModel?.selectedBattleDifficulty
            ?? GameConfigManager.shared.config.battleDifficulties.first
            ?? GameConfig.fallback.battleDifficulties[0]
    }

    private func scaledReward(_ value: Int) -> Int {
        Int((Double(value) * difficulty.rewardMultiplier).rounded())
    }

    private func loadIdleProgress() {
        let defaults = UserDefaults.standard
        attackLevel = max(1, defaults.integer(forKey: attackLevelKey))
        energyLevel = max(1, defaults.integer(forKey: energyLevelKey))
    }

    private func saveIdleProgress() {
        let defaults = UserDefaults.standard
        defaults.set(attackLevel, forKey: attackLevelKey)
        defaults.set(energyLevel, forKey: energyLevelKey)
    }

    private func claimOfflineRewards() {
        guard !isEventBattle else { return }

        let defaults = UserDefaults.standard
        let lastSeen = defaults.double(forKey: lastSeenKey)
        saveLastSeen()

        guard lastSeen > 0 else { return }

        let offlineSeconds = min(
            8 * 60 * 60,
            max(0, Date().timeIntervalSince1970 - lastSeen)
        )
        guard offlineSeconds >= 60 else { return }

        let kills = Int(offlineSeconds / 45) + attackLevel
        let montamCoins = kills * max(5, stageRewardCoins)
        let montamSaphirs = kills / 12

        MontamCoinsManager.shared.add(montamCoins)
        MontamSaphirsManager.shared.add(montamSaphirs)
        refreshCurrencies()
        showMessage("OFFLINE +\(montamCoins) COINS +\(montamSaphirs) SAPHIRS")
    }

    private func refreshCurrencies() {
        montamCoins = MontamCoinsManager.shared.montamCoins
        montamSaphirs = MontamSaphirsManager.shared.montamSaphirs
    }

    private func pulsePlayer() {
        playerPulse = true
        Task {
            try? await Task.sleep(nanoseconds: 110_000_000)
            playerPulse = false
        }
    }

    private func showMessage(_ text: String) {
        floatingMessage = text
        Task {
            try? await Task.sleep(nanoseconds: 900_000_000)
            if floatingMessage == text {
                floatingMessage = nil
            }
        }
    }
}

#Preview {
    GameView()
        .environmentObject(AppModel())
}
