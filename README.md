# Super Weather Schedule 超级天气课程表

一个现代化的Flutter应用，将课程表管理与天气预报完美结合，为你提供智能的学习和生活提醒服务。

## 项目简介

Super Weather Schedule 是一款面向学生群体的智能日程管理应用。它不仅提供了完整的课程表管理功能，还集成了精准的天气预报服务，让你能够在规划学习的同时了解天气状况，合理安排出行。

## 功能特点

### 课程表管理

- **添加课程** - 轻松添加、编辑和删除课程
- **导入功能** - 支持CSV文件导入课程表
- **今日课程** - 快速查看当日课程安排
- **颜色定制** - 为不同课程选择喜欢的颜色
- **周视图** - 清晰的周课程表展示
- **数据持久化** - 使用SQLite本地存储课程数据

### 天气预报

- **实时天气** - 获取当前城市的实时天气信息
- **5天预报** - 查看未来5天的天气预报
- **天气详情** - 湿度、风力、气压、能见度等详细信息
- **多城市支持** - 切换多个城市查看天气（北京、上海、广州、深圳等）
- **智能提醒** - 下雨时自动提醒带伞
- **多种天气服务** - 集成彩云天气和风君子天气API

### 智能提醒

- **天气提醒** - 每日天气概况提醒
- **带伞提醒** - 下雨时的带伞提示
- **课程提醒** - 当日课程安排提醒
- **未读标记** - 清晰的已读/未读状态

### 个性化设置

- **主题切换** - 支持浅色、深色、系统主题
- **城市设置** - 设置默认城市
- **数据管理** - 一键清除所有课程数据
- **用户指南** - 完整的使用说明

## 技术特性

- **Flutter 3.0+** - 跨平台开发框架
- **Material Design 3** - 现代化的设计语言
- **SQLite** - 本地数据存储
- **Dio/Http** - 网络请求库
- **SharedPreferences** - 用户设置持久化
- **Intl** - 国际化和日期格式化
- **Geolocator** - 地理位置服务
- **Flutter Weather BG** - 天气背景动画

## 项目结构

```
lib/
├── main.dart - 应用入口和主题配置
├── models/ - 数据模型
│   ├── course.dart - 课程模型
│   ├── reminder.dart - 提醒模型
│   └── weather.dart - 天气模型
├── pages/ - 页面组件
│   ├── schedule_page.dart - 课程表页面
│   ├── weather_page.dart - 天气页面
│   ├── reminder_page.dart - 提醒页面
│   └── settings_page.dart - 设置页面
├── services/ - 服务层
│   ├── database_service.dart - 数据库服务
│   ├── weather_service.dart - 天气服务
│   ├── weather_service_manager.dart - 天气服务管理器
│   ├── caiyun_weather_service.dart - 彩云天气API
│   ├── itboy_weather_service.dart - 风君子天气API
│   ├── csv_importer.dart - CSV导入服务
│   ├── reminder_service.dart - 提醒服务
│   ├── city_manager.dart - 城市管理服务
│   ├── city_codes.dart - 城市代码
│   └── city_coordinates.dart - 城市坐标
└── utils/ - 工具类
    └── weather_utils.dart - 天气工具函数
```

## 安装使用

### 前置要求

- Flutter SDK (3.0.0 或更高版本)
- Dart SDK
- Android Studio / VS Code (推荐)
- Android SDK (用于Android开发)
- Xcode (用于iOS开发，仅限macOS)

### 运行步骤

1. **克隆项目**
```bash
git clone https://gitee.com/gcx_952128814/flutter_-final_-homework.git
cd flutter_-final_-homework
```

2. **安装依赖**
```bash
flutter pub get
```

3. **运行应用**

**Android:**
```bash
flutter run
```

**Web (Chrome):**
```bash
flutter run -d chrome --web-port 8083
```

**Windows:**
```bash
flutter run -d windows
```

4. **构建APK (发布版本)**
```bash
flutter build apk --release
```

生成的APK文件位于：`build/app/outputs/flutter-apk/app-release.apk`

### 开发环境配置

如果还没有配置Flutter开发环境，请参考[Flutter官方文档](https://flutter.dev/docs/get-started/install)进行安装。

## CSV导入格式

导入课程表时，请使用以下CSV格式：

```csv
name,classroom,dayOfWeek,period
数学,101,1,1
英语,202,1,2
物理,303,2,1
```

**字段说明：**

- `name` - 课程名称
- `classroom` - 教室
- `dayOfWeek` - 星期几 (1-7, 1代表周一)
- `period` - 第几节课 (1-8)

## 界面预览

应用包含四个主要界面，通过底部导航栏切换：

1. **Schedule (课程表)** - 管理和查看课程安排
2. **Weather (天气)** - 查看实时天气和预报
3. **Reminders (提醒)** - 查看智能提醒消息
4. **Settings (设置)** - 个性化设置和数据管理

## 使用截图

![Schedule](lib/flutter_run_1.jpg)
![Settings](lib/flutter_run_2.jpg)

## 设计理念

- **现代化UI** - 使用渐变色、圆角、阴影营造美观界面
- **流畅体验** - 精心设计的动画和过渡效果
- **简洁直观** - 易于理解和使用的界面布局
- **多主题** - 支持浅色和深色主题，保护眼睛
- **响应式设计** - 适配不同屏幕尺寸

## 许可证

MIT License - 详见 LICENSE 文件

## 贡献

欢迎提交 Issue 和 Pull Request！

享受你的智能学习生活！🌟
