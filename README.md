# TA的一辈子 — 宠物陪伴沙漏 🐾

> 它的一生都在等你。

一个养宠人给自己算的账：它的一生只有十几年，剥掉你上班、睡觉、刷手机的时间，你这辈子真正能陪它的，还剩多少天？「TA的一辈子」帮你把答案算出来，并提醒你——**今天也要好好陪它。**

纯本地、无账号、无广告、无云端。数据只属于你和它。

---

## 为什么做这个

网上只有粗糙的「宠物年龄换算表」或海外英文 App。我们想要一个中文的、有情绪的、能算出「还能陪它多少天」的小工具——算完会心一击，然后去抱抱它。

**分享链**：算出「还能陪它 335 天」→ 震惊 / 愧疚 → 生成星空纪念卡片 → 发小红书 / 朋友圈 → 朋友也想算 → 裂变。

---

## 功能（MVS）

- 🐱 **添加宠物档案**：猫 / 狗 + 体型 + 生日 + 每天实际陪伴时长（滑杆）+ 照片
- 📊 **陪伴报告**：人类年龄换算 + 已陪伴天数 + 「还能陪你 X 天」+ 一句催泪语录 + 幽默彩蛋
- ✨ **纪念卡片生成**：自动匹配语录 + 星空模板，保存相册 / 分享
- 🕐 **桌面小组件**：主屏显示「还剩 X 天」，每日自动推进
- 👑 **Pro 买断**（一次性）：解锁多宠物、锁屏小组件、全部卡片模板

> 文案口径：避开「寿命 / 死亡 / 还能活多久」，统一用「陪伴剩余」「还能陪你 X 天」。

---

## 快速开始（开发者）

本项目是 iOS 原生 App（SwiftUI + WidgetKit + StoreKit 2），需要 macOS + Xcode 15+。

```bash
# 1. 安装 XcodeGen（生成 .xcodeproj）
brew install xcodegen

# 2. 生成工程
xcodegen generate

# 3. 打开工程
open companion-countdown.xcodeproj

# 4. 选择 CompanionCountdown scheme，真机或模拟器运行
```

### 单元测试

```bash
xcodebuild test -scheme CompanionCountdown -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## 技术栈

| 层 | 选型 |
|----|------|
| UI | SwiftUI（iOS 17+） |
| 小组件 | WidgetKit（App Group 共享数据） |
| 存储 | UserDefaults + Codable（纯本地，App Group 共享） |
| 支付 | StoreKit 2 一次性 IAP（non-consumable） |
| 后端 | 无 |

---

## 目录结构

```
App/       主 App（入口、视图、存储、支付）
Widget/    桌面小组件扩展
Shared/    App 与 Widget 共享的模型与计算引擎
Tests/     单元测试（陪伴计算核心逻辑）
project.yml  XcodeGen 工程描述
```

---

## Roadmap

- [x] v0.1.0：MVS 5 条全量（档案 / 报告 / 卡片 / 小组件 / Pro）
- [ ] 陪伴进度条（小爪子在进度条上走）
- [ ] 生日提醒
- [ ] 更多卡片模板（星空 / 月色 / 爪印 / 晚霞）
- [ ] 英文版草稿

---

## 链接

- 小红书：@TA的一辈子（获取最新教程与素材）
- 问题反馈 / 需求：请到 [Issues](https://github.com/neo0591/companion-countdown/issues)
- 喜欢请点 ⭐，这是对我们最大的鼓励

## License

MIT License — 见 [LICENSE](LICENSE)。

---

**它的一生很短，但你每天都在。**
