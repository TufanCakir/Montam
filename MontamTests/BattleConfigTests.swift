import Foundation
import Testing
@testable import Montam

@Suite("Battle Config")
struct BattleConfigTests {
    @Test("Bundled battle config has usable waves and backgrounds")
    func bundledBattleConfigIsUsable() throws {
        let config = try #require(
            JSONDataLoader.load("battleConfig", as: BattleConfigData.self)
        )

        #expect(config.groundYRatio > 0)
        #expect(config.walkDuration > 0)
        #expect(config.attackInterval > 0)
        #expect(config.fadeDuration > 0)
        #expect(!config.backgroundSequence.isEmpty)
        #expect(!config.playerMonsters.isEmpty)
        #expect(!config.waves.isEmpty)
        #expect(config.waves.allSatisfy { !$0.enemies.isEmpty })
    }

    @Test("Event battle config maps event rewards and enemy")
    func eventConfigUsesEventData() throws {
        let config = try #require(
            JSONDataLoader.load("battleConfig", as: BattleConfigData.self)
        )
        let eventJSON = """
        {
            "id": "test_event",
            "category": "boss",
            "eventBackground": "bg_test",
            "title": "Test Event",
            "description": "Fight",
            "enemyName": "test_enemy",
            "battleXPReward": 90,
            "rewards": [
                { "currency": "coins", "amount": 12 },
                { "currency": "crystal", "amount": 2 }
            ]
        }
        """
        let event = try JSONDecoder().decode(
            EventData.self,
            from: Data(eventJSON.utf8)
        )

        let eventConfig = config.configuredForEvent(event)

        #expect(eventConfig.backgroundSequence == ["bg_test"])
        #expect(eventConfig.waves.count == 2)
        #expect(eventConfig.waves[0].xpReward == 30)
        #expect(eventConfig.waves[1].xpReward == 90)
        #expect(eventConfig.waves[1].isBossWave)
        #expect(eventConfig.waves[1].enemies.first?.id == "test_enemy")
        #expect(eventConfig.rewards.coins == 12)
        #expect(eventConfig.rewards.crystals == 2)
        #expect(eventConfig.rewards.eventExp == 90)
    }
}
