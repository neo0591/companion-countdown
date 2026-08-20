import Foundation

/// 陪伴计算引擎
/// 核心口径（PRD 约定，避开「寿命/死亡」词）：
/// - 人类年龄换算：通用宠物年龄对照表
/// - 已陪伴天数：从生日到今天
/// - 「还能陪你 X 天」：参考陪伴上限（物种+体型）换算出的参考天数 - 已陪伴天数
///   * 参考陪伴年限 × 365 = 参考陪伴总天数
///   * 再按「每天实际陪伴时长 / 理想陪伴时长(8h)」折算「有效陪伴」——这就是为什么
///     陪伴 2h vs 4h 的结果显著不同：陪伴越少，能真正「一起」的日子越少。
struct CompanionCalculator {

    /// 理想每天陪伴时长（小时）——用于把「实际陪伴」折算成「有效陪伴」
    static let idealDailyHours: Double = 8

    /// 参考陪伴年限（物种+体型）
    static func referenceYears(species: PetSpecies, size: PetSize) -> Int {
        species.referenceYears[size] ?? 15
    }

    /// 参考陪伴总天数
    static func referenceTotalDays(species: PetSpecies, size: PetSize) -> Int {
        referenceYears(species: species, size: size) * 365
    }

    /// 人类年龄换算（周岁 + 月份描述）
    static func humanAgeYears(species: PetSpecies, size: PetSize, birthday: Date, now: Date = Date()) -> Int {
        let years = calendarYears(birthday: birthday, now: now)
        // 通用换算表：第1年≈15岁，第2年≈24岁，之后每多1年按体型/物种递增
        switch years {
        case 0: return 0
        case 1: return 15
        case 2: return 24
        default:
            let extra = years - 2
            let perYear: Int
            switch species {
            case .cat: perYear = 4
            case .dog:
                switch size {
                case .small: perYear = 4
                case .medium: perYear = 5
                case .large: perYear = 6
                }
            }
            return 24 + extra * perYear
        }
    }

    /// 已陪伴天数（自然日，含今天）
    static func accompaniedDays(birthday: Date, now: Date = Date()) -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: birthday)
        let end = calendar.startOfDay(for: now)
        let days = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        return max(0, days)
    }

    /// 有效陪伴天数（已陪伴天数按每日陪伴时长折算）
    static func effectiveAccompaniedDays(birthday: Date, dailyMinutes: Int, now: Date = Date()) -> Int {
        let days = accompaniedDays(birthday: birthday, now: now)
        return effectiveDays(rawDays: days, dailyMinutes: dailyMinutes)
    }

    /// 「还能陪你 X 天」：参考陪伴总天数(按有效陪伴折算) - 已消耗的有效陪伴
    static func remainingDays(species: PetSpecies, size: PetSize, birthday: Date, dailyMinutes: Int, now: Date = Date()) -> Int {
        let total = referenceTotalDays(species: species, size: size)
        let consumed = effectiveAccompaniedDays(birthday: birthday, dailyMinutes: dailyMinutes, now: now)
        return max(0, total - consumed)
    }

    /// 剩余参考陪伴天数（不折算，用于 widget「还剩 X 天」每日自动 -1）
    static func remainingReferenceDays(species: PetSpecies, size: PetSize, birthday: Date, now: Date = Date()) -> Int {
        let total = referenceTotalDays(species: species, size: size)
        let days = accompaniedDays(birthday: birthday, now: now)
        return max(0, total - days)
    }

    /// 生日当天是否整周年
    static func isAnniversary(birthday: Date, now: Date = Date()) -> Bool {
        let cal = Calendar.current
        return cal.component(.month, from: birthday) == cal.component(.month, from: now)
            && cal.component(.day, from: birthday) == cal.component(.day, from: now)
    }

    /// 已陪伴整周年数
    static func anniversaryYears(birthday: Date, now: Date = Date()) -> Int {
        let cal = Calendar.current
        return max(0, cal.dateComponents([.year], from: birthday, to: now).year ?? 0)
    }

    // MARK: - Private

    private static func calendarYears(birthday: Date, now: Date) -> Int {
        Calendar.current.dateComponents([.year], from: birthday, to: now).year ?? 0
    }

    /// 按每日陪伴时长把自然日折算成有效陪伴日
    /// 例：每天 2h → 有效 = 自然日 × 2/8；每天 4h → 自然日 × 4/8
    private static func effectiveDays(rawDays: Int, dailyMinutes: Int) -> Int {
        let hours = Double(dailyMinutes) / 60.0
        let ratio = min(max(hours / idealDailyHours, 0), 1)
        return Int((Double(rawDays) * ratio).rounded())
    }
}
