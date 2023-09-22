#import "EphemeralCore.h"

CSCoverSheetView* coverSheetView;
SpringBoard* springBoard;

#pragma mark - Class properties

static BOOL isEphemeralStandByActive(CSCoverSheetView* self, SEL _cmd) {
    BOOL rawValue;
    [objc_getAssociatedObject(self, (void *)isEphemeralStandByActive) getValue:&rawValue];
    return rawValue;
};
static void setIsEphemeralStandByActive(CSCoverSheetView* self, SEL _cmd, BOOL rawValue) {
    NSValue* value = [NSValue valueWithBytes:&rawValue objCType:@encode(BOOL)];
    objc_setAssociatedObject(self, (void *)isEphemeralStandByActive, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static UIViewController* ephemeralPageViewController(CSCoverSheetView* self, SEL _cmd) {
    return (UIViewController *)objc_getAssociatedObject(self, (void *)ephemeralPageViewController);
};
static void setEphemeralPageViewController(CSCoverSheetView* self, SEL _cmd, UIViewController* rawValue) {
    objc_setAssociatedObject(self, (void *)ephemeralPageViewController, rawValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Initialization

static void (* orig_CSCoverSheetView_didMoveToWindow)(CSCoverSheetView* self, SEL _cmd);
static void override_CSCoverSheetView_didMoveToWindow(CSCoverSheetView* self, SEL _cmd) {
    orig_CSCoverSheetView_didMoveToWindow(self, _cmd);

    if (coverSheetView) {
        return;
    }

    coverSheetView = self;
    springBoard = (SpringBoard *)[objc_getClass("SpringBoard") sharedApplication];

    [self setEphemeralPageViewController:[[EphemeralPageViewController alloc] init]];
    [[self superview] addSubview:[[self ephemeralPageViewController] view]];

    [[[self ephemeralPageViewController] view] setHidden:YES];
    [self setIsEphemeralStandByActive:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
}

#pragma mark - StandBy management

static void (* orig_SBUIController_ACPowerChanged)(SBUIController* self, SEL _cmd);
static void override_SBUIController_ACPowerChanged(SBUIController* self, SEL _cmd) {
    orig_SBUIController_ACPowerChanged(self, _cmd);
    triggerEphemeralStandBy();
}

static void orientationChanged(CSCoverSheetView* self, SEL _cmd) {
    triggerEphemeralStandBy();
}

static void triggerEphemeralStandBy() {
    if (!UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) ||
        ![[objc_getClass("SBUIController") sharedInstance] isOnAC] ||
        ![springBoard isLocked]
    ) {
        [coverSheetView deactivateEphemeralStandBy];
        return;
    }

    [coverSheetView activateEphemeralStandBy];
}

static void activateEphemeralStandBy(CSCoverSheetView* self, SEL _cmd) {
    if ([self isEphemeralStandByActive]) {
        return;
    }
    [self setIsEphemeralStandByActive:YES];

    [[[coverSheetView ephemeralPageViewController] view] setHidden:NO];

    disableBiometrics();
    disableAutoBrightness();
    setBrightness(0.4);

    [[NSNotificationCenter defaultCenter] postNotificationName:@"EphemeralStandByActivated" object:nil];
}

static void deactivateEphemeralStandBy(CSCoverSheetView* self, SEL _cmd) {
    if (![self isEphemeralStandByActive]) {
        return;
    }
    [self setIsEphemeralStandByActive:NO];

    [[[coverSheetView ephemeralPageViewController] view] setHidden:YES];

    enableBiometrics();
    if (wasAutoBrightnessEnabled) {
        enableAutoBrightness();
    } else {
        setBrightness(previousBrightness);
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"EphemeralStandByDeactivated" object:nil];
}

static void enableBiometrics() {
    [[objc_getClass("SBLockScreenManager") sharedInstance] setBiometricAutoUnlockingDisabled:NO forReason:@"dev.traurige.ephemeral"];
    [[objc_getClass("SBUIBiometricResource") sharedInstance] noteScreenWillTurnOn];
}

static void disableBiometrics() {
    [[objc_getClass("SBLockScreenManager") sharedInstance] setBiometricAutoUnlockingDisabled:YES forReason:@"dev.traurige.ephemeral"];
    [[objc_getClass("SBUIBiometricResource") sharedInstance] noteScreenDidTurnOff];
}

static void enableAutoBrightness() {
    CFPreferencesSetAppValue(CFSTR("BKEnableALS"), kCFBooleanTrue, CFSTR("com.apple.backboardd"));
    CFPreferencesAppSynchronize(CFSTR("com.apple.backboardd"));
    GSSendAppPreferencesChanged(CFSTR("com.apple.backboardd"), CFSTR("BKEnableALS"));
}

static void disableAutoBrightness() {
    Boolean valid = NO;
	wasAutoBrightnessEnabled = CFPreferencesGetAppBooleanValue(CFSTR("BKEnableALS"), CFSTR("com.apple.backboardd"), &valid);

	if (wasAutoBrightnessEnabled) {
		CFPreferencesSetAppValue(CFSTR("BKEnableALS"), kCFBooleanFalse, CFSTR("com.apple.backboardd"));
		CFPreferencesAppSynchronize(CFSTR("com.apple.backboardd"));
		GSSendAppPreferencesChanged(CFSTR("com.apple.backboardd"), CFSTR("BKEnableALS"));
	}
}

static void setBrightness(CGFloat value) {
    previousBrightness = BKSDisplayBrightnessGetCurrent();
    BKSDisplayBrightnessSet(value, 0);
}

#pragma mark - Constructor

__attribute((constructor)) static void initialize() {
    class_addProperty(NSClassFromString(@"CSCoverSheetView"), "isEphemeralStandByActive", (objc_property_attribute_t[]){{"T", @encode(BOOL)}, {"N", ""}, {"V", "_isEphemeralStandByActive"}}, 3);
    class_addMethod(NSClassFromString(@"CSCoverSheetView"), @selector(isEphemeralStandByActive), (IMP)&isEphemeralStandByActive, "C@:");
    class_addMethod(NSClassFromString(@"CSCoverSheetView"), @selector(setIsEphemeralStandByActive:), (IMP)&setIsEphemeralStandByActive, "v@:C");
    class_addProperty(NSClassFromString(@"CSCoverSheetView"), "ephemeralPageViewController", (objc_property_attribute_t[]){{"T", "@\"UIViewController\""}, {"N", ""}, {"V", "_ephemeralPageViewController"}}, 3);
    class_addMethod(NSClassFromString(@"CSCoverSheetView"), @selector(ephemeralPageViewController), (IMP)&ephemeralPageViewController, "@@:");
    class_addMethod(NSClassFromString(@"CSCoverSheetView"), @selector(setEphemeralPageViewController:), (IMP)&setEphemeralPageViewController, "v@:@");

    class_addMethod(objc_getClass("CSCoverSheetView"), @selector(orientationChanged), (IMP)&orientationChanged, "v@:");
    class_addMethod(objc_getClass("CSCoverSheetView"), @selector(activateEphemeralStandBy), (IMP)&activateEphemeralStandBy, "v@:");
    class_addMethod(objc_getClass("CSCoverSheetView"), @selector(deactivateEphemeralStandBy), (IMP)&deactivateEphemeralStandBy, "v@:");

    MSHookMessageEx(objc_getClass("CSCoverSheetView"), @selector(didMoveToWindow), (IMP)&override_CSCoverSheetView_didMoveToWindow, (IMP *)&orig_CSCoverSheetView_didMoveToWindow);
    MSHookMessageEx(objc_getClass("SBUIController"), @selector(ACPowerChanged), (IMP)&override_SBUIController_ACPowerChanged, (IMP *)&orig_SBUIController_ACPowerChanged);
}
