import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: CompanionStore
    @EnvironmentObject var purchaseManager: PurchaseManager

    var body: some View {
        Group {
            if !store.hasSeenOnboarding {
                OnboardingView()
            } else if store.pets.isEmpty {
                EmptyStateView()
            } else {
                TabView {
                    ReportView()
                        .tabItem { Label("陪伴报告", systemImage: "heart.fill") }
                    CardGeneratorView()
                        .tabItem { Label("纪念卡片", systemImage: "sparkles") }
                    SettingsView()
                        .tabItem { Label("设置", systemImage: "gearshape.fill") }
                }
            }
        }
        .task {
            // 启动时校验 Pro 授权 + 拉取商品（提前缓存）
            await purchaseManager.refreshEntitlements()
            if purchaseManager.products.isEmpty {
                await purchaseManager.loadProducts()
            }
        }
    }
}

/// 首只宠物添加入口（空状态）
struct EmptyStateView: View {
    @EnvironmentObject var store: CompanionStore
    @State private var showForm = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "pawprint.fill")
                .font(.system(size: 72))
                .foregroundStyle(Theme.accent)
            Text("它的一生只有十几年")
                .font(.title2.bold())
                .foregroundStyle(Theme.textPrimary)
            Text("先添加你的毛孩子，看看真正能陪它的时间还有多少")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
            Button {
                showForm = true
            } label: {
                Text("添加宠物")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.accent)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
        }
        .background(Theme.background.ignoresSafeArea())
        .sheet(isPresented: $showForm) {
            PetFormView()
        }
    }
}
