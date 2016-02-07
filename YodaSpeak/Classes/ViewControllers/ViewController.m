//
//  ViewController.m
//  YodaSpeak
//
//  Created by Jesse A on 2/6/16.
//  Copyright © 2016 Jesse A. All rights reserved.
//

#import "ViewController.h"
#import "YodaController.h"
#import "YodaSpokenListVC.h"

@interface ViewController () <YodaControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *yodaResponseLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progressBar;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Streams";
    [self setupNavButtons];
    
    [self.progressBar stopAnimating];
    [self resetUI];

}

- (void)resetUI {
    self.yodaResponseLabel.text = @"[Yoda will respond here]";
}

- (void)updateUI:(NSString *)yodaText {
    self.yodaResponseLabel.text = yodaText;
}

- (void)setupNavButtons {
    self.navigationItem.rightBarButtonItem = [MYStyleSheet barButtonItemWithImage:[UIImage imageNamed:@"top_nav_info"] highlightedImage:[UIImage imageNamed:@"top_nav_info"] target:self action:@selector(listingButtonPress) xOffset:0 height:30.0f width:30.0f];
}

- (void) showEditDialog:(NSString *)title {
    UIAlertController *alert = [UIAlertController
                                            alertControllerWithTitle:title
                                            message:@"Please enter the text."
                                            preferredStyle:UIAlertControllerStyleAlert];
    
    __weak UIAlertController *alertRef = alert;
    UIAlertAction *action = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * _Nonnull action) {
                                     NSString *text = ((UITextField *)[alertRef.textFields objectAtIndex:0]).text;
                                     [self fetchYodaText:text];
                                     
                                 }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = title;
     }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
    

}

- (void)fetchYodaText:(NSString *)message {
    if (!IsEmpty(message)) {
        [self resetUI];
        [self.progressBar startAnimating];
        YodaController *yodaController = [YodaController sharedYodaController];
        yodaController.delegate = self;
        [yodaController fetchYodaText:message];
    }
}

#pragma mark Button Taps
- (IBAction)enterMessageButtonTap {
    [self showEditDialog:@"Enter text"];
    
}

- (void)listingButtonPress {
    YodaSpokenListVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([YodaSpokenListVC class])];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark delegates
- (void)YodaController:(YodaController *)controller didFetchYoda:(NSString *)yodaText {
    [self.progressBar stopAnimating];

    [self updateUI:yodaText];
}

- (void)YodaController:(YodaController *)controller didFailWithError:(NSError *)error {
    [self.progressBar stopAnimating];
    [self showError:@"Error fetching yoda response" message:[NSString stringWithFormat:@"%@", error]];
}

@end
