# PiliPalaX 项目开发规则

## 项目概述
PiliPalaX 是一个基于 Flutter 开发的哔哩哔哩第三方客户端，支持 Android / iOS / Windows / Linux / macOS 平台。
本项目已无原始维护者，由我们自行开发维护，可以自由修改任何配置。

## 构建环境要求

### 必须设置 PUB_CACHE 环境变量
项目位于 E 盘，而 Windows 默认的 Flutter Pub Cache 在 C 盘。
Gradle 在跨盘符时无法正确计算相对路径（`different roots` 错误），**必须**将 `PUB_CACHE` 设置到 E 盘：
```powershell
$env:PUB_CACHE="E:\PubCache"
```
所有 `flutter build`、`flutter run`、`flutter pub` 命令执行前都需要先设置此环境变量。

### Android 构建命令
```powershell
$env:PUB_CACHE="E:\PubCache"; flutter build apk --debug
```

### Java 版本
- 项目使用 **Java 17** 作为编译目标（`JavaVersion.VERSION_17`）
- 请勿升级到 Java 21，部分第三方插件不兼容

### Kotlin 版本
- 当前 Kotlin 版本为 2.0.20
- `gradle.properties` 中已配置 `kotlin.jvm.target.validation.mode=warning` 以绕过 JVM target 校验

## 镜像源配置

### Gradle 分发
使用华为云镜像（已配置在 `android/gradle/wrapper/gradle-wrapper.properties`）：
```
https://repo.huaweicloud.com/gradle/
```

### media_kit 原生库
`media_kit_libs_android_video` 插件在编译时会从 GitHub 下载 `.jar` 原生库。
国内环境下载不稳定，已在插件的 `build.gradle` 中配置了 `kkgithub.com` 镜像。
如果下载仍然失败，可使用项目根目录下的 `download_jars.ps1` 脚本手动下载（支持多镜像轮询 + MD5 校验）。

JAR 文件缓存位置：`E:\Documents\PiliPalaX\build\media_kit_libs_android_video\v1.1.5\`

## 已修补的第三方插件

以下插件因使用已废弃的 `PluginRegistry.Registrar`（Flutter v1 embedding）在新版 Flutter 下编译失败，
已直接修改其 PubCache 中的 Java 源码，删除了旧的 `registerWith` 方法和相关 import：

| 插件 | 修补文件位置 |
|------|-------------|
| `status_bar_control` 3.2.1 | `E:\PubCache\hosted\pub.flutter-io.cn\status_bar_control-3.2.1\android\...` |
| `webview_cookie_manager` 2.0.6 | `E:\PubCache\hosted\pub.flutter-io.cn\webview_cookie_manager-2.0.6\android\...` |

> [!WARNING]
> 如果执行 `flutter pub get` 或清空 PubCache，这些修补会丢失，需要重新应用。
> 未来应考虑将这两个插件 fork 到自己的仓库中，通过 git 依赖引用。

## API 适配记录

| 变更 | 文件 | 说明 |
|------|------|------|
| `CardTheme` → `CardThemeData` | `lib/main.dart` | Flutter 3.38+ 重命名了此类 |
| `flutter_mailer` 2.1.2 → 3.0.2 | `pubspec.yaml` | 旧版使用了已移除的 v1 embedding API |

## 注意事项

- **必须提交 `pubspec.lock`**：本项目是一个面向终端用户的 Application，为了绝对保证编译稳定性并切断第三方依赖的“幽灵升级”，**必须强制提交 `pubspec.lock` 文件**。此规则覆写全局配置中的 `Avoid committing package manager lockfiles` 规则。每次新增或有意升级依赖时，请连同 lock 文件一起 commit。
- 编译过程中出现的大量 `Warning: 'namespace' is not specified` 和 `Overriding compileSdk` 是正常的，不影响构建
- `android/build.gradle` 中的 `buildDir` 使用了 `new File()` 绝对路径写法，请勿改回相对路径字符串
- 构建产物 APK 输出路径：`build\app\outputs\flutter-apk\app-debug.apk`
