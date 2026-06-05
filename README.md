# 孕育时光 · BumpJourney

孕期周期全流程管理 App（Flutter）。以「孕周」为核心时间轴，双轨视角（孕妈 / 准爸爸），本地优先存储，预留云端 AI 内容提取。

## 运行环境

- Flutter SDK ≥ 3.16（含 Dart ≥ 3.3）
- 桌面端（Windows / macOS / Linux）已通过 `sqflite_common_ffi` 适配，可直接 `flutter run` 调试
- 移动端：Android / iOS 均可

## 快速开始

本项目已生成并完整配置了跨平台原生工程脚手架（Android, iOS, Windows, macOS, Linux, Web）。特别地，针对 Android 端已预先配置了 Java 8 核心库脱糖（core library desugaring）以兼容高级别的通知推送 API。您可以直接拉取依赖并运行：

```bash
# 1. 拉取依赖
flutter pub get

# 2. 运行调试
flutter run                 # 选择已连接的设备/模拟器
flutter run -d windows      # 或直接跑桌面端预览
```

## 目录结构

```
lib/
├── main.dart                      # 入口，主题随视角切换
├── theme/app_theme.dart           # 配色与主题（孕妈暖橙 / 准爸爸绿）
├── models/models.dart             # 数据模型
├── data/standard_data.dart        # 内置标准孕周数据（关键里程碑周）
├── providers/app_state.dart       # 核心状态（Provider）
├── services/
│   ├── database_service.dart      # SQLite（含桌面端 ffi、版本化迁移框架）
│   ├── notification_service.dart  # 本地通知调度（flutter_local_notifications + 时区）
│   └── ai_extractor.dart          # AI 结构化提取（占位，预留云端接入）
├── widgets/
│   ├── section_card.dart          # 卡片 / 标签
│   ├── week_rail.dart             # 孕周轮播轴
│   ├── role_switch.dart           # 视角切换开关
│   └── check_row.dart             # 可勾选条目
└── screens/
    ├── home_shell.dart            # 主壳（顶栏 + tab + FAB）
    ├── timeline_screen.dart       # 时间线主页（双轨 feed）
    ├── add_node_sheet.dart        # 新建自定义节点弹窗
    ├── knowledge_screen.dart      # 知识库
    ├── reminders_screen.dart      # 提醒中心
    ├── profile_screen.dart        # 我的（孕期基准设定）
    ├── due_date_sheet.dart        # 预产期 / 末次月经 / B超孕周 推算弹窗
    └── tools_screen.dart 及       # 孕期工具中心
        fetal_movement / contraction / weight / checklist_screen.dart
```

测试位于 `test/`（模型序列化、孕周推算、标准数据覆盖、CheckRow 组件等）；
`.github/workflows/ci.yml` 在 push/PR 时自动跑 `flutter analyze + test`。

## 已实现

- 双轨视角切换（主题色随之变化）
- 孕周轮播轴（点击定位、自动居中、本周高亮，覆盖第 1–40 周）
- 时间线 feed：胎儿摘要、饮食红黑榜、起居调养（营养/运动/睡眠/喝水）、本周注意事项、产检勾选
- 准爸爸视角：老公任务看板 +「老婆这周的状态」+ 逐周体贴提示
- 内置 1–40 周完整标准数据（饮食、营养补充、运动量、分孕期睡眠姿势/禁忌、喝水量、注意事项，含准爸爸视角）
- **孕期工具**：胎动计数、宫缩计时（5-1-1 提示）、体重增长曲线、待产包清单
- **本地通知**：带「提前提醒」的事件在目标日前 N 天 09:00 触发（flutter_local_notifications）
- **孕期基准设定**：支持 预产期 / 末次月经(LMP) / B超孕周 三种推算，落 shared_preferences
- 产检 / 老公任务勾选态、自定义节点均落 SQLite（含版本化迁移框架）
- 知识库锚定卡片 + 标签筛选
- 首次启动注入演示数据
- GitHub Actions CI（analyze + 单元/组件测试）

## 待打磨（下一步）

1. 真机验证本地通知（Android receiver / iOS 权限弹窗与前台展示）
2. AI 提取改为真实云端调用（经自有后端中转，勿在客户端硬编码 Key）
3. iCloud / Google Drive 云备份与夫妻双人同步
4. Premium 内购变现闭环
5. 替换 App 图标 / 启动屏（当前为 Flutter 默认占位），补隐私政策

## 合规

孕期数据默认仅存本地。正式上架请对齐《中国妇产科指南》/ WHO 标准，并保留「内容仅供参考，不构成医疗诊断建议」免责声明。
