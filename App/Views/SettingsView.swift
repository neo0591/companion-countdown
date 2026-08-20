import SwiftUI

/// 设置页：隐私说明（纯本地）、反馈、开源链接
struct SettingsView: View {
    @EnvironmentObject var store: CompanionStore
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State private var showPro = false
    @State private var showAddForm = false

    var body: some View {
        NavigationStack {
            Form {
                Section("我的宠物") {
                    ForEach(store.pets) { pet in
                        HStack {
                            if let data = pet.photoData, let ui = UIImage(data: data) {
                                Image(uiImage: ui)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: pet.species == .cat ? "cat.fill" : "dog.fill")
                                    .foregroundStyle(Theme.accent)
                            }
                            Text(pet.name)
                            Spacer()
                            Text("\(pet.species.rawValue)")
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { store.removePet(store.pets[$0]) }
                    }
                    Button {
                        if store.canAddPet() {
                            showAddForm = true
                        } else {
                            showPro = true
                        }
                    } label: {
                        Label("添加宠物", systemImage: "plus")
                    }
                }

                Section("Pro") {
                    Button {
                        showPro = true
                    } label: {
                        HStack {
                            Label(store.proUnlocked ? "Pro 已解锁" : "解锁 Pro", systemImage: "crown.fill")
                                .foregroundStyle(store.proUnlocked ? .green : Theme.accent)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("隐私") {
                    Label("所有数据只存在你的设备上", systemImage: "lock.shield.fill")
                    Label("无账号 · 无云端 · 无广告", systemImage: "hand.raised.fill")
                }

                Section("关于") {
                    Label("TA的一辈子 v0.1.0", systemImage: "heart.fill")
                    Link("开源仓库（GitHub）", destination: URL(string: "https://github.com/neo0591/companion-countdown")!)
                    Link("问题反馈", destination: URL(string: "https://github.com/neo0591/companion-countdown/issues")!)
                }
            }
            .navigationTitle("设置")
            .sheet(isPresented: $showPro) {
                ProShopView()
            }
            .sheet(isPresented: $showAddForm) {
                PetFormView()
            }
        }
    }
}
