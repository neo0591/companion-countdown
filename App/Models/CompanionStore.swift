import Foundation
import Combine

/// 本地存储：App Group 共享 UserDefaults（App + Widget 同源）
/// 纯本地、无后端、无账号；重启不丢；断网可用。
/// 说明：PRD 允许 SwiftData 或 UserDefaults，MVS 选 UserDefaults + Codable，
///       便于 Widget 通过 App Group 直接读到同一份数据。
@MainActor
final class CompanionStore: ObservableObject {

    static let appGroupID = "group.com.companion.countdown"
    static let shared = CompanionStore()

    private let petsKey = "pets"
    private let proUnlockedKey = "proUnlocked"
    private let onboardingSeenKey = "onboardingSeen"

    @Published var pets: [Pet] = [] {
        didSet { savePets() }
    }

    @Published var proUnlocked: Bool = false {
        didSet { defaults.set(proUnlocked, forKey: proUnlockedKey) }
    }

    @Published var hasSeenOnboarding: Bool = false {
        didSet { defaults.set(hasSeenOnboarding, forKey: onboardingSeenKey) }
    }

    private var defaults: UserDefaults {
        UserDefaults(suiteName: Self.appGroupID) ?? .standard
    }

    private init() {
        load()
    }

    func load() {
        proUnlocked = defaults.bool(forKey: proUnlockedKey)
        hasSeenOnboarding = defaults.bool(forKey: onboardingSeenKey)
        if let data = defaults.data(forKey: petsKey),
           let decoded = try? JSONDecoder().decode([Pet].self, from: data) {
            pets = decoded
        }
    }

    private func savePets() {
        if let data = try? JSONEncoder().encode(pets) {
            defaults.set(data, forKey: petsKey)
        }
        // 同步 Widget 用的轻量快照（只存第一只宠物，免费版规则）
        if let first = pets.first {
            if let snap = try? JSONEncoder().encode(first.snapshot) {
                defaults.set(snap, forKey: "widgetPet")
            }
        } else {
            defaults.removeObject(forKey: "widgetPet")
        }
    }

    // MARK: - CRUD

    func addPet(_ pet: Pet) {
        pets.append(pet)
    }

    func updatePet(_ pet: Pet) {
        if let idx = pets.firstIndex(where: { $0.id == pet.id }) {
            pets[idx] = pet
        }
    }

    func removePet(_ pet: Pet) {
        pets.removeAll { $0.id == pet.id }
    }

    /// 免费版规则：只允许 1 只宠物；第 2 只需要 Pro
    func canAddPet() -> Bool {
        proUnlocked || pets.count < 1
    }
}
