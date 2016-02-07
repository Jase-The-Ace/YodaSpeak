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
    
    UIAlertAction *action = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * _Nonnull action) {
                                 [self dismissViewControllerAnimated:YES completion:nil];
                             }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
