#import "EphemeralObservers.h"

#pragma mark - SBDashBoardIdleTimerProvider class hooks

static void (* orig_SBDashBoardIdleTimerProvider_initWithDelegate)(SBDashBoardIdleTimerProvider* self, SEL _cmd, id delegate);
static void override_SBDashBoardIdleTimerProvider_initWithDelegate(SBDashBoardIdleTimerProvider* self, SEL _cmd, id delegate) {
    orig_SBDashBoardIdleTimerProvider_initWithDelegate(self, _cmd, delegate);

    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
    [notificationCenter addObserver:self selector:@selector(enableIdleTimer) name:@"EphemeralStandByDeactivated" object:nil];
    [notificationCenter addObserver:self selector:@selector(disableIdleTimer) name:@"EphemeralStandByActivated" object:nil];
}

static void enableIdleTimer(SBDashBoardIdleTimerProvider* self, SEL _cmd) {
    [self removeDisabledIdleTimerAssertionReason:@"dev.traurige.ephemeral"];
}

static void disableIdleTimer(SBDashBoardIdleTimerProvider* self, SEL _cmd) {
    [self addDisabledIdleTimerAssertionReason:@"dev.traurige.ephemeral"];
}

#pragma mark - UIStatusBar_Modern class hooks

static void (* orig_UIStatusBar_Modern_setFrame)(UIStatusBar_Modern* self, SEL _cmd, CGRect frame);
static void override_UIStatusBar_Modern_setFrame(UIStatusBar_Modern* self, SEL _cmd, CGRect frame) {
    orig_UIStatusBar_Modern_setFrame(self, _cmd, frame);

    if (isStatusBarObserverAdded) {
        return;
    }
    isStatusBarObserverAdded = YES;

    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
    [notificationCenter addObserver:self selector:@selector(hideStatusBar) name:@"EphemeralStandByActivated" object:nil];
    [notificationCenter addObserver:self selector:@selector(unhideStatusBar) name:@"EphemeralStandByDeactivated" object:nil];
}

static void hideStatusBar(UIStatusBar_Modern* self, SEL _cmd) {
    [self setHidden:YES];
}

static void unhideStatusBar(UIStatusBar_Modern* self, SEL _cmd) {
    [self setHidden:NO];
}

#pragma mark - Constructor

__attribute((constructor)) static void initialize() {
    class_addMethod(objc_getClass("SBDashBoardIdleTimerProvider"), @selector(enableIdleTimer), (IMP)&enableIdleTimer, "v@:");
    class_addMethod(objc_getClass("SBDashBoardIdleTimerProvider"), @selector(disableIdleTimer), (IMP)&disableIdleTimer, "v@:");
    MSHookMessageEx(objc_getClass("SBDashBoardIdleTimerProvider"), @selector(initWithDelegate:), (IMP)&override_SBDashBoardIdleTimerProvider_initWithDelegate, (IMP *)&orig_SBDashBoardIdleTimerProvider_initWithDelegate);

    class_addMethod(objc_getClass("UIStatusBar_Modern"), @selector(hideStatusBar), (IMP)&hideStatusBar, "v@:");
    class_addMethod(objc_getClass("UIStatusBar_Modern"), @selector(unhideStatusBar), (IMP)&unhideStatusBar, "v@:");
    MSHookMessageEx(objc_getClass("UIStatusBar_Modern"), @selector(setFrame:), (IMP)&override_UIStatusBar_Modern_setFrame, (IMP *)&orig_UIStatusBar_Modern_setFrame);
}
