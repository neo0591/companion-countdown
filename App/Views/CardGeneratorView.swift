import SwiftUI
import Photos
import UIKit

/// 纪念卡片生成：自动匹配语录 + 星空模板，保存相册 / 分享
struct CardGeneratorView: View {
    @EnvironmentObject var store: CompanionStore
    @EnvironmentObject var purchaseManager: PurchaseManager

    @State private var selectedTemplate: CardTemplate = .starfield
    @State private var showProWall = false
    @State private var toast: String?

    private var currentPet: Pet? { store.pets.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let pet = currentPet {
                    VStack(spacing: 20) {
                        cardPreview(pet)
                        templatePicker(pet)
                        actionButtons(pet)
                    }
                    .padding()
                } else {
                    Text("先添加宠物，再生成纪念卡片")
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.top, 80)
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("纪念卡片")
            .sheet(isPresented: $showProWall) {
                ProShopView()
            }
            .overlay(alignment: .bottom) {
                if let toast {
                    Text(toast)
                        .font(.subheadline)
                        .padding()
                        .background(.black.opacity(0.8))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                        .padding(.bottom, 20)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: toast)
        }
    }

    // MARK: - Preview

    private func cardPreview(_ pet: Pet) -> some View {
        StarfieldCardView(
            petName: pet.name,
            remainingDays: CompanionCalculator.remainingDays(
                species: pet.species, size: pet.size,
                birthday: pet.birthday, dailyMinutes: pet.dailyCompanionMinutes),
            accompaniedDays: CompanionCalculator.accompaniedDays(birthday: pet.birthday),
            quote: QuoteStore.quote(forRemainingDays: CompanionCalculator.remainingDays(
                species: pet.species, size: pet.size,
                birthday: pet.birthday, dailyMinutes: pet.dailyCompanionMinutes)),
            template: selectedTemplate
        )
        .frame(width: 360, height: 540)
        .shadow(radius: 12)
        .scaleEffect(0.9)
    }

    // MARK: - Template picker

    private func templatePicker(_ pet: Pet) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(CardTemplate.allCases) { template in
                    let locked = template.isPro && !store.proUnlocked
                    Button {
                        if locked {
                            showProWall = true
                        } else {
                            selectedTemplate = template
                        }
                    } label: {
                        VStack(spacing: 6) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(templateGradient(template))
                                    .frame(width: 64, height: 64)
                                if locked {
                                    Image(systemName: "lock.fill")
                                        .foregroundStyle(.white)
                                        .font(.title3)
                                } else {
                                    Image(systemName: "sparkles")
                                        .foregroundStyle(.white)
                                }
                            }
                            Text(template.displayName)
                                .font(.caption)
                                .foregroundStyle(selectedTemplate == template ? Theme.accent : Theme.textSecondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private func templateGradient(_ template: CardTemplate) -> LinearGradient {
        LinearGradient(
            colors: [Theme.starfieldTop.opacity(0.7), Theme.starfieldBottom.opacity(0.7)],
            startPoint: .top, endPoint: .bottom)
    }

    // MARK: - Actions

    private func actionButtons(_ pet: Pet) -> some View {
        HStack(spacing: 12) {
            Button {
                saveToPhotos(pet)
            } label: {
                Label("保存相册", systemImage: "square.and.arrow.down")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Theme.cardWarm)
                    .clipShape(Capsule())
            }

            ShareLink(item: Image(uiImage: renderCardImage(pet)), preview: SharePreview("\(pet.name)的陪伴卡片")) {
                Label("分享", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Theme.accent)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
    }

    // MARK: - Render & Save

    /// 用 ImageRenderer 把 SwiftUI 视图渲染成 UIImage
    private func renderCardImage(_ pet: Pet) -> UIImage {
        let view = StarfieldCardView(
            petName: pet.name,
            remainingDays: CompanionCalculator.remainingDays(
                species: pet.species, size: pet.size,
                birthday: pet.birthday, dailyMinutes: pet.dailyCompanionMinutes),
            accompaniedDays: CompanionCalculator.accompaniedDays(birthday: pet.birthday),
            quote: QuoteStore.quote(forRemainingDays: CompanionCalculator.remainingDays(
                species: pet.species, size: pet.size,
                birthday: pet.birthday, dailyMinutes: pet.dailyCompanionMinutes)),
            template: selectedTemplate
        )
        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = .init(width: 400, height: 600)
        return renderer.uiImage ?? UIImage()
    }

    private func saveToPhotos(_ pet: Pet) {
        let image = renderCardImage(pet)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        withAnimation {
            toast = "已保存到相册 🎉"
        }
        // 自动消失
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { toast = nil }
        }
    }
}
