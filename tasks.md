# Tasks — 「TA的一辈子」宠物陪伴沙漏（Phase 3 实现）

> 负责人: fe-dev（side-hustle-developer）
> 状态标记: `todo | doing | done | blocked`
> 本机无 macOS/Xcode → 编译验证项标记 `[待 macOS 验证]`，其余为工程/代码产出项。

## Sprint 1（当前，目标 2026-08-27 首单）

### P0 — MVS 5 条

- [ ] `doing` **T1 工程骨架**：目录结构 + XcodeGen `project.yml`（App target + Widget target）+ Info.plist + Assets 占位
  - 验收：`xcodegen generate` 在 macOS 可生成 .xcodeproj；两个 target 引用关系正确 `[待 macOS 验证]`
- [ ] `todo` **T2 数据模型 + 陪伴计算引擎**：`Pet`（猫/狗+体型+生日+每天陪伴时长+照片）、人类年龄换算表、剩余陪伴天数算法（2h vs 4h 结果显著不同）、生日周年判断
  - 验收：单元可读；陪 2h 与 4h 的「还能陪你 X 天」显著不同；生日当天显示整周年
- [ ] `todo` **T3 本地存储**：UserDefaults（App Group 共享，Widget 同源）+ Codable；重启不丢
  - 验收：断网/飞行模式全功能正常；重启后数据保留
- [ ] `todo` **T4 首页「陪伴报告」**：人类年龄 + 已陪伴天数 + 「还能陪你 X 天」+ 一句催泪语录 + 幽默彩蛋
  - 验收：添加宠物后首页立即显示报告
- [ ] `todo` **T5 添加/编辑宠物档案**：猫/狗 + 体型 + 生日 + 每天实际陪伴时长滑杆 + 照片（≤3 次点击）
  - 验收：表单可录入并回显
- [ ] `todo` **T6 纪念卡片生成**：语录自动匹配 + 星空模板（基础 1 张 / Pro 全部），ImageRenderer 渲染，保存相册 + 分享面板
  - 验收：生成图片含宠物名+剩余天数+语录；可保存相册、唤起分享
- [ ] `todo` **T7 桌面小组件（WidgetKit）**：主屏显示「还剩 X 天」，Timeline 过 0 点自动 -1
  - 验收：与 App 数据一致；跨日自动推进
- [ ] `todo` **T8 Pro 买断（StoreKit 2）**：一次性 IAP 解锁第 2+ 只宠物 / 锁屏小组件 / 更多卡片模板；恢复购买
  - 验收：第 2 只宠物触发购买；购买后立即可用；恢复购买有效（StoreKit 沙箱验证）`[待 macOS 验证]`

### P1 — 发布配套

- [ ] `todo` **T9 README.md**（中文叙事，照 design.md 首段）+ LICENSE(MIT) + .gitignore + CHANGELOG + RELEASE_NOTES
- [ ] `todo` **T10 GitHub 发布**：repo create（public, MIT）、push、tag v0.1.0、Release
- [ ] `todo` **T11 tech.md**：栈、环境变量、本地运行、部署、已知限制

### Backlog（Should/Could，不进 Sprint 1）

- [ ] 陪伴进度条（小爪子在进度条上走）P1
- [ ] 生日提醒（本地通知）P1
- [ ] 锁屏小组件 Pro 专属
- [ ] 更多卡片模板（Pro）
- [ ] 多语言（英文）草稿

## 验收汇总（PRD §5）

| 场景 | 通过 |
|------|------|
| 添加宠物 | T4/T5 |
| 陪伴计算 | T2 |
| 卡片生成 | T6 |
| 桌面小组件 | T7 |
| Pro 付费 | T8 |
| 无网可用 | T3 |
