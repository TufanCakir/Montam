import SwiftData
import Testing
@testable import Montam

@Suite("SwiftData Services")
@MainActor
struct SwiftDataServiceTests {
    @Test("Gift claim applies rewards once")
    func giftClaimAppliesRewardsOnce() throws {
        let context = try makeContext()
        let save = GameSaveData(didCompleteOnboarding: true)
        context.insert(save)
        let gift = GiftData(
            id: "test_gift",
            rewards: [
                RewardData(id: "coins", resourceId: "coins", amount: 50),
                RewardData(id: "bits", resourceId: "bit", amount: 5),
            ]
        )

        GiftBoxService.claim(
            gift: gift,
            saves: [save],
            modelContext: context
        )
        GiftBoxService.claim(
            gift: gift,
            saves: [save],
            modelContext: context
        )

        #expect(save.coins == 50)
        #expect(save.bits == 5)
        #expect(save.claimedGiftIds == ["test_gift"])
    }

    @Test("Daily login claim applies reward and advances day")
    func dailyLoginClaimUpdatesSave() throws {
        let context = try makeContext()
        let save = GameSaveData(didCompleteOnboarding: true)
        context.insert(save)
        let reward = DailyLoginData(
            day: 3,
            rewards: [
                RewardData(id: "crystals", resourceId: "crystals", amount: 4)
            ]
        )

        DailyLoginService.claim(
            reward: reward,
            saves: [save],
            modelContext: context
        )

        #expect(save.crystals == 4)
        #expect(save.dailyLoginDay == 3)
        #expect(save.lastDailyClaimDate != nil)
        #expect(DailyLoginService.didClaimToday(save: save))
    }

    private func makeContext() throws -> ModelContext {
        let schema = Schema([
            GameSaveData.self,
            OwnedMonsterData.self,
            OwnedTamerData.self,
            OwnedSupporterData.self,
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
        return ModelContext(container)
    }
}
