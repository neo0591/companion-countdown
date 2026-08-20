import SwiftUI

/// 首页「陪伴报告」：人类年龄 + 已陪伴天数 + 「还能陪你 X 天」+ 催泪语录 + 幽默彩蛋
struct ReportView: View {
    @EnvironmentObject var store: CompanionStore
    @State private var selectedPetID: UUID?
    @State private var humor: String = QuoteStore.randomHumor()
    @State private var showEditForm = false

    private var currentPet: Pet? {
        if let selectedPetID,
           let pet = store.pets.first(where: { $0.id == selectedPetID }) {
            return pet
        }
        return store.pets.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let pet = currentPet {
                    VStack(spacing: 20) {
                        petHeader(pet)
                        statsGrid(pet)
                        remainingCard(pet)
                        quoteCard(pet)
                        humorBanner()
                    }
                    .padding()
                } else {
                    EmptyStateView()
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("陪伴报告")
            .toolbar {
                if store.pets.count > 1 {
                    ToolbarItem(placement: .topBarLeading) {
                        petSwitcher
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showEditForm = true
                    } label: {
                        Image(systemName: "pawprint")
                    }
                }
            }
            .sheet(isPresented: $showEditForm) {
                if let pet = currentPet {
                    PetFormView(editingPet: pet)
                }
            }
            .onAppear {
                if humor.isEmpty { humor = QuoteStore.randomHumor() }
            }
        }
    }

    // MARK: - Header

    private func petHeader(_ pet: Pet) -> some View {
        HStack(spacing: 16) {
            if let data = pet.photoData, let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
            } else {
                Image(systemName: pet.species == .cat ? "cat.fill" : "dog.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(Theme.accent)
                    .frame(width: 64, height: 64)
                    .background(Theme.cardWarm.opacity(0.6))
                    .clipShape(Circle())
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(pet.name)
                    .font(.title2.bold())
                    .foregroundStyle(Theme.textPrimary)
                Text("\(pet.species.rawValue) · \(pet.size.rawValue) · 每天陪 \(Double(pet.dailyCompanionMinutes)/60, specifier: "%.1f") 小时")
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
        }
        .padding()
        .background(Theme.cardWarm.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Stats

    private func statsGrid(_ pet: Pet) -> some View {
        let humanYears = CompanionCalculator.humanAgeYears(species: pet.species, size: pet.size, birthday: pet.birthday)
        let days = CompanionCalculator.accompaniedDays(birthday: pet.birthday)

        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            statCard(title: "换算人类年龄", value: "\(humanYears) 岁", icon: "person.fill")
            statCard(title: "已陪伴天数", value: "\(days) 天", icon: "calendar")
        }
    }

    private func statCard(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Theme.accent)
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(Theme.textPrimary)
            Text(title)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Remaining

    private func remainingCard(_ pet: Pet) -> some View {
        let remaining = CompanionCalculator.remainingDays(
            species: pet.species, size: pet.size,
            birthday: pet.birthday, dailyMinutes: pet.dailyCompanionMinutes)
        let isAnniv = CompanionCalculator.isAnniversary(birthday: pet.birthday)
        let annivYears = CompanionCalculator.anniversaryYears(birthday: pet.birthday)

        return VStack(spacing: 12) {
            if isAnniv && annivYears > 0 {
                Text("🎂 今天是\(pet.name)陪伴你的第 \(annivYears) 周年")
                    .font(.headline)
                    .foregroundStyle(Theme.accent)
            }
            Text("还能陪你")
                .font(.headline)
                .foregroundStyle(Theme.textSecondary)
            Text("\(remaining)")
                .font(.system(size: 64, weight: .heavy))
                .foregroundStyle(Theme.accent)
            Text("天")
                .font(.title3)
                .foregroundStyle(Theme.textSecondary)
            Text(QuoteStore.reportHeadline(remainingDays: remaining, petName: pet.name))
                .font(.subheadline)
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .background(
            LinearGradient(colors: [Theme.starfieldTop.opacity(0.9), Theme.starfieldBottom.opacity(0.9)],
                           startPoint: .top, endPoint: .bottom)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(alignment: .topTrailing) {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.5))
                .padding()
        }
    }

    // MARK: - Quote & Humor

    private func quoteCard(_ pet: Pet) -> some View {
        let remaining = CompanionCalculator.remainingDays(
            species: pet.species, size: pet.size,
            birthday: pet.birthday, dailyMinutes: pet.dailyCompanionMinutes)
        let quote = QuoteStore.quote(forRemainingDays: remaining)

        return VStack(spacing: 10) {
            Image(systemName: "quote.opening")
                .font(.title2)
                .foregroundStyle(Theme.accent)
            Text(quote)
                .font(.body.weight(.medium))
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Theme.cardWarm.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func humorBanner() -> some View {
        HStack(spacing: 8) {
            Image(systemName: "face.smiling")
                .foregroundStyle(Theme.accent)
            Text(humor)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
    }

    // MARK: - Pet switcher

    private var petSwitcher: some View {
        Menu {
            ForEach(store.pets) { pet in
                Button(pet.name) {
                    selectedPetID = pet.id
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(currentPet?.name ?? "")
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .font(.subheadline.weight(.medium))
        }
    }
}
