<div align="center">
  <img src="HairWashTracker/assets/icon.png" alt="Hair Wash Tracker 徽标" height="96" />
</div>

# Hair Wash Tracker

[![许可证：GPL-3.0-only](https://img.shields.io/badge/许可证-GPL--3.0--only-blue.svg)](LICENSE)

[English version](README.md) · [Versión en español](README_ES.md) · [Deutsche Version](README_DE.md) · [Version française](README_FR.md) · [Versione italiana](README_IT.md) · 中文版

本地优先的 Flutter 洗发记录应用。在日历上记录洗发日期，查看按周和按月
统计，并获得下次建议洗发的自适应预测。无需账号，无需云端：数据保留在
设备本地。

<p align="center">
  <img src="HairWashTracker/assets/readme_home_light.png" width="45%" alt="主页，浅色主题">
  &nbsp;&nbsp;
  <img src="HairWashTracker/assets/readme_home_dark.png" width="45%" alt="主页，深色主题">
</p>

## 功能

- 可交互的月历；点按某天即可记录或删除一次洗发
- 根据已记录历史预测洗发日期
- 按周柱状图和按月计数
- 自适应预测下次洗发（EWMA 间隔、趋势、星期偏好）
- 浅色、深色和跟随系统主题；四种预设（Warm Coral、Lavender Mist、
  Sage Mist、Ocean Blue），在受支持的设备上支持 Android 动态取色
- 自适应导航（手机底部栏，大屏侧边栏）
- 本地持久化；支持 CSV 和 JSON 导入导出，可通过系统分享面板分享导出文件

## 统计

<p align="center">
  <img src="HairWashTracker/assets/readme_stats_light.png" width="45%" alt="统计页，浅色主题">
  &nbsp;&nbsp;
  <img src="HairWashTracker/assets/readme_stats_dark.png" width="45%" alt="统计页，深色主题">
</p>

## 技术栈

- Flutter / Dart, Material 3
- `provider` 状态管理
- `table_calendar` 日历视图
- `shared_preferences` 本地存储
- `dynamic_color` Android 动态主题

## 快速开始

```bash
git clone https://github.com/marodriguezd/HairWashTracker.git
cd HairWashTracker/HairWashTracker
flutter pub get
flutter run
```

质量检查：

```bash
flutter analyze
flutter test
```

## 兼容性

- Android（minSdk 24，targetSdk 36）
- 包含自适应图标和单色启动器图标
