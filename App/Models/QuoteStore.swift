import Foundation

/// 催泪语录 + 幽默彩蛋
/// 文案口径：避开「死亡/寿命/还能活多久」，统一用「陪伴」「剩下一起的时间」。
struct QuoteStore {

    /// 催泪语录（按剩余陪伴天数区间匹配）
    static let tearsQuotes: [(minDays: Int, text: String)] = [
        (0,    "它用一生等你回家，你别让它等太久。"),
        (0,    "今天也好好陪它，就像它每天都好好等你一样。"),
        (30,   "它不是宠物，它是你的全世界，而你是它的全部。"),
        (60,   "狗是唯一爱你胜过爱自己的生物。"),
        (180,  "它在用有限的时间，给你无限的爱。"),
        (365,  "能遇见它，是你这辈子最划算的运气。"),
        (1000, "别总说以后，以后可能没有以后。"),
        (2000, "陪伴不是一时兴起，而是日复一日的惦记。"),
        (3000, "它记得你回家的脚步声，也记得你所有的好。"),
        (5000, "趁它还年轻，多带它看看世界。"),
    ]

    /// 幽默彩蛋（缓冲情绪，防止过度沉重）
    static let humorQuotes: [String] = [
        "温馨提示：你摸鱼的时候，它也在等你下班。",
        "它算不出自己的生日，但肯定记得你喂饭的时间。",
        "你以为你在养它，其实是它在驯化你每天回家。",
        "它的一生很短，但你放屁的时候它会装作没闻到——这就是爱。",
        "别看它现在高冷，你一开零食袋子它比谁都快。",
        "加班晚归的补偿方式：多撸五分钟。",
        "它不需要你很有钱，它只需要你准时回家。",
        "研究显示：宠物和主人会越长越像，包括黑眼圈。",
    ]

    /// 按剩余天数匹配一句催泪语录（取最贴近的）
    static func quote(forRemainingDays days: Int) -> String {
        let clamped = max(0, days)
        let sorted = tearsQuotes.sorted { $0.minDays > $1.minDays }
        for item in sorted where clamped >= item.minDays {
            return item.text
        }
        return tearsQuotes[0].text
    }

    /// 随机一条幽默彩蛋
    static func randomHumor() -> String {
        humorQuotes.randomElement() ?? humorQuotes[0]
    }

    /// 陪伴报告主文案（设计稿 §4）
    static func reportHeadline(remainingDays: Int, petName: String) -> String {
        if remainingDays <= 0 {
            return "剩下的每一天，都当最后一天好好陪\(petName)。"
        }
        return "还能陪你 \(remainingDays) 天 · 今天多陪它一会儿"
    }
}
