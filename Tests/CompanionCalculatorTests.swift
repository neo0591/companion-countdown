import XCTest
@testable import companion_countdown

final class CompanionCalculatorTests: XCTestCase {

    /// 陪伴 2h vs 4h → 「还能陪 X 天」结果显著不同
    func testRemainingDaysDifferByDailyHours() {
        let birthday = Calendar.current.date(byAdding: .year, value: -3, to: Date())!
        let pet = Pet(name: "测试", species: .dog, size: .medium, birthday: birthday, dailyCompanionMinutes: 0)

        let with2h = CompanionCalculator.remainingDays(
            species: .dog, size: .medium,
            birthday: birthday, dailyMinutes: 120, now: Date())

        let with4h = CompanionCalculator.remainingDays(
            species: .dog, size: .medium,
            birthday: birthday, dailyMinutes: 240, now: Date())

        XCTAssertNotEqual(with2h, with4h, "陪伴时长不同，剩余天数必须不同")
        XCTAssertLessThan(with2h, with4h, "陪得越少，能一起的有效日子越少")
    }

    /// 已陪伴天数随生日推移正确
    func testAccompaniedDays() {
        let cal = Calendar.current
        let birthday = cal.date(byAdding: .day, value: -365, to: Date())!
        let days = CompanionCalculator.accompaniedDays(birthday: birthday, now: Date())
        XCTAssertEqual(days, 365, "一年前生日应为 365 天")
    }

    /// 生日当天显示整周年
    func testAnniversary() {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: Date())
        comps.year! -= 3
        let birthday = cal.date(from: comps)!
        XCTAssertTrue(CompanionCalculator.isAnniversary(birthday: birthday, now: Date()))
        XCTAssertEqual(CompanionCalculator.anniversaryYears(birthday: birthday, now: Date()), 3)
    }

    /// 人类年龄换算：1岁≈15，2岁≈24
    func testHumanAge() {
        let cal = Calendar.current
        let oneYearAgo = cal.date(byAdding: .year, value: -1, to: Date())!
        let twoYearsAgo = cal.date(byAdding: .year, value: -2, to: Date())!

        XCTAssertEqual(CompanionCalculator.humanAgeYears(species: .cat, size: .small, birthday: oneYearAgo, now: Date()), 15)
        XCTAssertEqual(CompanionCalculator.humanAgeYears(species: .cat, size: .small, birthday: twoYearsAgo, now: Date()), 24)
    }

    /// 语录匹配：剩余天数少 → 更珍惜向
    func testQuoteMatching() {
        let low = QuoteStore.quote(forRemainingDays: 10)
        let high = QuoteStore.quote(forRemainingDays: 4000)
        XCTAssertFalse(low.isEmpty)
        XCTAssertFalse(high.isEmpty)
    }
}
