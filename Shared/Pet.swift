import Foundation
import SwiftUI

/// 宠物物种
enum PetSpecies: String, Codable, CaseIterable, Identifiable {
    case cat = "猫"
    case dog = "狗"

    var id: String { rawValue }

    /// 参考陪伴年限（按物种+体型，仅作温柔参考，不做寿命承诺）
    /// 换算表参考通用宠物年龄对照（第一年≈15岁，第二年≈24岁，之后逐年递增）
    var referenceYears: [PetSize: Int] {
        switch self {
        case .cat:
            return [.small: 15, .medium: 15, .large: 14]
        case .dog:
            return [.small: 15, .medium: 13, .large: 11]
        }
    }
}

/// 体型
enum PetSize: String, Codable, CaseIterable, Identifiable {
    case small = "小型"
    case medium = "中型"
    case large = "大型"

    var id: String { rawValue }
}

/// 宠物档案（SwiftData/Codable 兼容，纯本地存储）
struct Pet: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var species: PetSpecies
    var size: PetSize
    var birthday: Date
    /// 每天实际陪伴时长（分钟），滑杆输入 0.5h ~ 8h
    var dailyCompanionMinutes: Int = 120
    /// 照片数据（压缩后的 JPEG），可为 nil
    var photoData: Data?

    /// 用于 widget 共享的瘦身模型
    var snapshot: PetSnapshot {
        PetSnapshot(
            id: id,
            name: name,
            species: species,
            size: size,
            birthday: birthday,
            dailyCompanionMinutes: dailyCompanionMinutes
        )
    }
}

/// Widget 与 App 共享的轻量模型（JSON 存入 App Group UserDefaults）
struct PetSnapshot: Codable, Hashable {
    var id: UUID
    var name: String
    var species: PetSpecies
    var size: PetSize
    var birthday: Date
    var dailyCompanionMinutes: Int
}
