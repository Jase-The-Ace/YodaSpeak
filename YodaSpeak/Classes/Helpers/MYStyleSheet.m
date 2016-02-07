//
//  MYStyleSheet.m
//  MysteryApplicationiOS
//

#import "MYStyleSheet.h"

@implementation MYStyleSheet

#pragma mark Navigation Bar elements

+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage target:(id)target action:(SEL)selector xOffset:(CGFloat)xOffset {
    
    return [MYStyleSheet barButtonItemWithImage:image highlightedImage:highlightedImage target:target action:selector xOffset:xOffset height:image.size.height width:image.size.width];
}

+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage target:(id)targetOrNil action:(SEL)selectorOrNil xOffset:(CGFloat)xOffset height:(CGFloat)height width:(CGFloat)width {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGRect buttonFrame = CGRectMake(0.0f, 0.0f, width + fabsf(xOffset), height);
    
    button.frame = buttonFrame;
    [button setImage:image            forState:UIControlStateNormal];
    [button setImage:highlightedImage forState:UIControlStateHighlighted];
    
    if (targetOrNil && selectorOrNil) {
        [button addTarget:targetOrNil action:selectorOrNil forControlEvents:UIControlEventTouchUpInside];
    }
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}


@end
