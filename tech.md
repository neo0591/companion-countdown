# 技术说明: 「TA的一辈子」宠物陪伴沙漏

## 栈
- 前端: SwiftUI (iOS 17+) / WidgetKit
- 后端: 无（纯本地）
- 数据库: UserDefaults + Codable（App Group 共享）
- 支付: StoreKit 2 一次性 IAP（non-consumable）

## 仓库
- 本地路径: `D:\WorkSpace\bot\companion-countdown\`
- 远程 URL: https://github.com/neo0591/companion-countdown

## 关键设计决策（ADR）
1. **存储选 UserDefaults 而非 SwiftData**：PRD 允许两者；UserDefaults + App Group 让 Widget 直接读到同一份数据，避免跨 target 复杂同步，MVS 最省。
2. **「还能陪你 X 天」算法**：参考陪伴总天数（物种+体型）× 每日陪伴时长/8h 折算「有效陪伴」，减去已消耗有效陪伴。这样陪伴 2h vs 4h 结果显著不同（验收标准）。
3. **文案禁忌**：全工程统一「陪伴剩余」，避开「寿命/死亡/还能活多久」，降低审核风险。

## 环境变量
| 变量 | 说明 |
|------|------|
| （无） | 无后端无 API Key；仅 App Store Connect 后台配置 IAP 产品 ID `com.companion.countdown.pro` 与 App Group `group.com.companion.countdown` |

## 本地运行
```bash
# macOS 需要 Xcode 15+ / XcodeGen
brew install xcodegen
xcodegen generate
open companion-countdown.xcodeproj
# 真机/模拟器运行 CompanionCountdown scheme
# 测试：xcodebuild test -scheme CompanionCountdown -destination 'platform=iOS Simulator,name=iPhone 15'
```

## 部署（App Store）
1. 在 App Store Connect 创建 App「TA的一辈子」
2. 配置 IAP 产品：`com.companion.countdown.pro`（一次性购买 ¥12 首发 / ¥18 常态）
3. 开启 App Group：`group.com.companion.countdown`（App + Widget 两个 target 的 entitlements 已就绪）
4. Xcode 归档 → Upload → TestFlight → 提审（隐私声明：纯本地，无数据收集）
5. 审核备注：强调无预测功能、无账号、纯本地，文案用「陪伴」口径

## 生产 URL
- App Store（待上架）；GitHub 开源: https://github.com/neo0591/companion-countdown
- 小红书：@TA的一辈子（引流入口）

## 已知限制（V1）
- 本仓库产出于 Windows，未在本机编译验证 → 需 macOS 跑通
- 卡片模板渲染用 `ImageRenderer`（iOS 16+），需真机确认相册权限文案
- 锁屏小组件为 Pro 权益，需在 Widget 支持 `.accessoryRectangular`（V1 仅主屏 small/medium）
- 生日提醒（本地通知）在 Backlog，未实现
