#import <substrate.h>
#import <UIKit/UIKit.h>

BOOL isStatusBarObserverAdded = NO;

@interface SBDashBoardIdleTimerProvider : NSObject
- (void)addDisabledIdleTimerAssertionReason:(NSString *)reason;
- (void)removeDisabledIdleTimerAssertionReason:(NSString *)reason;
@end

@interface UIStatusBar_Modern : UIView
@end
