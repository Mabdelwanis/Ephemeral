#import "EphemeralPageContentViewController.h"

@implementation EphemeralPageContentViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    [[self view] setBackgroundColor:[UIColor systemPinkColor]];
}

- (BOOL)_canShowWhileLocked {
    return YES;
}
@end
