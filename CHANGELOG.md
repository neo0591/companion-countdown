# Changelog

本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/)。
版本格式：`vMAJOR.MINOR.PATCH`。

## [v0.1.0] - 2026-08-27（首发）

### 新增（MVS 5 条全量）

- **添加宠物档案**：猫 / 狗 + 体型 + 生日 + 每天实际陪伴时长（滑杆 0.5~8h）+ 照片
- **陪伴报告**：人类年龄换算 + 已陪伴天数 + 「还能陪你 X 天」+ 催泪语录 + 幽默彩蛋
- **纪念卡片生成**：语录自动匹配 + 星空模板，保存相册 / 分享
- **桌面小组件**：主屏显示「还剩 X 天」，每日自动推进（App Group 共享数据）
- **Pro 买断**：一次性 IAP，解锁多宠物 / 锁屏小组件 / 全部卡片模板，支持恢复购买

### 技术

- 纯本地存储（UserDefaults + Codable，App Group 共享），无后端、无账号、无第三方 SDK
- StoreKit 2 一次性非消耗型 IAP
- XcodeGen 工程描述（project.yml），支持 `xcodegen generate`

### 说明

- 文案统一「陪伴剩余」，避开「寿命 / 死亡」等审核敏感词
- 本版本由 Windows 环境产出源码，**待 macOS 编译验证后归档**
