import Testing
@testable import Montam

@Suite("Bundled JSON Catalogs")
struct JSONCatalogDecodingTests {
    @Test("Core game catalogs decode")
    func decodesCoreCatalogs() {
        #expect(JSONDataLoader.load("background", as: [BackgroundData].self)?.isEmpty == false)
        #expect(JSONDataLoader.load("battleConfig", as: BattleConfigData.self) != nil)
        #expect(JSONDataLoader.load("battleReward", as: [BattleRewardData].self)?.isEmpty == false)
        #expect(JSONDataLoader.load("daily", as: [DailyLoginData].self)?.isEmpty == false)
        #expect(JSONDataLoader.load("enemy", as: [EnemyData].self)?.isEmpty == false)
        #expect(JSONDataLoader.load("event", as: [EventData].self)?.isEmpty == false)
        #expect(JSONDataLoader.load("gift", as: [GiftData].self)?.isEmpty == false)
        #expect(JSONDataLoader.load("mission", as: [MissionData].self)?.isEmpty == false)
        #expect(JSONDataLoader.load("monster", as: [MonsterData].self)?.isEmpty == false)
        #expect(JSONDataLoader.load("music", as: [MusicData].self)?.isEmpty == false)
        #expect(JSONDataLoader.load("news", as: [NewsData].self)?.isEmpty == false)
        #expect(JSONDataLoader.load("tamer", as: [TamerData].self)?.isEmpty == false)
        #expect(JSONDataLoader.load("trade", as: [TradeOfferData].self)?.isEmpty == false)
    }

    @Test("Shop and summon catalogs decode")
    func decodesShopAndSummonCatalogs() {
        #expect(JSONDataLoader.load("gameVisual", as: GameVisualCatalogData.self) != nil)
        #expect(JSONDataLoader.load("itemShop", as: ItemShopData.self) != nil)
        #expect(JSONDataLoader.load("shop", as: ShopData.self) != nil)
        #expect(JSONDataLoader.load("summon", as: [SummonData].self)?.isEmpty == false)
        #expect(JSONDataLoader.load("summonCategory", as: [SummonCategoryData].self)?.isEmpty == false)
        #expect(JSONDataLoader.load("summonPool", as: [SummonPoolData].self)?.isEmpty == false)
    }

    @Test("Team catalogs decode")
    func decodesTeamCatalogs() {
        #expect(JSONDataLoader.load("evolution", as: [EvolutionData].self)?.isEmpty == false)
        #expect(JSONDataLoader.load("monsterAppearance", as: [MonsterAppearanceData].self)?.isEmpty == false)
        #expect(JSONDataLoader.load("supportMegaMonster", as: [SupporterData].self)?.isEmpty == false)
        #expect(JSONDataLoader.load("supportMonster", as: [SupporterData].self)?.isEmpty == false)
        #expect(JSONDataLoader.load("supportTamer", as: [SupporterData].self)?.isEmpty == false)
    }
}
