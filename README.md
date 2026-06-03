# 孕育时光 · BumpJourney

孕期周期全流程管理 App（Flutter）。以「孕周」为核心时间轴，双轨视角（孕妈 / 准爸爸），本地优先存储，预留云端 AI 内容提取。

## 运行环境

- Flutter SDK ≥ 3.16（含 Dart ≥ 3.3）
- 桌面端（Windows / macOS / Linux）已通过 `sqflite_common_ffi` 适配，可直接 `flutter run` 调试
- 移动端：Android / iOS 均可

## 快速开始

这个压缩包只包含 `lib/` 源码与 `pubspec.yaml` 等配置，**不含**各平台脚手架目录（android/ios/windows…）。最省事的方式是用 Flutter 重新生成脚手架，再把本工程的文件覆盖进去：

```bash
# 1. 在空目录用 Flutter 生成完整工程脚手架
flutter create bumpjourney
cd bumpjourney

# 2. 用本压缩包的内容覆盖 lib/ 和 pubspec.yaml
#    （把解压出的 lib/、pubspec.yaml、analysis_options.yaml 复制进来覆盖）

# 3. 拉取依赖
flutter pub get

# 4. 运行
flutter run                 # 选择已连接的设备/模拟器
flutter run -d windows      # 或直接跑桌面端预览
flutter run -d chrome       # Web 端预览（注意 sqflite 在纯 Web 需额外适配）
```

> 提示：直接在已有的 `flutter create` 工程里替换 `lib/` 与 `pubspec.yaml`，能避免缺少平台目录导致无法构建。

## 目录结构

```
lib/
├── main.dart                      # 入口，主题随视角切换
├── theme/app_theme.dart           # 配色与主题（孕妈暖橙 / 准爸爸绿）
├── models/models.dart             # 数据模型
├── data/standard_data.dart        # 内置标准孕周数据（关键里程碑周）
├── providers/app_state.dart       # 核心状态（Provider）
├── services/
│   ├── database_service.dart      # SQLite（含桌面端 ffi）
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
    └── profile_screen.dart        # 我的（设置预产期）
```

## 已实现

- 双轨视角切换（主题色随之变化）
- 孕周轮播轴（点击定位、自动居中、本周高亮）
- 时间线 feed：胎儿摘要、饮食红黑榜、产检勾选 / 老公任务看板
- 自定义节点新建、勾选、左滑删除，落 SQLite
- 知识库锚定卡片 + 标签筛选
- 提醒中心、我的（按预产期推算孕周）
- 首次启动注入演示数据

## 待打磨（下一步）

1. 补全 40 周完整标准数据（对齐权威指南）
2. 接入 `flutter_local_notifications` 真正触发提醒
3. AI 提取改为真实云端调用（经自有后端中转，勿在客户端硬编码 Key）
4. iCloud / Google Drive 云备份与夫妻双人同步
5. Premium 内购变现闭环

## 合规

孕期数据默认仅存本地。正式上架请对齐《中国妇产科指南》/ WHO 标准，并保留「内容仅供参考，不构成医疗诊断建议」免责声明。
