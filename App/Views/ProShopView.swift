import SwiftUI

/// Pro 商店：一次性买断，解锁多宠物 / 锁屏小组件 / 全部卡片模板
struct ProShopView: View {
    @EnvironmentObject var store: CompanionStore
    @EnvironmentObject var purchaseManager: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero
                    VStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(.yellow)
                        Text("解锁 Pro，留住每一个它")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                        Text("一次性买断，永久解锁 · 无订阅 · 无广告")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(Theme.starfield)

                    // 权益
                    VStack(alignment: .leading, spacing: 16) {
                        ProBenefitRow(icon: "pawprint.fill", title: "无限宠物", subtitle: "为家里每只毛孩子都算一笔账")
                        ProBenefitRow(icon: "lock.fill", title: "锁屏小组件", subtitle: "解锁即点亮屏幕也在提醒你")
                        ProBenefitRow(icon: "sparkles", title: "全部卡片模板", subtitle: "星空 / 月色 / 爪印 / 晚霞 全开放")
                        ProBenefitRow(icon: "gift.fill", title: "生日提醒", subtitle: "不错过它的每一个整周年")
                    }
                    .padding()
                    .background(Theme.cardWarm.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    // 购买按钮
                    if store.proUnlocked {
                        Label("已解锁 Pro 🎉", systemImage: "checkmark.seal.fill")
                            .font(.headline)
                            .foregroundStyle(.green)
                            .padding(.vertical, 12)
                    } else {
                        Button {
                            Task { await purchaseManager.purchasePro() }
                        } label: {
                            HStack {
                                Text(purchaseManager.isPurchasing ? "购买中…" : "¥12 买断 Pro")
                                    .font(.headline)
                                if purchaseManager.isPurchasing {
                                    ProgressView()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Theme.accent)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                        }
                        .disabled(purchaseManager.isPurchasing)

                        Button {
                            Task { await purchaseManager.restorePurchases() }
                        } label: {
                            Text("恢复购买")
                                .font(.footnote)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        .padding(.top, 4)
                    }

                    if let error = purchaseManager.lastError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    Text("定价参考：同类买断 App 普遍 ¥12–18。首发价 ¥12，之后恢复 ¥18。")
                        .font(.caption2)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Pro")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

struct ProBenefitRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Theme.accent)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(Theme.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
    }
}
