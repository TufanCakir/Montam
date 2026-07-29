import Testing
@testable import Montam

@Suite("Game Progression")
struct GameProgressionTests {
    @Test("Progression values clamp unsafe config input")
    func clampsUnsafeProgressionValues() {
        let progression = GameProgressionData(
            maxLevel: 0,
            xpBase: -20,
            xpLinearGrowth: -5,
            xpExponentialGrowth: 0.5
        )

        #expect(progression.resolvedMaxLevel == 1)
        #expect(progression.resolvedXPBase == 1)
        #expect(progression.resolvedXPLinearGrowth == 0)
        #expect(progression.resolvedXPExponentialGrowth == 1)
    }

    @Test("XP requirement grows from configured curve")
    func computesXPRequirement() {
        let progression = GameProgressionData(
            maxLevel: 100,
            xpBase: 100,
            xpLinearGrowth: 50,
            xpExponentialGrowth: 1.1
        )

        #expect(
            GameProgressionCalculator.xpNeeded(
                for: 1,
                progression: progression
            ) == 100
        )
        #expect(
            GameProgressionCalculator.xpNeeded(
                for: 3,
                progression: progression
            ) == 242
        )
        #expect(
            GameProgressionCalculator.xpNeeded(
                for: -4,
                progression: progression
            ) == 100
        )
    }

    @Test("Monster power uses HP, attack, defense, and level growth")
    func computesMonsterPower() {
        let monster = MonsterData(
            id: "test_monster",
            monsterName: "mon_test",
            name: "Test",
            rarity: "common",
            hp: 100,
            attack: 20,
            defense: 10,
            level: nil,
            xp: nil,
            monsterGrowthRate: 1.2,
            yOffset: 0,
            xOffset: 0,
            zOffset: 0
        )

        #expect(GameProgressionCalculator.power(for: monster, level: 1) == 40)
        #expect(GameProgressionCalculator.power(for: monster, level: 2) == 48)
    }
}
