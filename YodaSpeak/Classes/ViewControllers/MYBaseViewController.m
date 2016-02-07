//
//  MYBaseViewController.m
//

#import "MYBaseViewController.h"

@implementation MYBaseViewController

- (void)showError:(NSString *)title message:(NSString *)message {
    UIAlertController *alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:alert animated:YES completion:nil];
}


@end
