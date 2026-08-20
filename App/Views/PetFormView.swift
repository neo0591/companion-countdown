import SwiftUI
import PhotosUI

/// 添加/编辑宠物档案：猫/狗 + 体型 + 生日 + 每天实际陪伴时长（滑杆）+ 照片
/// 主路径 ≤3 次点击（设计稿 §2）
struct PetFormView: View {
    @EnvironmentObject var store: CompanionStore
    @Environment(\.dismiss) private var dismiss

    var editingPet: Pet?

    @State private var name = ""
    @State private var species: PetSpecies = .cat
    @State private var size: PetSize = .small
    @State private var birthday = Calendar.current.date(byAdding: .year, value: -2, to: Date()) ?? Date()
    @State private var dailyHours: Double = 2.0 // 滑杆：0.5 ~ 8h
    @State private var photoItem: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var showProWall = false

    var body: some View {
        NavigationStack {
            Form {
                Section("它叫什么") {
                    TextField("给它起个名字", text: $name)
                        .font(.body)
                }

                Section("它是？") {
                    Picker("物种", selection: $species) {
                        ForEach(PetSpecies.allCases) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)

                    Picker("体型", selection: $size) {
                        ForEach(PetSize.allCases) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("生日") {
                    DatePicker("生日", selection: $birthday, in: ...Date(), displayedComponents: .date)
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("每天实际陪伴时长")
                            Spacer()
                            Text(String(format: "%.1f 小时", dailyHours))
                                .foregroundStyle(Theme.accent)
                                .bold()
                        }
                        Slider(value: $dailyHours, in: 0.5...8, step: 0.5)
                        Text("包括撸它、陪玩、散步的时间。陪得越少，能一起的「有效日子」越短。")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }

                Section("照片（可选）") {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        HStack {
                            if let photoData, let ui = UIImage(data: photoData) {
                                Image(uiImage: ui)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 48, height: 48)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "camera.fill")
                                    .frame(width: 48, height: 48)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            Text(photoData == nil ? "选择一张它的照片" : "更换照片")
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                    .onChange(of: photoItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                // 压缩到 800px 内，控制本地存储体积
                                photoData = compress(data)
                            }
                        }
                    }
                }

                if editingPet == nil && !store.canAddPet() {
                    Section {
                        Button {
                            showProWall = true
                        } label: {
                            Label("免费版只能养 1 只，解锁 Pro 可添加更多", systemImage: "crown.fill")
                                .foregroundStyle(Theme.accent)
                        }
                    }
                }
            }
            .navigationTitle(editingPet == nil ? "添加宠物" : "编辑宠物")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(isPresented: $showProWall) {
                ProShopView()
            }
            .onAppear(perform: loadEditing)
        }
    }

    private func loadEditing() {
        guard let pet = editingPet else { return }
        name = pet.name
        species = pet.species
        size = pet.size
        birthday = pet.birthday
        dailyHours = Double(pet.dailyCompanionMinutes) / 60.0
        photoData = pet.photoData
    }

    private func save() {
        var pet = editingPet ?? Pet(name: "", species: species, size: size, birthday: birthday)
        pet.name = name.trimmingCharacters(in: .whitespaces)
        pet.species = species
        pet.size = size
        pet.birthday = birthday
        pet.dailyCompanionMinutes = Int(dailyHours * 60)
        pet.photoData = photoData

        if editingPet != nil {
            store.updatePet(pet)
        } else {
            store.addPet(pet)
        }
        dismiss()
    }

    /// 简单压缩：限制最长边 800px、JPEG 压缩 0.7
    private func compress(_ data: Data) -> Data? {
        guard let img = UIImage(data: data) else { return data }
        let maxSide: CGFloat = 800
        let size = img.size
        let scale = min(1, maxSide / max(size.width, size.height))
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            img.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: 0.7)
    }
}
