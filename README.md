# CCScale 1.9 — 控制中心整体放大 1.02 倍（参数写死）

独立插件，作用于控制中心（含 ControlCenter18），**不改动 ControlCenter18 本体**。
参数已写死在代码里，安装即生效，**不读取任何 plist**，重装/升级后效果恒定。

## 写死的参数

```objc
static const CGFloat kCCScale   = 1.02;  // 缩放：1.00 = 原生
static const CGFloat kCCOffsetX = 0.0;   // 水平偏移（点）
static const CGFloat kCCOffsetY = 0.0;   // 垂直偏移（点）
```

## 原理

hook SpringBoard 的 `CCUIModularControlCenterOverlayViewController`：

1. `viewDidLayoutSubviews` / `viewWillAppear` 之后执行；
2. 先把 `bounds` 强制还原为窗口尺寸（375×667）——否则存在 transform 时
   SpringBoard 设置 frame 会把 bounds 压缩成 `frame/scale`，而 CC18 子视图
   仍按 375 宽布局，导致单侧裁切/位置偏移；
3. 再套 `CGAffineTransformMakeScale(1.02, 1.02)`，居中缩放。

## 构建

```bash
export THEOS="$HOME/theos"
cd CCScale-src
make clean && make package FINALPACKAGE=1
# → packages/com.dafeiyu.ccscale_1.9-1_iphoneos-arm64.deb
```

## 安装 / 卸载

Sileo 安装 deb → respring。卸载即恢复，没有安装脚本、无残留。

> 早期版本会把配置写到
> `/var/jb/var/mobile/Library/Preferences/com.dafeiyu.ccscale.plist`，
> 1.9 起不再读取它，留着也不影响；想干净可以删掉。

## 构建两种架构（同一份源码）

```bash
export THEOS="$HOME/theos"

# rootless（Dopamine 等通用环境）→ 产物 *_iphoneos-arm64.deb
make clean && make package FINALPACKAGE=1

# roothide（RootHide 环境）→ 产物 *_iphoneos-arm64e.deb
make clean && make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=roothide
```

`THEOS_PACKAGE_SCHEME` 默认 `rootless`，命令行传 `roothide` 即覆盖；
`control` 里的 `Architecture` 由 Theos 按 scheme 决定，无需手改。
