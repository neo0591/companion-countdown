import SwiftUI

/// 卡片模板：免费 1 张，Pro 解锁全部
enum CardTemplate: String, CaseIterable, Identifiable {
    case starfield   // 星空（基础，免费）
    case moon        // 月色
    case pawprint    // 爪印
    case sunset      // 晚霞

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .starfield: return "星空"
        case .moon: return "月色"
        case .pawprint: return "爪印"
        case .sunset: return "晚霞"
        }
    }

    /// 免费版可用的模板（MVS：1 张基础卡片）
    static let freeTemplates: [CardTemplate] = [.starfield]

    var isPro: Bool { !Self.freeTemplates.contains(self) }
}

/// 星空卡片渲染（SwiftUI 纯代码绘制，ImageRenderer 导出）
struct StarfieldCardView: View {
    let petName: String
    let remainingDays: Int
    let accompaniedDays: Int
    let quote: String
    let template: CardTemplate

    private var gradient: LinearGradient {
        switch template {
        case .starfield:
            return LinearGradient(colors: [
                Color(red: 0.10, green: 0.06, blue: 0.22),
                Color(red: 0.32, green: 0.18, blue: 0.50)
            ], startPoint: .top, endPoint: .bottom)
        case .moon:
            return LinearGradient(colors: [
                Color(red: 0.10, green: 0.12, blue: 0.25),
                Color(red: 0.22, green: 0.30, blue: 0.45)
            ], startPoint: .top, endPoint: .bottom)
        case .pawprint:
            return LinearGradient(colors: [
                Color(red: 0.18, green: 0.10, blue: 0.20),
                Color(red: 0.42, green: 0.25, blue: 0.30)
            ], startPoint: .top, endPoint: .bottom)
        case .sunset:
            return LinearGradient(colors: [
                Color(red: 0.45, green: 0.16, blue: 0.28),
                Color(red: 0.90, green: 0.42, blue: 0.28)
            ], startPoint: .top, endPoint: .bottom)
        }
    }

    var body: some View {
        ZStack {
            gradient

            // 星星
            ForEach(0..<40, id: \.self) { i in
                Circle()
                    .fill(.white.opacity(Double.random(in: 0.15...0.6)))
                    .frame(width: CGFloat.random(in: 1.5...3.5))
                    .position(x: CGFloat.random(in: 10...390),
                              y: CGFloat.random(in: 10...560))
            }

            // 主内容
            VStack(spacing: 12) {
                Spacer()
                Image(systemName: template == .pawprint ? "pawprint.fill" : "heart.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white.opacity(0.9))

                Text(petName)
                    .font(.system(size: 34, weight: .heavy))
                    .foregroundStyle(.white)

                Text("还能陪你 \(remainingDays) 天")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white.opacity(0.95))

                Text("已陪伴 \(accompaniedDays) 天")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))

                Divider()
                    .frame(width: 60)
                    .overlay(.white.opacity(0.5))

                Text(quote)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)

                Spacer()

                Text("TA的一辈子 · 好好陪它")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.45))
                    .padding(.bottom, 16)
            }
        }
        .frame(width: 400, height: 600)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
