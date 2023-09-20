#import <UIKit/UIKit.h>
#import "ContentViewController/EphemeralPageContentViewController.h"

static NSUInteger const kPageCount = 2;

@interface EphemeralPageViewController : UIPageViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>
@property(nonatomic, retain)EphemeralPageContentViewController* contentViewController;
@end
