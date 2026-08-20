import SwiftUI

/// 首次引导页（"它的一生只有十几年"）
struct OnboardingView: View {
    @EnvironmentObject var store: CompanionStore
    @State private var showForm = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("🐾")
                .font(.system(size: 80))
            Text("它的一生只有十几年")
                .font(.largeTitle.bold())
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center)
            Text("而你能真正陪它的时间，更短。\n先算一笔账，再好好陪它。")
                .font(.body)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            Button {
                showForm = true
            } label: {
                Text("开始算账")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.accent)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
        .background(Theme.background.ignoresSafeArea())
        .sheet(isPresented: $showForm) {
            PetFormView()
                .onDisappear {
                    // 关闭引导：无论是否添加成功都进入主流程
                    store.hasSeenOnboarding = true
                }
        }
    }
}
