#import "EphemeralViewController.h"

@implementation EphemeralViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setDataSource:self];

    UIViewController* vc1 = [[UIViewController alloc] init];
    vc1.view.backgroundColor = [UIColor redColor];
    UIViewController* vc2 = [[UIViewController alloc] init];
    vc2.view.backgroundColor = [UIColor greenColor];

    [self setMyControllers:@[vc1, vc2]];
    [self setViewControllers:@[vc1] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger currentIndex = [[self myControllers] indexOfObject:viewController];
    if (currentIndex > 0) {
        return [self myControllers][currentIndex - 1];
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger currentIndex = [[self myControllers] indexOfObject:viewController];
    if (currentIndex < [[self myControllers] count] - 1) {
        return [self myControllers][currentIndex + 1];
    }
    return nil;
}

- (BOOL)_canShowWhileLocked {
    return YES;
}
@end
