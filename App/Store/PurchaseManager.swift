import Foundation
import StoreKit

/// StoreKit 2 一次性 IAP（Pro 买断）
/// 产品：com.companion.countdown.pro（non-consumable 非消耗型）
/// 用法：@MainActor 环境下调用；购买成功后解锁，恢复购买走 currentEntitlements。
@MainActor
final class PurchaseManager: ObservableObject {

    static let shared = PurchaseManager()

    /// 与 App Store Connect 配置一致的产品 ID
    static let proProductID = "com.companion.countdown.pro"

    @Published private(set) var products: [Product] = []
    @Published private(set) var isPurchasing = false
    @Published var lastError: String?

    private var updatesTask: Task<Void, Never>?

    private init() {
        // 监听交易更新（购买完成、退款、续订等）——非消耗型主要处理购买成功
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    await self?.process(transaction: transaction)
                    await transaction.finish()
                }
            }
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    /// 拉取商品（在设置/商店页加载）
    func loadProducts() async {
        do {
            products = try await Product.products(for: [Self.proProductID])
        } catch {
            lastError = "商品加载失败：\(error.localizedDescription)"
        }
    }

    /// 购买 Pro（一次性买断）
    func purchasePro() async {
        guard !isPurchasing else { return }
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            guard let product = products.first(where: { $0.id == Self.proProductID }) else {
                // 未加载到商品时先尝试重新拉取
                await loadProducts()
                guard let product = products.first(where: { $0.id == Self.proProductID }) else {
                    lastError = "未找到 Pro 商品，请稍后重试"
                    return
                }
                try await purchase(product)
                return
            }
            try await purchase(product)
        } catch {
            lastError = "购买失败：\(error.localizedDescription)"
        }
    }

    private func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await process(transaction: transaction)
                await transaction.finish()
            } else {
                lastError = "交易验证失败"
            }
        case .userCancelled:
            break // 用户取消，静默
        case .pending:
            lastError = "购买待确认（家长同意或余额不足）"
        @unknown default:
            lastError = "未知购买状态"
        }
    }

    /// 恢复购买
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            lastError = "恢复失败：\(error.localizedDescription)"
        }
    }

    /// 启动时校验当前授权
    func refreshEntitlements() async {
        var unlocked = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.proProductID,
               transaction.revocationDate == nil {
                unlocked = true
            }
        }
        CompanionStore.shared.proUnlocked = unlocked
    }

    private func process(transaction: Transaction) async {
        if transaction.productID == Self.proProductID {
            CompanionStore.shared.proUnlocked = true
        }
    }
}
