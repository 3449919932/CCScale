// CCScale 1.9 — 参数写死版：Scale=1.02，Offset=(0,0)，不读取任何 plist
// 以后重装即为最终效果，无需任何配置。
//
// 原理：hook SpringBoard 的 CCUIModularControlCenterOverlayViewController，
// 布局完成后先把 bounds 还原成窗口尺寸（避免 transform 导致 bounds 被压缩、
// 子视图按旧宽度布局造成单侧裁切），再套用整体缩放。
// 不改动 ControlCenter18 任何文件。

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface CCUIModularControlCenterOverlayViewController : UIViewController
@end

// ===== 写死的参数（要改就改这里，重新编译） =====
static const CGFloat kCCScale  = 1.02;   // 缩放：1.0 = 原生，>1 放大，<1 缩小
static const CGFloat kCCOffsetX = 0.0;   // 水平偏移（点，正值向右）
static const CGFloat kCCOffsetY = 0.0;   // 垂直偏移（点，正值向下）
// ================================================

static void CCApply(UIViewController *vc) {
    UIView *v = vc.view;
    if (!v) return;

    UIWindow *win = v.window ?: v.superview.window;
    CGSize want = win ? win.bounds.size : CGSizeZero;

    if (want.width > 1 && want.height > 1) {
        // 修复：transform 存在时 SpringBoard 设 frame 会把 bounds 缩成 frame/scale，
        // 这里强制还原，保证 CC18 子视图按真实屏宽布局。
        if (!CGSizeEqualToSize(v.bounds.size, want)) {
            v.bounds = CGRectMake(0, 0, want.width, want.height);
        }
        CGPoint center = CGPointMake(want.width / 2.0, want.height / 2.0);
        if (!CGPointEqualToPoint(v.center, center)) v.center = center;
    }

    CGAffineTransform t = CGAffineTransformMakeScale(kCCScale, kCCScale);
    if (kCCOffsetX != 0 || kCCOffsetY != 0) {
        t = CGAffineTransformConcat(t, CGAffineTransformMakeTranslation(kCCOffsetX, kCCOffsetY));
    }
    if (!CGAffineTransformEqualToTransform(v.transform, t)) {
        v.transform = t;
    }
}

%hook CCUIModularControlCenterOverlayViewController

- (void)viewDidLayoutSubviews {
    %orig;
    CCApply(self);
}

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    CCApply(self);
}

%end

%ctor {
    NSLog(@"[CCScale] 1.9 loaded: Scale=%.3f Offset=(%.1f, %.1f)", kCCScale, kCCOffsetX, kCCOffsetY);
}
