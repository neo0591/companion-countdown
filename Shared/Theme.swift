import SwiftUI

/// 主题色：治愈系暖调（奶咖 / 奶油黄 / 暖橙）+ 星空紫渐变（卡片）
enum Theme {
    static let background = Color(red: 0.98, green: 0.95, blue: 0.90)   // 奶油黄
    static let cardWarm = Color(red: 0.96, green: 0.88, blue: 0.76)     // 奶咖
    static let accent = Color(red: 0.95, green: 0.60, blue: 0.30)       // 暖橙
    static let textPrimary = Color(red: 0.30, green: 0.24, blue: 0.18)
    static let textSecondary = Color(red: 0.55, green: 0.47, blue: 0.38)

    // 星空卡片渐变（星空紫，催泪反差）
    static let starfieldTop = Color(red: 0.15, green: 0.08, blue: 0.28)
    static let starfieldBottom = Color(red: 0.35, green: 0.20, blue: 0.50)
    static let starfield = LinearGradient(
        colors: [starfieldTop, starfieldBottom],
        startPoint: .top,
        endPoint: .bottom
    )
}
