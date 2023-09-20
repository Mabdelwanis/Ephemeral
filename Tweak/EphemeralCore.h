#import <substrate.h>
#import <UIKit/UIKit.h>
#import <BackBoardServices/BKSDisplayBrightness.h>
#import "ViewController/EphemeralPageViewController.h"

extern "C" void GSSendAppPreferencesChanged(CFStringRef bundleID, CFStringRef key);
static void enableBiometrics();
static void disableBiometrics();
static void enableAutoBrightness();
static void disableAutoBrightness();
static void setBrightness(CGFloat brightness);

BOOL wasAutoBrightnessEnabled = YES;
CGFloat previousBrightness = 0;

@interface CSCoverSheetView : UIView
@property(nonatomic, assign)BOOL isEphemeralStandByActive;
@property(nonatomic, retain)EphemeralPageViewController* ephemeralPageViewController;
- (void)activateEphemeralStandBy;
- (void)deactivateEphemeralStandBy;
@end

@interface SBUIController : NSObject
+ (id)sharedInstance;
- (BOOL)isOnAC;
@end

@interface SpringBoard : UIApplication
@end

@interface SBLockScreenManager : NSObject
+ (id)sharedInstance;
- (BOOL)isUILocked;
- (void)setBiometricAutoUnlockingDisabled:(BOOL)disabled forReason:(NSString *)reason;
@end

@interface SBUIBiometricResource : NSObject
+ (id)sharedInstance;
- (void)noteScreenDidTurnOff;
- (void)noteScreenWillTurnOn;
@end
