#import "EphemeralPageViewController.h"

@implementation EphemeralPageViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setDelegate:self];
    [self setDataSource:self];

    EphemeralPageContentViewController* initialContentViewController = [self viewControllerAtIndex:0];
    NSArray* viewControllers = [NSArray arrayWithObject:initialContentViewController];
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (EphemeralPageContentViewController *)viewControllerAtIndex:(NSUInteger)index {
    [self setContentViewController:[[EphemeralPageContentViewController alloc] init]];
    [[self contentViewController] setPageIndex:index];
    return [self contentViewController];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [((EphemeralPageContentViewController *) [self contentViewController]) pageIndex];
    if (index == 0 || index == NSNotFound) {
        return nil;
    }

    index--;

    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [((EphemeralPageContentViewController *) [self contentViewController]) pageIndex];
    if (index == NSNotFound) {
        return nil;
    }

    index++;

    if (index == kPageCount) {
        return nil;
    }

    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return [((EphemeralPageContentViewController *) [self contentViewController]) pageIndex];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return kPageCount;
}

- (BOOL)_canShowWhileLocked {
    return YES;
}
@end
